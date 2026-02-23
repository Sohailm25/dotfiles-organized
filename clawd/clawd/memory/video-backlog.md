# Video Backlog

## How This Works
- Topics start as one-liners in the **Ideas** section
- When you're feeling it, flesh one out into a **Skeleton** (hook + beats + closer)
- Either mode works for recording: grab a topic and stream, or grab a skeleton and riff
- 🔥 = high conviction / would hit well as video

## Ideas — From Published Writings

### Technical Deep Dives (walkthrough / whiteboard style)
- 🔥 RAG at scale: data residency, multi-tenancy, production reliability — the stuff nobody blogs about
- vLLM in production: memory fragmentation, throughput cliffs, quantization accuracy issues
- Ray in production: what dozens of GPUs and 3am pages actually taught me

### Agent/AI Infrastructure (your unique lane)
- 🔥 Writing culture IS agent infrastructure — orgs best positioned for AI aren't the ones with best tooling
- 🔥 Org theory maps to agent orchestration — 3 jobs taught me 3 patterns
- Managing agents: the first time it actually worked (3 weeks into new role)
- Multi-mode AI assistants: how I eliminated context bleeding with Telegram forums

### Frameworks & Mental Models (short-form / punchy)
- 🔥 "Models aren't creative" is a skill issue — yours, not the model's
- Latency-bound vs throughput-bound: the missing dimension nobody talks about
- Sampling everything at the frontier — and when to stop
- Catching yourself in patterns: Slack vs Telegram decision-making trap
- 🔥 Signal vs social-game content: anti-hype filter + learning contract for navigating AI's coming "golden age" without fear

### Philosophy / Personal (stream of consciousness)
- Desire is a contract to be unhappy — Naval's idea in practice
- Integration not oscillation — when ambition and spirituality point the same direction
- Robotics beyond humanoids — what a software engineer learns jumping in

## Ideas — New (not yet written about)

### Format Experiments
- Livestream-style: hit record, answer a viewer question OR do focused work publicly (research, learning, building)
- Series cold-open manifesto: anti-performative, anti-hype framing + "1% better daily" learning contract before each deep-dive episode

- Public proof series: use your research paper as the credibility anchor, then build episodes that translate the work into practical frameworks and decisions in the open

<!-- Drop new topic ideas here -->

## Skeletons (structured improv ready)

### Activation Steering Deep Dive — SOURCE OF TRUTH (locked)
- Canonical doc: `~/clawd/memory/video-sources/activation-steering-deep-dive-source-of-truth-2026-02-23.md`
- Supporting notes: `~/clawd/memory/video-sources/activation-steering-supporting-notes-2026-02-23.txt`
- Reconciliation feedback: `~/clawd/memory/video-sources/activation-steering-reconciliation-feedback-2026-02-23.md`
- Gemini research dump: `~/clawd/memory/video-sources/activation-steering-gemini-research-2026-02-23.csv`
- Gemini source-verification audit: `~/clawd/memory/video-sources/activation-steering-gemini-source-verification-audit-2026-02-23.csv`
- Ground-truth vs Gemini reconciliation: `~/clawd/memory/video-sources/activation-steering-ground-truth-vs-gemini-reconciliation-2026-02-23.md`
- Status: basis for the activation-steering mini-series (6 episodes)
- Note: Use canonical doc as primary source; use supporting notes + reconciliations + Gemini research/audits for updates to framing, episode arc, and cited findings.


### Reusable Intro Variants (anti-hype + learning contract)

**Variant 1 — 20s (concise):**
"Okay, so quick context before we jump in. A lot of AI content right now is hype, social games, or soft B2B outreach disguised as education. Some of it is signal, a lot of it is noise. In this video, we’re going deep on **[topic]** — and by the end, you should be able to **[specific outcome]**."

**Variant 2 — 40s (standard):**
"Okay, so quick acknowledgement before we start. A lot of AI content right now is hype, social games, or soft B2B outreach disguised as information. Some of it is signal, a lot of it is noise. Is this video itself part of that game? Maybe in some way — it’s hard to be fully outside the system. But my intent here is simple: sift through the echo chamber, focus on what’s actually useful, and help you build real understanding for the next few years. I’m Sohail — L5 at Amazon, built production RAG at JPMorgan, architected ML infra at Wendy’s, and I fund my own independent research in mech interp and inference optimization. In this video, we’re going deep on **[topic]** — and by the end, you should be able to **[specific outcome]**."

**Variant 3 — 60s (reflective):**
"Alright, so before we get into today’s topic, I want to set the frame. We live in a cycle right now where AI content is constant — hype threads, performative takes, breaking news every hour, and a lot of social positioning. Some of that is signal. A lot of it is noise. And honestly, if we’re being real, almost all of us are participating in that system in some way. So the goal of this series is not to pretend I’m above it — it’s to be explicit about what I’m trying to do: cut through the echo chamber, focus on durable ideas, and help people build actual understanding. Because at the end of the day, if we can replace fear with clarity and get 1% better each day, that compounds. I’m Sohail — L5 at Amazon, built production RAG at JPMorgan, architected ML infra at Wendy’s, and I fund my own independent research in mech interp and inference optimization. Now, in this one, we’re going deep on **[topic]** — and by the end, you should be able to **[specific outcome]**."

<!-- 
Template:
### [Topic]
**Hook:** (first 15 seconds — why should they care)
**Beats:**
1. ...
2. ...
3. ...
**Closer:** (the takeaway, the "at the end of the day...")
**Visuals:** (optional — diagrams, screen shares, whiteboard moments)
-->

### Nick Saraev-style Deep Technical Series (authentic teaching while learning)
**Hook:** "Okay, so here's the thing: most technical content is either surface-level summaries or over-polished tutorials. I want to go deep, in public, and show real understanding."
**Beats:**
1. Define the lane: deep dives on mechanistic interpretability, inference optimization, and adjacent systems topics (mini-series, not one-offs).
2. Teaching style: Feynman-style explanation (clear, first-principles, no buzzword dumping) without over-emphasizing "I'm still learning" as the headline.
3. Credibility signal: synthesize research + implementation intuition so it feels original, not recycled takes from X/YouTube.
4. Format mechanics: teleprompter-guided talking points + hand-drawn visuals/diagrams + notes aggregated from deep research queries.
5. Brand thesis: merge authenticity + self-awareness + technical rigor into a lane that is unmistakably yours.
**Closer:** "At the end of the day, the goal isn't to look like the smartest person in the room — it's to build real understanding in public, consistently, and let the depth compound."
**Visuals:** whiteboard-style sketches, architecture diagrams, "what people think vs what's actually happening" comparison drawings, mini-series map (Episode 1→N progression).

### 6-Episode Technical Series: Activation Steering in LLMs 🔥
**Series Hook:** "Okay, so if you've heard people say 'we can steer model behavior' but it still feels hand-wavy, this series is going to make that concrete — from geometry intuition to real implementation tradeoffs."
**Series Promise:** By the end, viewers should understand what activation steering is, when it works, when it breaks, and how to reason about it like an engineer (not just a demo poster).

#### Episode 1 — What Activation Steering Actually Is (without the hype)
**Hook:** "Most people explain steering like magic. It's not magic — it's interventions in representation space."
**Beats:**
1. Define terms: activations, residual stream, steering vector, intervention point.
2. Intuition: adding a direction in latent space to bias downstream behavior.
3. Compare to prompting/fine-tuning/RLHF: what layer each method touches.
4. Simple toy example + expected behavior shift.
**Closer:** "At the end of the day, steering is controllability over internal state — not mind control over the model."
**Visuals:** residual stream diagram, vector addition sketch, control-knob metaphor.

#### Episode 2 — The Geometry: Why Directions Encode Behavior
**Hook:** "If the geometry story is fuzzy, steering will always feel like cargo cult."
**Beats:**
1. Representation geometry 101: directions, subspaces, linear probes.
2. How to derive candidate steering vectors (contrast pairs / activation differences).
3. Layer dependence: why same vector behaves differently by depth.
4. Interference + entanglement: why 'truthfulness' can collide with style/verbosity.
**Closer:** "The better your geometric mental model, the less random your steering experiments look."
**Visuals:** 2D projection intuition, layer stack heatmap, overlap/interference sketch.

#### Episode 3 — Hands-On Pipeline: Build a Steering Experiment End-to-End
**Hook:** "Let's stop theorizing and actually build one."
**Beats:**
1. Dataset/task framing for a concrete behavior axis.
2. Collect activations + compute vector.
3. Inject at inference and evaluate behavior deltas.
4. Baselines + ablations: no-steer vs prompt-only vs steer.
5. Common implementation bugs (token alignment, wrong layer, scaling).
**Closer:** "If you can't reproduce your own steering result twice, you don't have a method yet — you have a moment."
**Visuals:** code walkthrough, experiment table, failure-case snippets.

#### Episode 4 — Evaluation: Did We Really Steer, or Did We Just Nudge Style?
**Hook:** "A lot of steering wins are just style transfer in disguise."
**Beats:**
1. Define metrics tied to target behavior (not vibes).
2. Robustness tests across prompts/domains/temperatures.
3. Side-effect audits: capability loss, verbosity drift, refusal spikes.
4. Statistical sanity checks + qualitative review rubric.
**Closer:** "At the end of the day, steering quality = target gain minus collateral damage."
**Visuals:** eval matrix dashboard, before/after response grid, side-effect scorecard.

#### Episode 5 — Limits and Failure Modes in Real Systems
**Hook:** "Where does activation steering break in production? More often than people admit."
**Beats:**
1. Distribution shift and brittle vectors.
2. Multi-objective conflicts (harmlessness vs helpfulness vs specificity).
3. Transfer issues across models/checkpoints.
4. Security/misuse concerns and policy boundaries.
5. Cost/latency implications for deployment.
**Closer:** "Steering is powerful, but it is not a replacement for alignment, eval, or product guardrails."
**Visuals:** failure taxonomy map, reliability curve, tradeoff triangle.

#### Episode 6 — Practical Playbook: When to Use Steering vs Other Levers
**Hook:** "You have four levers: prompt, retrieval, steering, fine-tuning — which one should you pull first?"
**Beats:**
1. Decision framework by constraints (data, latency, risk, controllability).
2. Hybrid stacks: prompt + steering + lightweight adapters.
3. Production checklist: monitoring, rollback, drift detection.
4. Research frontier: non-linear steering, feature disentanglement, automated vector discovery.
**Closer:** "At the end of the day, steering is one instrument in an orchestra — use it deliberately, measure it ruthlessly, and ship with humility."
**Visuals:** decision tree, deployment checklist board, frontier roadmap slide.

## Recorded / Published

<!-- Move topics here after recording -->
