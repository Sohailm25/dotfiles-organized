# Activation Steering Deep Dive — Independent 6-Episode Series (No-Paper Basis)

Date: 2026-02-23
Constraint: This series is fully independent of your paper and does not use your paper’s findings as narrative backbone or evidence base.
Source basis for this draft: Gemini audit/research dumps + Claude rigor audit + prior reconciliation notes.

---

## Series Thesis
Activation steering is best understood as a controllability stack, not a single trick: representation geometry, extraction methods, architecture constraints, sparse-feature control, and deployment safety all interact.

---

## Episode 1 — Foundations: Activation Steering 101 (Without the Hype)
**Thesis:** Steering modifies internal model states at inference-time; this can shift behavior without retraining.

**Hook:**
“Most people treat activation steering like magic. It’s not magic — it’s state intervention in representation space.”

**Beats:**
1. Define terms: activation, residual stream, steering vector, intervention layer.
2. Foundational lineage: ActAdd, RepE, ITI, CAA.
3. Refusal-direction framing from literature (with caveats on generality).
4. What steering can do vs what it cannot replace (it is not full alignment).

**Closer:**
“At the end of the day, steering is controllability — useful, fast, and limited.”

---

## Episode 2 — Extraction: DIM, Search, and Reproducibility
**Thesis:** Extraction quality is the difference between a clean intervention and noisy behavior shifts.

**Hook:**
“People argue about steering effectiveness, but half the disagreement is actually extraction and protocol disagreement.”

**Beats:**
1. DIM pipeline and contrastive design.
2. COSMIC-style selection/search framing (position as selection strategy, not separate ontology of concept extraction).
3. Layer sensitivity and depth sweeps.
4. Reproducibility discipline: tool versioning, seeds, prompt sets, exact eval rubric.
5. Reporting standard for fair comparisons.

**Closer:**
“At the end of the day, if your extraction pipeline is sloppy, your conclusions are noise.”

---

## Episode 3 — Scaling and Method-Class Transitions
**Thesis:** Linear single-direction steering appears brittle in larger/complex regimes; nonlinear and multi-component methods are active alternatives.

**Hook:**
“The bigger the model, the less likely simple static steering gives you stable behavior control.”

**Beats:**
1. Survey inverse-scaling concerns in current literature.
2. Why linear directions may degrade with increased representational complexity.
3. Nonlinear alternatives (e.g., RFM) and what they change operationally.
4. What to test before claiming a method ‘fails’ at scale.

**Closer:**
“At the end of the day, scale changes the method class you need — not just the hyperparameters.”

---

## Episode 4 — Architecture, Transfer, and Quantization
**Thesis:** Steering outcomes are architecture- and precision-dependent; transfer works only under the right mapping assumptions.

**Hook:**
“Same steering idea, different architecture, opposite outcome — that’s not a bug, that’s the point.”

**Beats:**
1. Architecture-conditioned behavior (attention design, residual dynamics).
2. Cross-family transfer: weak under naive transfer, stronger under specialized alignment protocols (caveated preprint evidence).
3. Quantization interaction: why precision mismatch can break practical steering.
4. Deployment rule: validate per architecture, per precision.

**Closer:**
“At the end of the day, there is no universal steering recipe that ignores architecture and precision.”

---

## Episode 5 — Sparse Feature Steering (SAE Landscape)
**Thesis:** SAEs provide finer-grained, interpretable intervention handles, but the field is still rapidly evolving.

**Hook:**
“If dense vectors are blunt control, SAEs are trying to give us a surgical instrument panel.”

**Beats:**
1. Superposition and why sparse dictionaries matter.
2. Method map: SAE-TS, FGAA, CorrSteer, SAE-RSV, CRL (status-labeled).
3. Key tension: interpretability vs steerability vs coherence.
4. Practical guidance: what is mature enough to trust now.

**Closer:**
“At the end of the day, SAEs are promising — but this is still frontier engineering, not settled doctrine.”

---

## Episode 6 — Safety Externalities and Deployment Playbook
**Thesis:** Steering can improve utility while weakening safety margins; safe deployment needs conditional control + diagnostics + adversarial evaluation.

**Hook:**
“The uncomfortable truth: even benign steering goals can unintentionally increase jailbreak risk.”

**Beats:**
1. Externalities framing (safety-margin erosion risks).
2. Conditional steering (apply control when activation context warrants it).
3. Mechanistic indicators for runtime confidence/failure detection (e.g., NBF/KL-style diagnostics).
4. Practical deployment checklist: test matrix, rollback plan, architecture/precision audits, preprint caveats.

**Closer:**
“At the end of the day, steering is only production-ready when monitoring and safety evaluation are first-class.”

---

## Cross-Episode Rules
1. No claims sourced from your paper.
2. No uncited hard numbers in script unless primary source is attached and quoted.
3. Mark every 2025–2026 preprint explicitly.
4. Separate empirical claims from hypotheses and speculative interpretation.
5. Keep focus on field consensus, disagreements, and open problems.

---

## Citation Policy (for drafting phase)
- Use only literature-backed references.
- If a claim is from single-author preprint / under review / informal post, label it.
- If source status is unresolved, move claim to bonus or remove.
