# Activation Steering Series — Ground Truth vs Gemini Reconciliation (2026-02-23)

Source: Slack #contentforge-video (message id: 1771828996.446619)

## New material that materially changes the series

1. **Cristofano (Jan 2026) — Universal Refusal Circuits Across LLMs** (arXiv:2601.16034)
   - Dynamic Time Warping on atom Gram fingerprints aligns donor/target layers.
   - “Weight-SVD stability guard” projects transferred intervention into target semantic null-space, away from high-variance principal weight subspaces.
   - Reported result: Mistral refusal rate 0.98 → 0.02 without perplexity degradation.
   - Transfer demonstrated across dense-to-MoE (Qwen3-8B → GPT-OSS-20B).
   - Implication: Mistral anomaly is likely solvable engineering, not a hard impossibility.

2. **Mistral spectral healing mechanism**
   - SWA treats persistent bias as local anomaly and attenuates it across windows.
   - Coherence discriminative signal in late-layer smoothness; early/mid injections get neutralized before unembedding.

3. **Concept cones**
   - Refusal represented as bounded conical region (not just single direction).
   - Linear moves can remain inside cone and preserve behavior; boundary-crossing becomes the real objective.

4. **Affine Concept Editing (ACE)**
   - DIM + affine reference projection to move hidden state outside refusal cone while preserving semantics.

5. **Quantization recalibration mandate**
   - FP16-extracted vectors should not be naively reused in INT4 environments.
   - Prescription: extraction and intervention in same precision environment.

6. **QwQ-32B reasoning steering fragmentation**
   - Only ~10.2% tokens steered overall.
   - Phase-dependent steering efficacy (e.g., different rates across numeric computation vs equation recall phases).

7. **Jafari et al. metrics**
   - NBF explains R² ≈ 0.47–0.54 of steering success variance.
   - Failures show attention disruption at intervention+1 layer.

8. **Steering externalities concrete numbers**
   - Example: Layer 30 classification boundary crossing 60.8% for harmful prompts under compliance steering.
   - ASR rises to 80–90% under adaptive black-box attacks (PAIR/CoP/TAP).

---

## Episode-level updates

### Episode 1
- Add concept cones as an early preview to complicate the “direction-only” geometry story.

### Episode 2
- Add ACE and RepIt beside DIM/COSMIC.
- Keep denoising section (SDCV + pruned activations).

### Episode 3
- Add QwQ-32B phase-dependent fragmentation framing (not just aggregate inverse scaling).

### Episode 4 (major upgrade)
- Narrative sequence:
  1) your paper identifies Mistral failure,
  2) spectral-healing mechanism explains why,
  3) Cristofano demonstrates solution path.
- Strengthen quantization section with same-precision extraction/intervention rule.

### Episode 5
- Use concept-cone framing as bridge to SAE decomposition.
- Add FGAA backwards design detail (choose desired effect in latent feature space first).

### Episode 6
- Add Jafari numeric predictive performance.
- Add steering externalities concrete rates (boundary crossing + adaptive ASR).
- Add Cristofano as evidence architecture barriers can be engineered around.
- Closing toolchain framing:
  - concept cones (geometry)
  - SAEs (decomposition)
  - mechanistic indicators (prediction)
  - conditional steering (deployment)

---

## New citations to add

- Cristofano (Jan 2026) — Universal Refusal Circuits [arXiv:2601.16034]
- Concept Cones / Geometry of Refusal (ICML 2025)
- Affine Concept Editing (ACE)
- RepIt (Siu et al.)
- QwQ-32B steering analysis
- CBQ / cross-block reconstruction (quantization-aware recalibration)

---

## Suggested next action from source
- Produce consolidated final series doc integrating all sources and reconciliations.
