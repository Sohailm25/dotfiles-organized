# sohail's stories canon

<!-- ABOUTME: canonical list of sohail's real war stories, real companies, real numbers. -->
<!-- ABOUTME: contentforge prompts reference this; agents may only draw first-person moments from here. -->

> **Sohail — draft from your essays. Edit freely. Anything I got wrong here propagates into the TikTok scripts, so correct it before the next run. Add stories I missed. Remove ones you don't want surfaced publicly.**

every story below is a real moment with real specifics. the contentforge agents draw all first-person "i did X" claims and all numeric specifics from this file (or from a source tweet/replies). they may NOT invent.

stories are tagged with the POV anchors from guide.md so the agent can pick the right one per tweet.

---

## stack pillar — production / infra

### vllm-qsr-throughput-cliffs
- where: a QSR chain (drive-thru voice ordering), ~2 years
- what: vLLM as the foundation for real-time conversational AI. ran at **sub-1.5s latency** for drive-thru
- specific failure: **KV cache fragmentation cost 30% throughput after 12 hours of uptime.** docs didn't warn.
- the lesson: "throughput cliffs in production are rarely single bottlenecks. it's usually 2-3 subsystems failing simultaneously."
- anchors: `production-only-at-scale`, `latency-vs-throughput`, `deployment-gap-is-the-business`

### ray-jpm-rlhf-ownership-bug
- where: JPM, financial compliance environment
- what: built RLHF clusters
- specific failure: **lost 18 hours of PPO training to a Ray ownership bug**
- the lesson: "Ray is a distributed operating system, not a library. it has operational characteristics, failure modes, and performance cliffs you NEED to understand."
- anchors: `infra-not-library`, `production-only-at-scale`

### ray-enterprise-rag-dpi-disaster
- where: enterprise RAG deployment in a regulated environment
- what: ran Ray in an enterprise network with DPI (deep packet inspection)
- specific failure: DPI mangled internal cluster traffic; debugging chewed weeks
- the lesson: in enterprise, **30-50% of the work is network + compliance + review boards, not the Ray code.**
- anchors: `enterprise-is-a-different-country`, `infra-not-library`

### ray-qsr-kuberay-multi-engine
- where: same QSR (drive-thru), production inference
- what: KubeRay + multi-engine routing across vLLM and SGLang
- the lesson: routing tier needs to know which engine is latency-bound vs throughput-bound. name the regime or every decision is wrong.
- anchors: `latency-vs-throughput`, `infra-not-library`

### latency-vs-throughput-qsr-vs-training
- where: QSR (latency-critical drive-thru, sub-1.5s) vs training clusters (throughput-optimized batch)
- what: same person, opposite tradeoffs
- the lesson: most performance advice implicitly assumes throughput. latency-bound flips every decision: batching hurts, smaller models win, prefetching becomes the lever.
- anchors: `latency-vs-throughput`

---

## path pillar — career arc

### career-arc-jpm-to-together
- arc: **JPM → LeanScale → Amazon → Together AI**
- current: forward deployed engineer at Together AI (just started)
- what: each transition was driven by where the deployment gap was largest, not by title
- the lesson: plans fail. routes change. direction survives.
- anchors: `plans-fail-direction-survives`, `deployment-gap-is-the-business`

### amazon-myhr-jfk-storm
- where: Amazon, NYC storm, while co-owning the MyHR platform
- scale: **MyHR supports 1.5M+ employees globally**
- what: got pinged about a leave-request issue affecting JFK employees; fixed it during the storm
- the lesson: "he who has a why to live can bear almost any how. if the why is real, you can absorb a lot."
- anchors: `responsibility-is-its-own-reward`

### amazon-l5-to-l6-managing-agents
- where: Amazon, **three weeks into the role**
- what: built local per-project directories + OpenCode sessions to manage dual workstreams (an API migration AND a wiki rebuild) in parallel
- the lesson: "this system is a cheat code that lets me punch above my weight. it makes any L5 engineer capable of transitioning to L6."
- anchors: `agents-need-context-not-tools`, `discernment-compounds-faster-than-skill`

### fde-at-together-deployment-gap
- where: Together AI, present day
- the role: forward deployed engineer
- the thesis: the gap between what a model does in a demo and what it sustains in production at a real customer IS the business. FDE is the role whose only job is closing that gap.
- the lesson: "if AI feels underwhelming in the real world, it's not the model. it's the deployment gap. and almost nobody is being trained to close it."
- anchors: `deployment-gap-is-the-business`, `enterprise-is-a-different-country`

### inference-economics-book (in progress)
- what: writing a book on inference economics — TCO traps, vendor evaluation, migration gates, LCPR (Latency / Cost / Privacy / Reliability)
- the angle: there's a calculator SaaS and an advisory layer downstream
- usable as: drip videos pre-launch from work-in-progress concepts
- anchors: `deployment-gap-is-the-business`, `latency-vs-throughput`, `infra-not-library`

---

## cross-domain — healthcare ops / GTM

### medical-assistant-clinical-workflows
- where: earlier life, worked as a medical assistant
- what: prior auth nightmares, patient communication breakdowns, clinical workflows
- the lesson: software people consistently underestimate the operational reality of clinical work. healthcare-ai pilots fail at the workflow seam, not the model.
- anchors: `enterprise-is-a-different-country`, `deployment-gap-is-the-business`
- when to use: any tweet about AI in healthcare, clinical agents, prior auth, medical scribes

---

## frame pillar — aphoristic moments

### research-phase-is-the-creative-work
- context: built systems asking LLMs for novel output
- the realization: the creative work isn't the generation step. it's the research that frames it. models are synthesis engines, not idea generators.
- the line: "constraints enable creativity. they give the model edges to push against."
- anchors: `synthesis-not-creativity`

### models-matching-taste-not-obsession
- context: watched LLMs nail curation, trend prediction, and style matching — things "obviously human"
- the realization: taste is reproducible. multi-year unprompted conviction is not.
- the line: "what are YOU uniquely obsessed with building? that's the edge they can't copy."
- anchors: `obsession-is-the-moat`

### graveyard-visit-presence
- context: graveyard visit clarified that seeking is the game — but the target matters
- the realization: relationships, faith, meaning vs. arbitrary titles
- the line: "death doesn't change your circumstances. it changes your perception. which means the perception was always available."
- anchors: `presence-is-a-choice`, `plans-fail-direction-survives`

### prayer-imagined-future-trap
- context: caught himself rushing through prayer to get back to what he was longing to do — and pre-planning how to post about a moment of presence
- the realization: longing-then-arrival never ends. the contract closes and a new one opens that fast.
- the line: "self-identity lives HERE, in this moment, away from the modifiers of reality."
- anchors: `presence-is-a-choice`

### signing-the-offer-morning-after
- context: signed the offer he'd been chasing for months
- the realization: wife asked how he was doing. already thinking about the next thing. naval was half right — the contract closes and a new one opens that fast.
- the line: "desire is a contract you make with yourself to be unhappy until you have the thing. getting it doesn't cancel the contract."
- anchors: `presence-is-a-choice`

---

## numbers floating without a story (need Sohail to slot)

these specifics appear in essays but the agent didn't capture which story they belong to. flag and edit:

- **$11.4M annual savings** (likely Amazon MyHR? or QSR cost-out?)
- **99.9% uptime over 7 months** (which system?)
- **3x throughput improvement (300 → 900 queries/sec)** (which deployment?)
- **60-second response vs 180-minute baseline** (likely drive-thru voice replacing human ordering?)
- **PGVector's performance degrades past ~5-10M vectors** (which RAG system hit this?)

once slotted into a real story, these become high-credibility specifics. unsourced, the agent treats them as numeric framing only, NOT first-person claims.

---

## rules for the agent reading this file

1. when drafting a TikTok script, find the closest story above by POV anchor + topic.
2. quote real numbers verbatim from this canon. never round, never substitute.
3. attribute the moment correctly: "at the QSR" / "at JPM" / "at Amazon" / "at Together" — do not blur companies.
4. if no story fits, fall back to **generalized framing** — "i've watched teams hit this pattern" — and do NOT invent a specific company or number.
5. if the source tweet itself has a concrete number, you may quote it directly with attribution: "as the tweet notes, 61% token reduction" — but make clear it's the tweet's claim, not sohail's number.
