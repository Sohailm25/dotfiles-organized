# Experiment Ideas Log

## 2026-02-22 — no-model-spec
- Slug: `no-model-spec`
- Status: Scope locked for phase-1 execution; handoff README created for #experiment-work.
- Canonical thread: `https://sohailmo.slack.com/archives/C0ADFN5HREE/p1771775251561389`
- Locked scope:
  - AgenticSQL only, n=200 stratified
  - Mandatory baselines: autoregressive, SuffixDecoding-only, routing-only
  - ASO variants: static (+ bandit if available)
- Core decision metric: CAL (λ=0.5), with task-success guardrails.
- Promotion clarity amendment retained:
  - p<0.05 necessary, CI lower-bound rules required near threshold.
- Artifact created:
  - `/Users/sohailmohammad/clawd/experiments/no-model-spec/README.md`
- Next execution checkpoint:
  - mandatory n=100 pause report with CAL estimates, 95% CIs, success deltas, routing shares, SPEC acceptance, and continue/abort/pivot recommendation.
- Execution infra lock (added after scope lock):
  - all runs must be executed on Modal.
  - credentials for Modal + W&B + HF were provided by Sohail in Slack source message `1771775507.934979` (sensitive; reference only).

## 2026-02-22 — json-quant
- Slug: `json-quant`
- Status: Promoted to #experiment-ideas (`promote-idea` PASS), lifecycle `ideation`
- Canonical context:
  - Seed transcript: `/Users/sohailmohammad/clawd-experiments/experiments/json-quant/history/research_seed.md`
  - Idea thread: `https://sohailmo.slack.com/archives/C0ADFN5HREE/p1771769685555829`
- Core hypothesis:
  - Quantization may disproportionately degrade structured JSON output vs unstructured generation.
  - Mechanistic decomposition: feature attenuation vs feature noise vs downstream readout corruption.
  - Potential repair path via SAE-based interventions, benchmarked against constrained decoding and fine-tuning baselines.
- Gating notes before promote-to-work:
  - Reframe primary objective as mechanistic diagnosis; repair is secondary.
  - Include GPTQ + AWQ, at least two model families.
  - Evaluate constrained vs unconstrained decoding; separate syntax vs semantics metrics.
  - Pre-register causal necessity/sufficiency tests with random controls.
  - Define side-effect non-inferiority thresholds and stop/go pivot criteria.
- Deliverables standard locked (promote-ready, not force-ready):
  1) `README.md` handoff-grade with conservative hypothesis language, explicit syntax/semantics criteria, diagnosis-first objective, and a cheap falsification first step.
  2) `PREREG.md` with primary metric thresholds, necessity/sufficiency + random controls, abort/pivot rules, budget/runtime caps.
  3) `PLAN.md` (<=30 lines) with interview completion, 8-15 item literature table, minimum experiment matrix, and exact promote checklist.
  4) `WORKING_MEMORY.md` with focus, uncertainties, next single action, and `waiting_for` state.
- No-forcing-progress rule: only call `@ops promote "json-quant" as json-quant` when prereg is concrete, criteria measurable, confounds documented, and unresolved claims are explicitly labeled unknown/hypothesis.
