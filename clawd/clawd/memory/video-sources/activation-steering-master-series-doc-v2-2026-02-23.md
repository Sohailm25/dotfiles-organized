# Activation Steering Deep Dive — Master Series Doc (v2 Final-Candidate)

**Date:** 2026-02-23  
**Status:** Final-candidate for recording prep  
**Built from:** rigor-gated claim ledger (Keep + Keep-with-Rewording only)

---

## 0) Operating Standard (Truth-First)

- Tag each substantive claim in prep notes/slides as:
  - **[EMPIRICAL]** observed in our experiments
  - **[HYPOTHESIS]** plausible explanation not directly proven
  - **[SPECULATION]** extrapolation beyond current evidence
- All 2025–2026 non-peer-reviewed work gets **(preprint / under review)** on first mention.
- No unverified hard numbers from HOLD bucket.
- No “monotonic” wording unless strictly monotonic.

---

## 1) Series Arc (Locked)

1. **Geometry of behavior** (clean story)
2. **Signal extraction** (method + layer + tooling)
3. **Scale breakdown** (inverse-scaling behavior)
4. **Architecture gate** (Mistral/transfer/quantization)
5. **SAE landscape** (finer control + tradeoffs)
6. **What breaks + what’s next** (toolchain + open hypotheses)

Core narrative style: literature baseline → our results → honest uncertainty.

---

## 2) Episode-by-Episode (Structured Improv Talk-Track)

## Episode 1 — The Geometry of Behavior

**Thesis:** Steering works because behavior is often linearly accessible in representation space.

**Hook (first ~20s):**
“Okay, so here’s the clean version of the story: if behavior lives as a direction in activation space, you can shift behavior by adding that direction — without retraining the model.”

**Talk-track beats (riff-friendly):**
1. Define terms quickly: residual stream, steering vector, intervention layer.
2. Historical lineage in one pass: ActAdd → RepE → ITI → CAA → refusal-direction work.
3. Show one concrete before/after output pair (same prompt, vector on/off).
4. State the promise clearly: inference-time control is fast and cheap.
5. Tease the rest of series: existence is one thing, reliability is another.

**Closer:**
“At the end of the day, Episode 1 is the beautiful geometry story. The next five are about where reality pushes back.”

**Optional visuals:** residual stream diagram, vector addition overlay, timeline of foundational papers.

---

## Episode 2 — Extracting the Signal

**Thesis:** Extraction and layer selection determine outcomes more than people expect.

**Hook:**
“Now here’s where it gets interesting: two people can both say ‘we did activation steering’ and get opposite outcomes because they extracted different directions at different layers.”

**Talk-track beats:**
1. DIM in plain language (contrast sets → mean difference → normalize).
2. COSMIC in plain language (automated search/selection framing).
3. Present your head-to-head result from your table (with exact setup scope).
4. Explain layer-depth failure case at larger scale.
5. Reproducibility point: tooling/protocol details can dominate practical outcome in your setup.

**Closer:**
“At the end of the day, this isn’t just ‘find a vector.’ It’s methodology + layer + implementation discipline.”

**Optional visuals:** DIM animation, layer sweep chart, extraction-pipeline checklist.

---

## Episode 3 — The Inverse-Scaling Problem

**Thesis:** In your experiments, steering reliability degrades with model scale.

**Hook:**
“If you expected bigger models to be easier to control because they’re ‘smarter,’ your data says the opposite for simple linear steering.”

**Talk-track beats:**
1. Walk Qwen/Gemma family results exactly as measured.
2. Show stats and effect-size framing (no hype).
3. Three hypotheses:
   - distributed representation growth,
   - pathway redundancy,
   - narrowing effective intervention window.
4. Reconcile with nonlinear literature (different method class, different data regime).
5. Keep extrapolation cautious.

**Closer:**
“At the end of the day, scale changes the geometry enough that simple single-direction control starts to lose reliability.”

**Optional visuals:** inverse-scaling curve, multiplier-window chart, hypothesis cards.

---

## Episode 4 — Architecture as a Gate

**Thesis:** Method portability is architecture-dependent under fixed protocols.

**Hook:**
“Same setup, same intent, completely different outcome — that’s the architecture story.”

**Talk-track beats:**
1. Mistral anomaly under matched conditions.
2. Cross-family transfer weakness in your protocol.
3. Quantization finding: direction may look preserved while behavior isn’t.
4. Why this matters operationally: per-architecture validation is non-negotiable.
5. Optional caveated update: Cristofano suggests a transfer framework that may mitigate some architecture barriers.

**Closer:**
“At the end of the day, steerability is not a universal constant. It’s architecture- and pipeline-conditional.”

**Optional visuals:** side-by-side outputs, transfer matrix, quantized-vs-fp behavior chart.

---

## Episode 5 — Sparse Features and Fine-Grained Control

**Thesis:** SAEs increase interpretability and control granularity, but the field is still maturing.

**Hook:**
“If single dense directions get brittle at scale, the obvious next move is to decompose into sparse features and steer with more precision.”

**Talk-track beats:**
1. Superposition problem and why SAEs matter.
2. Brief method map: SAE-TS, FGAA, related feature-targeted approaches.
3. Tradeoff discussion: refusal-control gains can interact with capability/coherence.
4. Connect back to your hypothesis: larger models may spread refusal across more features.
5. Keep confidence calibrated (many methods are recent preprints).

**Closer:**
“At the end of the day, SAEs are a promising control interface — but still an engineering frontier, not a solved stack.”

**Optional visuals:** SAE architecture, feature activation strips, tradeoff matrix.

---

## Episode 6 — Where Steering Breaks, and What Comes Next

**Thesis:** Linear steering has limits; a practical reliability stack is emerging.

**Hook:**
“We started with one direction controlling one behavior. We end with a much messier, more useful truth: steering works — conditionally.”

**Talk-track beats:**
1. Synthesize the three core breakpoints: scale, architecture, tooling.
2. Methods pushing past limits: nonlinear/feature-based/conditional/diagnostic.
3. Present your four testable hypotheses as community challenges.
4. Safety framing for deployment: architecture-aware monitoring + strict evaluation.
5. Distinguish clearly what is measured vs what is still hypothesis.

**Closer:**
“At the end of the day, steering is neither pure scalpel nor pure sledgehammer — it’s a controllability interface that only becomes safe when rigor catches up to capability.”

**Optional visuals:** known-vs-unknown board, toolchain stack, hypothesis cards.

---

## 3) Recording-Safe Language Constraints

- Prefer: “in our experiments,” “under this setup,” “we observed.”
- Avoid: “always,” “proves universally,” “definitively solves.”
- If citing a preprint, say it once in-line: “(preprint, not yet peer-reviewed).”
- If claims differ across papers, say so explicitly.

---

## 4) Quantitative Claim Mapping Appendix (Recording Confidence Table)

> Use this table as the pre-recording checklist. If Source Anchor is missing, do not use the number on camera.

| ID | Quantitative Claim (Draft-safe wording) | Status | Source Anchor Required Before Recording |
|---|---|---|---|
| Q1 | Qwen-family steering reliability declines by larger sizes in our dataset | Draft-safe | Source-of-truth doc + underlying experiment table/figure reference |
| Q2 | Gemma large-scale failure under tested setup (coherence collapse) | Draft-safe with setup qualifier | Source-of-truth doc + exact sample size reference |
| Q3 | DIM vs COSMIC large-scale delta in our comparison | Draft-safe with protocol scope | Source-of-truth doc Table reference (exact test + p-value link) |
| Q4 | COSMIC-selected deeper layer underperformed empirically selected mid-depth layer at 32B | Draft-safe | Source-of-truth layer sweep/table reference |
| Q5 | Tooling/protocol switch correlated with large effectiveness swing in our setup | Draft-safe with strict scope | Internal experiment note + reproducibility appendix reference |
| Q6 | Transfer efficiency asymmetry (within-family stronger than cross-family in our protocol) | Draft-safe with scope | Source-of-truth transfer table reference |
| Q7 | Quantization: high directional similarity can coexist with weaker functional steering at larger scale | Draft-safe | Source-of-truth quantization section/table |
| Q8 | Jafari NBF explains roughly half variance (R² ~0.47–0.54) | Preprint-caveated | arXiv:2602.01716 + section/table pointer |
| Q9 | Xiong externalities: benign steering can sharply increase ASR under adaptive attacks | Preprint-caveated qualitative | arXiv:2602.04896 + figure/table pointer |
| Q10 | Cristofano reports major refusal-rate reduction with <1% perplexity degradation under transfer method | Preprint-caveated | arXiv:2601.16034 + exact table/figure pointer |

### Excluded Quant Claims (until verified)
- Random-noise 1–13% harmful compliance
- Universal-vector 50% on Llama-3.1-70B
- Any unresolved concept-cone/ACE/RepIt hard numbers without stable bibliographic chain

---

## 5) Citation Status Notes (on-screen discipline)

- **Peer-reviewed / stronger anchors:** ActAdd, RepE, Arditi, CAST, COSMIC.
- **Preprint anchors (must label):** Jafari 2026, Xiong 2026, Cristofano 2026, FGAA (if unpublished at record time), CRL.
- **Attribution fix locked:** arXiv:2309.08600 = Cunningham et al. (not Bricken).

---

## 6) Final Go/No-Go Before Recording

**Go if all true:**
1. Every hard number in slides maps to a table/figure/section.
2. Every preprint is labeled once on first mention.
3. Hold-bucket claims are absent.
4. Episode structure matches locked 6-episode research arc.

If any fail: revise before filming.
