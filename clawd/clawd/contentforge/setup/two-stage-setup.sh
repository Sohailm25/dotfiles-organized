#!/bin/bash
# Two-stage architecture for contentforge:
#   Stage 1 (researcher): existing feed-highlights-slack / bookmark-slack-digest
#     - Codex (default model)
#     - Phases: fetch, triage, research, classify, write digest JSON, brief Slack status
#   Stage 2 (writer): new feed-writer-slack / bookmark-writer-slack
#     - Claude Opus 4.6 (anthropic/claude-opus-4-7 via OAuth)
#     - Phases: read digest JSON, optionally verify research, write blurbs, deliver to Slack
set -euo pipefail
cd ~/assistant/openclaw

TAVILY_KEY="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"
FEED_CHANNEL="C0ACVEM27K8"     # #contentforge-feed
CURATED_CHANNEL="C0ACVEL27PY"  # #contentforge-curated

# ====================================================================
# STAGE 1 prompt — researcher (writes structured JSON digest)
# ====================================================================
cat > /tmp/feed-research.txt <<'STAGE1_EOF'
this is the X For You feed RESEARCH stage. runs 3x daily (8 AM / 12 PM / 6 PM CT). produces a structured JSON digest of every tweet with substance, with all research findings prefetched. the WRITER stage (separate cron job, claude opus) reads this file and writes the actual blurbs.

read these two files end to end before doing anything:
- ~/clawd/contentforge/guide.md (filters, value bar, slop blacklist, POV anchors, pillars, tiers)
- ~/clawd/contentforge/stories.md (sohail's war stories — used to identify anchor opportunities)

# CRITICAL EXECUTION RULES

1. bird-cli stderr warnings ("Failed to read Safari cookies", "No Twitter cookies found") are NOISE. Only check exit code (0 = success) and that stdout starts with `[` or `{`. ignore stderr completely.
2. NEVER end the run without sending a status message to Slack channel:C0ACVEM27K8. If fetch fails entirely, send "stage 1 failed: [reason]" so sohail knows.
3. If one tweet's research fails, skip THAT item's research and continue. Do NOT abandon the run.
4. Process items in parallel batches where possible (background bash + wait).

# phase 1 — fetch timeline

run `bird home --json --count 100 > $TIMELINE_PATH` and save to:
  ~/assistant/data/feed/raw/$(date +%Y-%m-%d-%H%M)/timeline.json

# phase 2 — triage (LOOSE — sohail is the judge)

target 20-35 items cleared per 100. when in doubt, ship it.

auto-drop ONLY:
- ads / promotional posts
- pure NFT / crypto token drama
- political / culture-war
- dunks / beefs / drama with no substance
- "huge if true" with zero detail
- screenshots of LLM outputs with no commentary
- posts about sohail himself
- non-english tweets

EVERYTHING ELSE clears if it has any substance.

HARD FLOOR: if first pass clears fewer than 20 from 100, re-triage with only the drop list above.

# phase 3 — per-item research (parallel where possible)

for each cleared item:

3a. fetch replies (parse stdout, ignore stderr):
    bird replies <tweet-id> --json > ~/assistant/data/feed/raw/<ts>/replies/<tweet-id>.json
    target 30-80 replies. exit code != 0 means skip this item's replies and continue.

3b. fetch related X content:
    bird search "<keyword>" --json > ~/assistant/data/feed/raw/<ts>/research/<tweet-id>_bird.json

3c. Tavily web search (the openclaw web_search tool is BROKEN — use this instead):
    curl -s -X POST https://api.tavily.com/search \
      -H "Content-Type: application/json" \
      -d '{"api_key":"TAVILY_KEY_PLACEHOLDER","query":"<topic>","max_results":5,"search_depth":"basic"}' \
      > ~/assistant/data/feed/raw/<ts>/research/<tweet-id>_tavily.json

3d. if the tweet links to an external URL, use WebFetch and save:
    ~/assistant/data/feed/raw/<ts>/research/<tweet-id>_linked.md

# phase 4 — classify

for each cleared item, classify:
- pillar: Stack / Frame / Path
- tiers_supported: any of T1 / T2 / T3
- pov_anchor: name from guide.md POV anchors, or "no anchor"
- bridge_audience: from guide.md Bridge audiences, or "no Bridge"
- stories_anchor: slug from stories.md, or "none — observer mode"

# phase 5 — produce structured digest JSON

write a SINGLE structured JSON file to:
  ~/assistant/data/feed/digests-stage1/<ts>.json

schema:
{
  "version": 1,
  "run_id": "<ts>",
  "stage1_completed_at": "<ISO timestamp>",
  "tweets_fetched": <N>,
  "items_cleared": <N>,
  "items": [
    {
      "tweet_id": "...",
      "source_url": "https://x.com/...",
      "tweet_text": "<full text>",
      "tweet_author_handle": "...",
      "tweet_author_name": "...",
      "tweet_metrics": { "likes": ..., "replies": ..., "retweets": ... },
      "pillar": "Stack",
      "tiers_supported": ["T2", "T3"],
      "pov_anchor": "deployment-gap-is-the-business",
      "bridge_audience": "product",
      "stories_anchor": "vllm-qsr-throughput-cliffs",
      "verbatim_quote": "<best quotable line from tweet, max 220 chars, or null>",
      "replies_summary": "<one paragraph synthesizing the dominant reaction and key disagreements — uses verbatim quotes from replies file>",
      "top_critical_reply": "<verbatim quote from the most-upvoted critical reply, with @author>",
      "sentiment_delta": "<one paragraph on what the tweet claims vs what replies reveal — for steering writer's POV>",
      "research_findings": {
        "tavily_summary": "<2-4 sentences on what tavily surfaced: prior art, contradictions, related debates>",
        "linked_url_summary": "<if a linked URL was fetched, 2-3 sentences on what it adds>",
        "key_facts": ["specific verifiable fact 1", "fact 2", "..."]
      },
      "raw_files": {
        "replies": "~/assistant/data/feed/raw/<ts>/replies/<id>.json",
        "tavily": "~/assistant/data/feed/raw/<ts>/research/<id>_tavily.json",
        "bird_search": "~/assistant/data/feed/raw/<ts>/research/<id>_bird.json",
        "linked": "~/assistant/data/feed/raw/<ts>/research/<id>_linked.md (or null)"
      }
    },
    ...
  ],
  "stage2_completed_at": null
}

write the file ATOMICALLY: write to .tmp first, then mv to final path.

# phase 6 — brief slack status

send ONE message via the message tool to channel:C0ACVEM27K8:

```
stage 1 research complete -- [today's date], [HH:MM CT]

[N] tweets fetched.
[N] items cleared.
digest: ~/assistant/data/feed/digests-stage1/<ts>.json
writer fires in 5 min.
```

# phase 7 — return summary

return plain-text:
(1) tweets fetched
(2) items cleared
(3) tavily success rate
(4) digest file path
(5) any errors

timeout budget: 5400s.
STAGE1_EOF

sed -i.bak "s|TAVILY_KEY_PLACEHOLDER|$TAVILY_KEY|" /tmp/feed-research.txt

# ====================================================================
# STAGE 2 prompt — writer (reads digest, writes blurbs, delivers to Slack)
# ====================================================================
cat > /tmp/feed-writer.txt <<'STAGE2_EOF'
this is the X For You feed WRITER stage. runs 5 min after stage 1 (the researcher). reads the latest stage 1 digest JSON and writes the actual blurbs in sohail's voice.

read these two files end to end before doing anything:
- ~/clawd/contentforge/guide.md (voice rules, slop blacklist, output format, POV anchors)
- ~/clawd/contentforge/stories.md (sohail's war stories — use as anchor when stories_anchor field names one)

# CRITICAL EXECUTION RULES

1. NEVER end the run without sending to Slack channel:C0ACVEM27K8. Plain text responses go NOWHERE in cron context. Use the message tool.

2. ALWAYS find the latest stage 1 digest. If no unwritten digest exists (e.g., stage 1 failed), send a brief Slack message saying "stage 2: no new digest to write — stage 1 may have failed" and exit cleanly.

3. You have FULL research access. The stage 1 digest gives you a baseline, but if anything in it is unclear, contradictory, or you suspect a misinterpretation, you can verify by:
   - opening the raw files (replies, tavily, bird search, linked URL) listed in `raw_files`
   - calling Tavily directly: curl -s -X POST https://api.tavily.com/search -H "Content-Type: application/json" -d '{"api_key":"TAVILY_KEY_PLACEHOLDER","query":"<followup query>","max_results":5}'
   - using WebFetch on any URL
   - using `bird search "<keyword>" --json` for more X context
   USE this freedom. don't trust stage 1 blindly. when you're about to write a take that depends on a specific claim, verify it.

4. The slop blacklist in guide.md is the hardest rule. NO punchline parallel structure ("X isn't Y. Z is.", "X wins A. Y wins B."). NO "the real X is not Y. it's Z." NO mirror-grammar sentences in a row.

# phase 1 — find the latest unwritten digest

list ~/assistant/data/feed/digests-stage1/*.json by mtime, find the most recent file where `stage2_completed_at` is null.

if none found, send the "no new digest" message to channel:C0ACVEM27K8 and exit.

# phase 2 — read the digest fully

read the digest JSON. understand: tweets_fetched, items_cleared, all items.

# phase 3 — write blurbs (NO BEATS, NO STAGE DIRECTIONS, NO LENGTH CAP)

for each item in the digest:

3a. read the raw files (replies + tavily + bird search + linked URL if present) BEFORE writing. this is the depth that prevents misinterpretation.

3b. if the take you want to write depends on a specific claim, VERIFY it. examples of when to verify:
- the tweet says "X benchmark shows Y%" — verify Y is real, not exaggerated
- the tweet attributes work to person A — verify A actually did the work (not just commented)
- you want to anchor a story to stories.md — verify the anchor matches the tweet's topic
- you suspect the sentiment delta misreads the replies — re-read the replies file

call Tavily, WebFetch, or bird search as needed. each verification is cheap (1-3 calls). DO this when in doubt.

3c. write per-tier blurbs (1-3 per item depending on tiers_supported field).

each blurb is a flowing paragraph in sohail's voice. NO [BEAT N] markers. NO stage directions like [Open on face] or [Cut to screen] or [Text overlay]. NO word counts. NO second counts.

just prose. one cohesive take. opinion + substance + a payoff at the end. length is whatever the take demands.

every blurb MUST:
- open with a strong hook (5-12 words, not a punchline)
- include real substance from the research findings (tavily, replies, linked URL, your own verification)
- have a clear opinion / POV / take
- end with a payoff line that does NOT use the punchline parallel structure family

AVOID (these fail the run):
- "X isn't the bottleneck. Y is."
- "X wins A. Y wins B."
- "the real X is not Y. it's Z."
- "if your X doesn't include Y, it isn't Z. it's W."
- "X is more than Y. it's Z."
- any two-sentence-mirror parallel structure punchlining itself closed
- comma-lists of three or more items in spoken sentences

USE instead:
- specific stories from stories.md when stories_anchor names one
- observer framing when none does ("i've been seeing this pattern", "the failure mode is")
- genuine partial pushback ("yeah, some of this is overblown, but...")
- honest uncertainty ("i don't have a clean answer for this — the messy part is...")
- texture: named tools, named people, specific numbers from research findings (NOT invented)

3d. if bridge_audience is set, write ONE Bridge blurb adapted for that audience.

3e. write ONE X-post per item. under 280 chars. flowing prose. no em-dashes. no punchline parallel structure.

# phase 4 — slack delivery

INTRO MESSAGE (to channel:C0ACVEM27K8):

```
feed digest -- [today's date], [HH:MM CT] (writer stage)

[N] items cleared the bar.

[2-3 sentences in sohail's voice on what's interesting about today's feed. NOT a paraphrase of items. the shape of the conversation. what tension is dominant?]
```

PER ITEM, send a HEADER message (to channel:C0ACVEM27K8):

```
HOOK: [5-12 word opener — strong but NOT a punchline]

tiers: [T1 / T2 / T3 / combinations from digest]
Bridge: [audience or no Bridge]
POV: [anchor or no anchor — generic take]
pillar: [Stack / Frame / Path]

source: [tweet URL]

what's interesting:
[2-4 sentences. the DEEP take. NOT a paraphrase. WHY this matters. the non-obvious angle. grounded in research findings.]

verbatim source quote:
"[short quote from the tweet, max 220 chars — or omit]"

sentiment delta:
[ONE paragraph on dominant reply reaction and disagreement. for STEERING POV, NOT for blurbs to quote verbatim.]

research context:
[2-4 sentences on what tavily / linked URL / your verification surfaced.]

stories.md anchor: [slug or "none — observer mode"]
```

capture the messageId. then send EACH TIER'S BLURB as a thread reply (threadId = header messageId):

```
T[1/2/3] angle:

[flowing prose blurb. no beats. no stage directions. no length cap. sohail's voice. real take with substance. ends with a payoff that is NOT parallel-structure.]
```

then if Bridge blurb exists, send as thread reply.
then send the X-post draft as final thread reply.

if any send fails, log and continue with remaining items.

# phase 5 — mark digest as written

update the digest JSON's `stage2_completed_at` field to the current ISO timestamp. atomic write (.tmp + mv).

# phase 6 — return summary

return plain-text:
(1) digest file processed
(2) items processed
(3) total blurbs generated (T1/T2/T3 counts + Bridge count)
(4) verification calls made (tavily/webfetch/bird-search counts)
(5) any errors

timeout budget: 7200s. take your time on voice — this is the whole point of the writer stage.
STAGE2_EOF

sed -i.bak "s|TAVILY_KEY_PLACEHOLDER|$TAVILY_KEY|" /tmp/feed-writer.txt

# ====================================================================
# Apply stage 1 (update existing feed-highlights-slack)
# ====================================================================
echo "=== updating feed-highlights-slack to be stage 1 (researcher) ==="
echo "  - reverting model to default (Codex)"
echo "  - replacing prompt with research-only version"
node dist/index.js cron edit feed-highlights-slack \
  --message "$(cat /tmp/feed-research.txt)" \
  --model "openai-codex/gpt-5.3-codex" 2>&1 | head -3
echo ""

# ====================================================================
# Create stage 2 (feed-writer-slack)
# ====================================================================
# First check if it already exists (idempotency)
EXISTS=$(node dist/index.js cron list 2>&1 | grep -c "feed-writer-slack" || true)
if [ "$EXISTS" -gt 0 ]; then
  echo "=== feed-writer-slack already exists — updating in place ==="
  node dist/index.js cron edit feed-writer-slack \
    --message "$(cat /tmp/feed-writer.txt)" \
    --model "anthropic/claude-opus-4-7" 2>&1 | head -3
else
  echo "=== creating feed-writer-slack (stage 2) ==="
  node dist/index.js cron add \
    --name "Feed writer (stage 2 — Claude Opus)" \
    --agent content \
    --session isolated \
    --cron "5 8,12,18 * * *" \
    --tz "America/Chicago" \
    --message "$(cat /tmp/feed-writer.txt)" \
    --model "anthropic/claude-opus-4-7" \
    --thinking high \
    --timeout-seconds 7200 \
    --channel slack \
    --to "$FEED_CHANNEL" \
    --best-effort-deliver 2>&1 | head -10
fi

echo ""
echo "=== final state ==="
python3 -c "
import json
d = json.load(open('/Users/sohailmohammad/.openclaw/cron/jobs.json'))
for j in d['jobs']:
    if 'feed' in j['id'] or 'writer' in j['id']:
        if j.get('enabled'):
            p = j.get('payload',{})
            print(f'  {j[\"id\"]:30} model={p.get(\"model\",\"default\")}  schedule={j.get(\"schedule\",{}).get(\"expr\",\"?\")}  size={len(p.get(\"message\",\"\"))} chars')
"
