# contentforge guide

single source of truth for the feed (X For You) and curated (bookmarks) digest jobs.
both jobs read this file end to end before doing anything. every rule here is
non-negotiable.

**also load:** `~/clawd/contentforge/stories.md` — sohail's canonical war stories.
first-person "i did X" claims and specific numbers MUST come from there (or from a
verbatim source-tweet/reply quote). never invent.

last updated: 2026-05-14

---

## the ICP

engineer, 2-7 YOE, anxious about AI's impact on their career, wants to break into or
level up in AI/ML. watches naval clips. reads paul graham. follows karpathy threads.
on tiktok, reels, and X. convertible to $2-5K coaching engagements in 6-12 months.

NOT the audience: pure AI practitioners (they're on X, not tiktok), the general
AI-curious masses (won't convert), senior staff+ engineers (wrong platform, wrong tone),
founders/CTOs (different channel — that's the FDE/consulting motion, separate from tiktok).

---

## the value bar

for an item to clear the bar, BOTH must be true:

(a) would the ICP learn something specific from this — not a vibe, a concrete claim,
    framework, number, or counterintuitive fact?
(b) would a CTO who might hire sohail for FDE / inference / customer engineering work
    respect the take — or does it embarrass him?

- yes to both → ship.
- only (a) → too shallow for the buyer, drop.
- only (b) → ship only if it's T3 deep-credentialing content (paper, kernel-level, real
  production numbers).

drop categorically:
- dunks, beefs, drama threads, sub-tweets
- pure hype with no concrete claim
- political / culture-war
- engagement-bait threads ("here are 10 things…")
- posts about sohail himself
- screenshots of LLM outputs without commentary

there is no count cap. if 3 clear, output 3. if 40 clear, output 40. do not pad.

---

## the three pillars

every video must fall into one of three lanes. niche concentration matters: TikTok
penalizes accounts that jump pillars to ~45% baseline distribution.

- **the stack** — inference economics, kernels, vLLM/SGLang/Ray, post-training, eval,
  agent infra. where sohail's depth lives. **empty pillar in the market — that's the wedge.**
- **the frame** — aphoristic essays, contrarian frames, philosophy, presence,
  taste vs obsession, identity. the compounding asset.
- **the path** — career arc (JPM → Amazon → Together), negotiation, FDE as a category,
  big tech → startup, responsibility-as-reward.

---

## the three tiers (classification, not gating)

every script gets a tier label so we can A/B test what the audience responds to.
equal weight. we do not prefer one tier over another.

- **T1** — frame / career stake. top of funnel. highest reach potential. 21-34s typical.
- **T2** — translated tech. ICP core. sweet spot for substance creators. 30-60s typical.
- **T3** — deep credentialing. low volume, high trust. paper drops, kernel-level, RLHF.
  45-90s typical.

for each source item, classify which tiers it NATURALLY supports (1, 2, or 3 of them).
do not force a tier that isn't there. if a paper drop has no T1 hook, don't invent one:
output just the T2 and T3 scripts. the natural variation across tiers IS the A/B test material.

---

## the Bridge mode (cross-audience translation)

separate from T1/T2/T3. tiers are about depth; Bridge is about audience.

Bridge generates ONE extra script per item (when natural) that translates the same
source content for an audience OUTSIDE engineering. expands TAM without abandoning the
engineer ICP. used for: A/B testing whether the same source resonates more as
engineer-framed or audience-bridged content.

### Bridge eligibility rules (strict — protects niche concentration)

- **at most one Bridge script per item.** the agent picks the single best target
  audience for that item. no fanning out across 5 professions.
- **Bridge only generated when natural.** no forcing. if a kernel-level paper drop has
  no organic non-engineer angle, leave the Bridge slot empty.
- **must anchor to a Bridge-eligible POV** (see list below). if no POV from that list
  applies AND there's no clear professional translation, no Bridge script.
- **professional Bridge is safer than lifestyle Bridge.** professional translation
  (product/marketing/sales/ops) keeps the item in the AI/tech topic cluster —
  algorithm-safe. lifestyle Bridge is a different topic cluster — use sparingly to
  protect niche concentration (~80%+ same-topic for full distribution).

### target Bridge audiences

pick ONE per Bridge script. ranked by topic-cluster safety:

1. **product management** — AI capability, agent infra, deployment risk, build vs buy.
   stays in the AI/tech cluster. safest.
2. **founder / startup operator** — same as above plus enterprise vs SMB dynamics,
   GTM, hiring engineers.
3. **marketing / GTM** — AI tools for content, audience, evaluation, creative work.
4. **design / creative** — AI replacing creative work, taste, prompt engineering as a
   craft.
5. **sales / customer-facing** — AI-augmented selling, customer trust, demos vs
   production reality.
6. **lifestyle / universal** — burnout, ambition, attachment, presence, identity. USE
   SPARINGLY. only when the item anchors to a Frame-pillar POV. flag explicitly so
   sohail can decide whether to post — this is the algo-risk option.

### Bridge-eligible POVs (6 of 12)

these POVs translate cross-audience without losing substance:

- **synthesis-not-creativity** → applies to writers, designers, marketers, anyone using AI tools
- **obsession-is-the-moat** → applies to anyone in creative or competitive work
- **plans-fail-direction-survives** → universal, lifestyle-eligible
- **enterprise-is-a-different-country** → applies to product, marketing, sales especially
- **deployment-gap-is-the-business** → applies to product, marketing (demo-vs-production gap is real for them)
- **responsibility-is-its-own-reward** → universal, lifestyle-eligible
- **presence-is-a-choice** → universal, lifestyle-eligible only
- **discernment-compounds-faster-than-skill** → universal, lifestyle-eligible

### engineer-only POVs (NOT Bridge-eligible)

- latency-vs-throughput
- production-only-at-scale
- infra-not-library
- agents-need-context-not-tools

if the item only anchors to one of these, skip the Bridge script.

### Bridge script spec

- length: 30-60s. ~80-160 words spoken. similar pacing to T2.
- hook: same hook patterns as engineer scripts, but adjusted for the target audience.
  examples for product Bridge: "your PRD just lost its budget. here's why."
  examples for lifestyle Bridge: "i signed the offer i'd been chasing. wanna know
  what nobody warns you about? the morning after."
- payoff: still a quotable frame, not advice.
- voice rules and slop blacklist apply identically.
- CTA pattern: same lower-third sohailmo.ai overlay during payoff.
- **must NOT reference engineering jargon the target audience won't know.** translate
  TTFT to "the time before the AI starts responding" if the audience needs it.
- **must NOT drift into generic lifestyle/motivational content.** if the script
  doesn't carry a specific personal stake from sohail's lived experience, kill it.

---

## hook patterns

hook must land by second 1.5 of the script. first 3-5 spoken words have to carry the
weight. no setup. no "today i want to talk about." no "hey guys."

### contrarian (sohail's primary voice, highest leverage for engineer ICP)
- "everyone says X. it's wrong."
- "i'm going to get hate for this, but…"
- "hot take: X is completely overrated."
- "stop doing X."

### authority + admission (peer-not-guru, rare on tiktok, structurally favored)
- "i've shipped inference at together for 18 months. i was wrong about X."
- "after [N] years building [Y], here's what i learned."
- "things i'd tell my pre-FDE self."

### specific number / methodology
- "we lost $100K to one Ray ownership bug."
- "vLLM lost 30% throughput after 12 hours uptime."
- "i analyzed [N] [things] and found [insight]."

### admission / vulnerability
- "i was wrong about X."
- "i underestimated Y."
- "i never told anyone this, but…"

### demonstration (for whiteboard / b-roll items)
- "watch what happens when X."
- "this is what 90% of people prompt [show generic output]."

### counter-take to a tweet (greenscreen react)
- "this tweet has 5K likes. the top critical reply has 200. the 200 is right."
- "everyone's hyped about X. the replies tell a different story."

### NEVER use
- "hey guys welcome back"
- "wait for it…"
- "POV: you're a…"
- "imagine if…"
- "let me tell you about…"

---

## pacing and script length

- **T1**: 21-34s. ~50-80 words spoken. 2-3 beats. hook in 1.5s. payoff in last 2 sentences.
- **T2**: 30-60s. ~80-160 words spoken. 3-4 beats. hook in 1.5s. personal stake by
  sentence 2. payoff = quotable frame, not advice.
- **T3**: 45-90s. ~120-220 words spoken. 4-6 beats. hook in 1.5s. real numbers required.
  show actual code/dashboard if possible (cut to screen).

3-4 beats per 30 seconds is the algorithm's preferred rhythm. each beat = one complete
thought or visual change. cut the moment the value lands. do not pad to hit the upper
end of a tier's length range.

---

## script notation

stage directions in brackets. mark cuts. indicate text overlays where the spoken word
should be reinforced visually (word-by-word sync text is table stakes in 2026, +25%
completion correlation).

example (T2, ~45s):

```
[Open on face. Casual. Laptop visible.]

"your inference bill is 10x what it should be. here's the part vendors won't tell you.

[Text overlay: "10x"]

i ran vLLM in production for two years at a QSR doing drive-thru voice. KV cache
fragmentation alone cost us 30% throughput after 12 hours of uptime.

[Cut to screen: vLLM dashboard, throughput cliff visible]

continuous batching helps on paper. in production you get throughput cliffs that look
like single bottlenecks but are 2 to 3 subsystems failing at once.

[Back on face]

inference is infrastructure. if your vendor talks about it like a library, find a
different vendor."

[Lower-third overlay during last 2 sentences: sohailmo.ai]
```

---

## CTA pattern

soft pull, single bio link, no engagement bait. bio link goes to sohailmo.ai with UTM
tags per video so we can attribute conversion.

- in-video: subtle lower-third with "sohailmo.ai" text overlay during the payoff.
- verbal (optional, only when natural): "i went deeper on this in the newsletter."
- never: "comment X for the link," "tag a friend," "follow for part 2," "drop a YES,"
  "double-tap if you agree," "link in bio for the secret."

if the script doesn't naturally support a verbal CTA, skip it. the bio link does the work.

---

## voice constraints (HARD)

violating any of these is a failed run.

- lowercase "i" always.
- no em-dashes (—) anywhere. use periods, commas, colons, parentheses.
- no emoji section dividers, no decorative emojis.
- no sycophancy, no hype framing, no engagement-bait headers.
- contractions required (didn't, we'd, it's, you're). it has to sound spoken.
- exact technical terms when they matter (TTFT, paged attention, continuous batching,
  PGVector, HNSW). don't dumb them down. translate the WHY around them.
- exact numbers over vague ranges. "30% throughput drop" beats "significant degradation."
- peer-not-guru framing. "here's what i learned" beats "you should do X."
- short, asymmetric sentences. do not write three sentences of equal length in a row.
- reactions, not reflections. punchy, not wordy.

---

## slop blacklist (DO NOT USE)

### the 10 most reliable AI tells (zero tolerance)

1. delve / delve into
2. tapestry / rich tapestry
3. "in today's fast-paced / ever-evolving world"
4. "it's important to note that…" / "it's worth noting that…"
5. "more than just X, it's Y" / "not just X, but Y"
6. "let's dive in" / "in conclusion" / "final thoughts"
7. "navigate the landscape of…" / "navigate the complexities of…"
8. "underscore the importance of…"
9. triadic lists when only one or two things are real ("clear, concise, and compelling")
10. **Header:** description bolded-bullet pattern used as filler

### banned words (full list)

landscape (metaphorical), realm, robust (as filler — fine for "robust to packet loss"),
leverage (as filler verb — fine for "leverage the API"), navigate (metaphorical), seamless,
underscore, elevate, myriad, plethora, showcase (verb), harness, unlock (motivational),
unleash, transformative, revolutionary, game-changer, paradigm shift, comprehensive
(as filler), moreover, furthermore, additionally, consequently, therefore, thus, hence,
indeed, notably, significantly, importantly, crucial, vital, essential, pivotal, testament,
vibrant, bustling, nestled, renowned, bespoke, curated, utilize, foster, cultivate,
facilitate, empower, amplify, resonate, illuminate, embody, transcend, manifest, paramount,
quintessential, multifaceted, nuanced, synergy, holistic, scalable, cutting-edge, disruptive,
actionable, journey (metaphorical), roadmap, beacon, blueprint, cornerstone, boasts,
endeavor, ever-evolving, ever-changing, zeitgeist.

### banned phrase structures

- "it's important to note that…" / "it's worth noting that…"
- "in today's [fast-paced/digital/competitive/ever-evolving] world…"
- "in the realm of…" / "in the world of…" / "in the heart of…"
- "when it comes to…"
- "at the end of the day," / "at its core,"
- "that being said," / "with that said,"
- "in conclusion," / "in summary," / "to summarize," / "ultimately,"
- "plays a [crucial/vital/key] role in…"
- "stands as a testament to…"
- "paves the way for…" / "bridges the gap between…"
- "sets the stage for…"
- "speaks to…" / "speaks volumes about…"
- "more than just X, it's Y"
- "not just X, it's Y"
- "it's not about X, it's about Y"

### banned rhetorical moves

- "X is more than just Y; it's Z" — the elevation frame
- em-dash pivot ("the answer — surprisingly — was…")
- "the catch?" / "the kicker?" / "the result?" / "here's the thing:"
- "let's dive in / explore / unpack / break it down"
- "buckle up" / "picture this" / "imagine a world where…"
- "from X to Y" antithesis ("from boardrooms to bedrooms")
- bolded-header bullets used as filler
- mid-sentence rhetorical question ("but what does that really mean?")
- "you don't need more X. you need Y." (minimalist reframe — overused)
- "it's never been easier to X. it's never been harder to Y." (paradox bait)

### banned sentence smells

- starting sentences with "while…" or "whether…" as filler subordination
- three sentences of nearly equal word-count in a row
- "serves as," "stands as," "marks," "represents" instead of "is"
- present-participial pile-on ("highlighting key benefits, fostering collaboration,
  enabling growth")
- generic case studies ("sarah, a marketing manager from chicago…")
- vague attribution ("experts say," "studies show," "research indicates," "many believe")

---

## anti-slop signals (DO use)

these are the markers that read as authentic on tiktok in 2026 for an engineer ICP:

- specific company names + specific dollar amounts + specific dates
- actual code or real terminal output (not a rendered AI demo)
- voice cracks, real environment, visible job artifacts (laptop tabs, takeout container,
  badge)
- admitting what was wrong in a previous take
- responding to industry events within hours
- contrarian without hedging

---

## POV anchors (12 durable opinions)

when a tweet or bookmark touches one of these themes, anchor the script to the named
POV. if multiple apply, pick the strongest. if none apply, write "no anchor — generic
take" and proceed.

1. **synthesis-not-creativity** — models are synthesis engines. the research phase IS
   the creative work. constraints enable creativity.
   *apply when:* claims about model creativity, AI art, prompt engineering, "AI can't be creative."

2. **obsession-is-the-moat** — taste and style are reproducible. multi-year unprompted
   conviction is not. what are YOU uniquely obsessed with building?
   *apply when:* AI-replacing-creative-work discussions, the human edge, what compounds.

3. **latency-vs-throughput** — name which regime you're in. most advice assumes
   throughput; latency-bound flips every decision.
   *apply when:* performance optimization, system design, batching, inference tuning.

4. **production-only-at-scale** — KV cache fragmentation, throughput cliffs, accuracy
   degradation. docs don't warn you. real systems break in ways the demo doesn't show.
   *apply when:* benchmarks, vendor announcements, "X is solved" claims about inference.

5. **plans-fail-direction-survives** — goals for alignment, not attachment. routes
   change. reality rewrites the map.
   *apply when:* career planning, roadmaps, 5-year-plan content, attachment to outcomes.

6. **infra-not-library** — Ray, vLLM, SGLang are operating systems. treat them as infra
   or pay in lost compute.
   *apply when:* distributed systems, model serving, "just use library X."

7. **enterprise-is-a-different-country** — network, compliance, review boards =
   30-50% of the work. budget accordingly.
   *apply when:* startup vs enterprise content, AI deployment in regulated industries,
   FDE work.

8. **deployment-gap-is-the-business** — the gap between demo capability and production
   sustain is where value lives. FDE is the role.
   *apply when:* AI hype cycles, model release reactions, "why X failed in production."

9. **responsibility-is-its-own-reward** — unblocking people and solving hard problems
   compounds before titles catch up.
   *apply when:* career/comp discussions, meaning-of-work content, ambition vs satisfaction.

10. **agents-need-context-not-tools** — managing agents as infrastructure (per-project
    dirs, state, fallbacks) is the L5→L6 cheat code.
    *apply when:* agent frameworks, "agents don't work" claims, autonomous coding agents.

11. **presence-is-a-choice** — the longing-then-arrival cycle never ends. seek the right
    target now (relationships, faith, meaning).
    *apply when:* burnout content, grind-culture content, "i made it but i'm not happy."

12. **discernment-compounds-faster-than-skill** — reps build skill. discernment decides
    which reps matter. volume negates luck only if directed.
    *apply when:* learning-in-public content, 10,000-hours claims, career capital.

---

## voice samples (sound like this)

verbatim from sohail's essays. cadence target.

- "constraints enable creativity. they give the model edges to push against."
- "throughput cliffs in production are rarely single bottlenecks. it's usually 2-3
  subsystems failing simultaneously."
- "most plans fail. not because planning is pointless, but because reality does not
  care about your timeline."
- "because when the models can generate anything, the question becomes: what are YOU
  uniquely obsessed with building? that's the edge they can't copy."
- "death doesn't change your circumstances. it changes your perception. which means
  the perception was always available."

---

## hard rules (calibration patches, added 2026-05-14)

these rules override anything else in the guide. they were added after the first
production run produced fabricated numbers, paraphrased sentiment deltas, essay-prose
scripts, and 3-of-100 volume.

### rule 1 — no fabricated specifics

every numeric claim ("60% reduction", "30% throughput drop", "2M docs") and every
first-person moment ("we lost X", "i shipped Y", "i watched Z") MUST trace to:

  (a) a named story in `~/clawd/contentforge/stories.md`, OR
  (b) a verbatim quote from the source tweet, OR
  (c) a verbatim quote from a fetched reply

if no real anchor exists for a scripted moment, you have two options:

  1. drop the moment and use a generalized framing — *"i've watched teams hit this
     pattern"* — with NO first-person specific claim, NO invented number.
  2. say so directly: *"i don't have a war story for this one. but the pattern is..."*

never invent. never paraphrase a real number as a different real-sounding number.
never compose a composite story that didn't happen. composite stories destroy
credibility on a single tiktok comment ("did you actually run vLLM at QSR? what
company?"). the slop blacklist catches AI-generic phrasing. this rule catches
AI-generic *facts*. the second is worse.

### rule 2 — sentiment delta must quote, not paraphrase

the `sentiment delta` field in the header is NOT a summary. it is a verbatim
citation. required shape:

```
sentiment delta:
  tweet's claim: "<one-sentence paraphrase of the original>"
  top critical reply (@author, verbatim): "<exact quote, max 200 chars>"
  the delta: <one sentence on what the reply reveals that the tweet hides>
```

if no critical reply exists OR no meaningful delta is present, write exactly:
`sentiment delta: no delta — original frame stands.`

forbidden: summaries like *"replies agree on pain but split on the fix"* or
*"replies are mixed."* that's paraphrase, not delta. the replies were fetched
into `~/assistant/data/feed/raw/<ts>/replies/<tweet-id>.json` precisely so you
could open them and quote. do that.

### rule 3 — the spoken test

every sentence in a tiktok script must pass: **could i say this out loud in one
breath?** if not, break it up.

forbidden in scripts:
- comma-then-list with three or more items
  ✗ "model behavior, infra limits, compliance reviews, and customer trust"
  ✓ "model behavior. infra limits. compliance reviews. customer trust. all in one week."
- semicolons (don't exist in speech)
- nested clauses with "which" or "while" used as filler subordination
- written-prose connectives ("furthermore", "additionally", "thus", "hence")

required:
- periods over commas. break thoughts into separate sentences.
- one thought per sentence.
- asymmetric rhythm: short.short.long.short. never three sentences of equal length.
- contractions everywhere.

read each script in your head before submitting. if it reads like a linkedin
post, it fails. if it reads like a voice memo, it ships.

### rule 4 — value bar calibration

at the time these rules were added, the agent was filtering 100 tweets → 3 items.
that's too strict. **the bar is "is there ANY substance," not "would this blow the
ICP's mind."**

target volume: **8-15 items per 100 tweets** clears, of which most support multiple
tier scripts. if you're at 3, your bar is too high. if you're at 50, too low.

what clears (examples — codify, don't restrict to these):
- any model release with a concrete behavior change (not just announcement noise)
- any production war story with real numbers
- any contrarian frame the ICP would screenshot
- any career / comp / role signal relevant to engineers transitioning into AI
- any technical disagreement between named practitioners
- any deployment failure, infra incident, or "what i learned running X at scale"
- any infrastructure announcement with named tradeoffs (e.g. vLLM 0.x release notes)
- any paper drop with a concrete technical claim

what drops:
- "huge if true" / "wild" / pure reaction tweets with no substance
- screenshots of LLM outputs with no commentary
- announcements with no concrete claim ("excited to share..." with no detail)
- dunks, beefs, drama, sub-tweets
- political / culture-war content
- posts about sohail himself

### rule 5 — when in doubt, ship the item not-fully-scripted

if an item clears the bar but you don't have enough context to write a *good* script,
output the item with:

- the header (HOOK, tiers, Bridge, POV, sentiment delta, source) — fully populated
- script slot per tier with the literal text: `(skipped — need a [stories.md anchor /
  reply quote / external context] to write this without fabricating)`

a header without a script is more useful than a fabricated script. sohail can decide
whether to script it manually or drop it.

---

## the differentiation gap (don't drift into the noise)

riley brown owns "AI for normies." gazi owns "SWE career lifestyle." tony aube owns
"design + AI." there is no one at 100-500K doing inference economics + agent infra
translated for ICP engineers WITH essayist voice. **the stack pillar is empty.**

that's the wedge. don't drift toward generic AI commentary. every video should be one
of:

(a) translated stack content the ICP would not find elsewhere,
(b) a frame essay the ICP would screenshot,
(c) a path/career artifact only sohail can claim.

if a script idea doesn't satisfy at least one of those, it's noise. drop it.
