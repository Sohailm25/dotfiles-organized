# Activation Steering Series — Reconciliation Feedback (2026-02-23)

Source: Slack #contentforge-video (message id: 1771828875.855899)

## What the Research Uncovered That We’re Missing

### Critical gaps (must integrate)

1. **Random noise bypasses safety**
   - Random vectors in middle layers increase harmful compliance by ~1–13%.
   - Averaging successful random vectors yields a **“Universal Vector”** that generalizes to unseen prompts (reported up to 50% on Llama-3.1-70B).
   - This challenges the “steering is always precise/surgical” framing.
   - Recontextualization for Mistral anomaly: coherence failure may reflect perturbation sensitivity, not just refusal-direction mismatch.

2. **SAE Input/Output feature split**
   - Early layers (0–50% depth): mostly detector/input features.
   - Later layers (66–100%): mostly actuator/output features.
   - Steering with input features often fails.
   - Filtering features by causal **Output Score** improves effectiveness by ~2–3x.

3. **Feature Absorption**
   - Wider SAEs can reduce steering precision by splitting one concept across multiple latents.
   - Concrete mechanism for distributed-representation behavior at scale.

4. **Steerability paradox**
   - Highly interpretable features (good detectors) are often weak actuators for generation.

5. **ROSI / permanent steering**
   - Rank-One Safety Injection (ROSI) “bakes in” safety direction to weights with zero inference overhead.
   - Reported jailbreak success drop (example cited): 52.7% → 6.7% on Qwen 2.5.

6. **Beyond Transformers**
   - State steering in Mamba/RWKV works, but is not additive with residual stream steering.

---

## Recommended updates by episode

### Episode 1
- Add **Causal Abstraction** framing (Distributed Interchange Intervention / bijective translation between neural states and causal variables).
- Add **Elicitation Overhang** concept.

### Episode 2
- Add denoising problem for dense vectors.
- Include:
  - L2-pruned activation differences (top-50% heuristic)
  - SDCV (SAE-projected denoised vectors), reported +4–16% improvements
- Add **Intervention Algebras** / compositional steering and commutativity idea.

### Episode 3 (major rework)
- Integrate random-noise finding as a foil to precision narrative.
- Add red-team composition formula: **v_attack = v_bias − v_refusal**.

### Episode 4
- Add multimodal hijacking (VLM visual channel as steering vector; referenced vulnerable layers 5/15/31).
- Add universal vector framing as aggregate latent failure mode.

### Episode 5 (major enhancement)
- Open with detector-vs-actuator split.
- Make Feature Absorption central.
- Include MIB comparison:
  - DAS supervised localization: ~94–100%
  - SAE clamping: ~74–80%
- Include FGAA behavioral-coherence comparison:
  - 0.5798 vs 0.3262 (Love steering, Gemma-2-2B)
- Add steering asymmetry (negative steering is harder than positive steering).

### Episode 6
- Add ROSI + LoRA distillation bridge from transient steering to permanent alignment.
- Add cross-architecture extension to Mamba/RWKV.
- Add “lobotomy effect” framing (incoherence risk under some steering).
- Add Universality Hypothesis caveat relative to cross-family transfer result.

---

## Proposed narrative arc change

Current arc:
- clean geometric story → complications from experiments → open problems

Recommended arc:
1. Beautiful geometric story
2. Signal extraction + noise reality
3. Scale breakage + random-noise fragility
4. Architecture/multimodal/universal vectors
5. SAEs as path forward + paradoxes
6. Permanent steering + cross-architecture frontier + “scalpel vs sledgehammer”

Recurring motif recommendation: **“Scalpel vs Sledgehammer”**.

---

## Suggested action from source message
- Produce an updated full series document integrating these changes.
