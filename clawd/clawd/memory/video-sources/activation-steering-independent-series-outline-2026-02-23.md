# Activation Steering Deep Dive — Independent 6-Episode Outline (v1)

Date: 2026-02-23
Intent: literature-first series, independent of any single paper.

## Series Positioning
This series explains activation steering as a field: what works, what breaks, and what is still unresolved.
No episode is anchored to one author/paper; all claims should be evidence-tagged and citation-backed.

---

## Episode 1 — Foundations: Why Steering Works at All
**Thesis:** Many behaviors are linearly accessible in representation space, enabling inference-time interventions.
- Activation-space intuition and residual stream basics
- ActAdd, RepE, ITI, CAA lineage
- Refusal-direction evidence and caveats
- What steering is and is not

## Episode 2 — Extraction Methods and Reproducibility
**Thesis:** Method choice, layer choice, and extraction protocol determine practical steering outcomes.
- DIM and contrastive construction
- COSMIC-style selection/search framing
- Layer depth sensitivity
- Tooling/reproducibility pitfalls and reporting standards

## Episode 3 — Scaling Limits and Nonlinear Alternatives
**Thesis:** Simple linear steering becomes less reliable with scale; nonlinear and multi-component approaches aim to recover control.
- Inverse-scaling evidence across model sizes
- Why scale can fracture single-direction control
- RFM/nonlinear approaches and method-class differences
- What remains unresolved

## Episode 4 — Architecture and Transfer
**Thesis:** Steerability is architecture-conditional; transfer is possible but protocol-dependent.
- Family-specific behavior and architecture effects
- Cross-family transfer: when weak, when improved under specialized mapping
- Quantization interaction and precision-mismatch risks
- Practical guidance for architecture-aware validation

## Episode 5 — Sparse Feature Steering (SAEs)
**Thesis:** SAEs offer finer-grained control and interpretability, but performance/safety tradeoffs remain active research.
- Superposition and sparse dictionaries
- SAE-TS, FGAA, CorrSteer/RSV/CRL as emerging spectrum
- Refusal/capability and coherence tradeoffs
- What to trust today vs what is still under review

## Episode 6 — Safety, Externalities, and Deployment Reality
**Thesis:** Steering is powerful but risky; deployment requires diagnostics, conditional control, and rigorous evaluation.
- Externalities: benign utility steering vs safety margin erosion
- Conditional steering and mechanism-aware gating
- Mechanistic indicators (NBF/KL) for failure prediction
- Open problems + practical deployment checklist

---

## Hard Rules for Scripting
1. No uncited hard numbers.
2. Label publication status (peer-reviewed / preprint / under review).
3. Separate empirical findings from hypotheses and speculation.
4. Keep “paper-specific results” as examples, not narrative spine.
5. Use a single references appendix across all episodes.
