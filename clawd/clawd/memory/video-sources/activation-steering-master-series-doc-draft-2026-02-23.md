# Activation Steering Deep Dive — Master Series Doc (Draft v1, Rigor-Gated)

**Date:** 2026-02-23  
**Status:** Draft for review (built from Keep + Keep-with-Rewording claims only)  
**Scope:** 6-episode mini-series, research-first narrative  
**Rule:** Claims in Hold/Remove bucket are excluded pending primary-source verification.

---

## Method and Evidence Policy (applies to all episodes)

- Tag claims as:
  - **[EMPIRICAL]** directly observed in our experiments
  - **[HYPOTHESIS]** explanation consistent with evidence but not directly proven
  - **[SPECULATION]** forward-looking extrapolation
- Every quantitative claim should map to a paper section/table/figure or to our own experiment artifact.
- All 2025–2026 non-peer-reviewed sources must be labeled *(preprint / under review)* on first mention.
- Avoid certainty inflation: no “monotonic” unless strictly monotonic, no blanket “SOTA” claims.

---

## Series Thesis

Activation steering starts with an elegant geometric intuition — model behaviors can often be moved by adding directions in activation space — but reliability breaks under scale, architecture shifts, and implementation details. This series tracks that arc from clean theory to practical limits and open research.

---

## Episode 1 — The Geometry of Behavior

**One-line thesis:** Behavior can be represented as directions in hidden-state space, enabling inference-time control without retraining.

### Necessary beats
1. **Core intuition**: vector arithmetic in representations (word vectors to LLM internals). **[EMPIRICAL/LITERATURE]**
2. **Foundational lineage**: ActAdd → RepE → ITI → CAA → refusal-direction work. **[LITERATURE]**
3. **Mechanism**: compute contrastive direction, inject at target layer during forward pass. **[LITERATURE]**
4. **Safety relevance**: intervention at inference-time as a controllability tool (not a full alignment substitute). **[LITERATURE]**

### Guardrails for script
- Avoid “this changed everything” language.
- Keep claims tied to cited papers; avoid bringing later speculative geometry here.

### Citations to show
- Turner et al. 2023 (ActAdd) [arXiv:2308.10248]
- Zou et al. 2023 (RepE) [arXiv:2310.01405]
- Li et al. 2023 (ITI) [arXiv:2306.03341]
- Panickssery et al. 2023 (CAA) [arXiv:2312.06681]
- Arditi et al. 2024 [arXiv:2406.11717]

---

## Episode 2 — Extracting the Signal

**One-line thesis:** Direction extraction method and layer choice strongly affect outcomes; simple methods can outperform more complex selection pipelines in our tests.

### Necessary beats
1. **DIM walkthrough** (contrastive activations, mean difference, normalization). **[LITERATURE + EMPIRICAL]**
2. **COSMIC framing** (automated selection strategy around intervention search). **[LITERATURE]**
3. **Our head-to-head findings** at larger scale and why layer selection mattered. **[EMPIRICAL]**
4. **Reproducibility warning**: tooling/protocol details materially affect practical outcomes in our setup. **[EMPIRICAL, scoped]**

### Guardrails for script
- Don’t present COSMIC as a strawman; scope any “wins” to tested setup.
- Phrase tooling effect as observed in our pipeline, not universal law.

### Citations to show
- Arditi et al. 2024 (DIM usage) [arXiv:2406.11717]
- Siu et al. (COSMIC, ACL Findings) [arXiv:2506.00085]
- Fiotto-Kaufman et al. (nnsight) [arXiv:2407.14561]
- Marks & Tegmark 2023 [arXiv:2310.06824] (optional support)

---

## Episode 3 — The Inverse-Scaling Problem

**One-line thesis:** In our experiments, steering reliability degrades with model scale, especially beyond mid-size regimes.

### Necessary beats
1. **Family-wise results** (Qwen and Gemma trends as measured in our study). **[EMPIRICAL]**
2. **Statistical framing** (test choice and effect size where reported). **[EMPIRICAL]**
3. **Three explanatory hypotheses**:
   - distributed representation growth,
   - redundancy in safety pathways,
   - narrower effective intervention window at larger scale. **[HYPOTHESIS]**
4. **Reconciliation with nonlinear results** (e.g., RFM): different method class, different data regime. **[LITERATURE + SYNTHESIS]**

### Guardrails for script
- Use “degrades with scale” (not monotonic).
- Treat frontier extrapolation as conditional speculation only.

### Citations to show
- Elhage et al. 2022 [arXiv:2209.10652]
- Wei et al. 2024 [arXiv:2402.05162] (verify exact % wording before script)
- Beaglehole et al. 2025 [arXiv:2502.03708]

---

## Episode 4 — Architecture as a Gate

**One-line thesis:** Steerability is architecture-dependent under fixed methods; transfer and quantization behavior show geometry alone is not enough.

### Necessary beats
1. **Mistral anomaly in our setup** under matched conditions. **[EMPIRICAL]**
2. **Cross-family transfer weakness in our tested protocol.** **[EMPIRICAL]**
3. **Quantization result**: directional similarity can persist while functional outcomes diverge at scale. **[EMPIRICAL]**
4. **Safety implication**: architecture-specific validation is mandatory.

### Bonus (clearly caveated)
- Cristofano (2026, single-author preprint) as a proposed solution path under a different transfer framework. **[LITERATURE, PREPRINT]**

### Guardrails for script
- Treat “spectral healing” as reported/hypothesized mechanism, not settled universal causality.
- Don’t overgeneralize from one architecture pair.

### Citations to show
- Arditi et al. 2024 [arXiv:2406.11717]
- Dettmers et al. 2022 [arXiv:2208.07339]
- Cristofano 2026 *(preprint, single-author)* [arXiv:2601.16034] (optional caveated mention)

---

## Episode 5 — Sparse Features and Fine-Grained Control (SAE Landscape)

**One-line thesis:** SAEs improve interpretability and intervention granularity, but tradeoffs and maturity gaps remain.

### Necessary beats
1. **Why SAEs**: superposition problem and sparse feature decomposition. **[LITERATURE]**
2. **Method landscape**: SAE-TS, FGAA, and related approaches. **[LITERATURE]**
3. **Tradeoff reality**: refusal improvements can interact with general capability/coherence. **[LITERATURE]**
4. **Bridge to our hypothesis**: larger models may distribute refusal across more features, degrading single-direction control. **[HYPOTHESIS]**

### Guardrails for script
- Avoid “SAE revolution” hype; frame as fast-moving emerging landscape.
- Any benchmark numbers require direct paper table linkage before recording.

### Citations to show
- Templeton et al. (Transformer Circuits)
- Cunningham et al. 2023 [arXiv:2309.08600]
- Chalnev, Siu & Conmy 2024 [arXiv:2411.02193]
- Soo et al. 2025 *(preprint)* [arXiv:2501.09929]
- O’Brien et al. 2024 [arXiv:2411.11296]

---

## Episode 6 — Where Steering Breaks, and What Comes Next

**One-line thesis:** Linear steering has hard limits, but a practical toolchain is emerging for safer, more reliable control.

### Necessary beats
1. **Synthesis of three failure axes**: scale, architecture, tooling. **[EMPIRICAL + SYNTHESIS]**
2. **Methods beyond simple linear single-direction interventions**:
   - nonlinear/feature-based approaches,
   - conditional steering,
   - mechanistic diagnostics. **[LITERATURE]**
3. **Our four testable hypotheses** as community challenge problems. **[HYPOTHESIS/RESEARCH AGENDA]**
4. **Safety framing**: monitoring and intervention must be architecture-aware and evaluation-rigorous.

### Bonus (caveated)
- Jafari NBF/KL indicators *(preprint)* as useful but partial predictors.
- Xiong externalities *(preprint)* as deployment warning.
- Cristofano-style cross-architecture transfer as evidence of possible mitigation routes.

### Guardrails for script
- Explicitly separate “what we measured” vs “what others recently reported.”
- Keep unresolved imported claims out unless verified pre-recording.

### Citations to show
- Beaglehole et al. 2025 [arXiv:2502.03708]
- Postmus & Abreu 2024 [arXiv:2410.16314]
- CAST (ICLR 2025)
- Jafari et al. 2026 *(preprint)* [arXiv:2602.01716]
- Xiong et al. 2026 *(preprint)* [arXiv:2602.04896]

---

## Explicit Exclusions for Draft v1

Excluded pending verification or conflict resolution:
- Random-noise 1–13% compliance number
- “Universal vector 50% on Llama-3.1-70B”
- Unresolved concept-cone venue claims
- ACE/RepIt numeric specifics without full citation table
- Any hard number lacking source anchor in primary text

---

## Pre-Recording Verification Checklist

1. Attach source pointers for every number used in script slides.
2. Confirm Arditi model-count phrasing used on-screen.
3. Confirm wording around COSMIC relation to DIM for methodological accuracy.
4. Confirm all 2025–2026 preprint labels on first mention.
5. Freeze final references list with corrected Cunningham/Bricken attribution.

---

## Short Closer Template for Series

At the end of the day, activation steering is neither pure scalpel nor pure sledgehammer. It is a controllability interface whose reliability depends on scale, architecture, and method. The opportunity now is to make that interface rigorous enough for safety-critical use.
