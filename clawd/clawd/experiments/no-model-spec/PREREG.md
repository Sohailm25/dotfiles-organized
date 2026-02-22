# PREREG — no-model-spec (Phase-1)

## 1) Study identity
- Experiment slug: `no-model-spec`
- Phase: 1 (only)
- Date locked: 2026-02-22
- Benchmark: AgenticSQL only

## 2) Objective
Test whether ASO (difficulty-aware routing + model-free speculation) improves Cost-Adjusted Latency (CAL, λ=0.5) over both single-component baselines without unacceptable task-success degradation.

## 3) Conditions
Mandatory:
1. autoregressive
2. suffix_decoding_only
3. routing_only
4. aso_static
5. aso_bandit (if available)

## 4) Dataset protocol
- Total n: 200 queries, stratified by predefined difficulty buckets.
- Query IDs frozen before execution in `artifacts/frozen_query_ids.json`.
- Same frozen query IDs used across all conditions (paired comparisons).

## 5) Primary metric
- CAL = latency × (1 + 0.5 × normalized_cost)
- normalized_cost scaled such that FULL path cost = 1.0

Primary comparisons:
- ASO vs suffix_decoding_only
- ASO vs routing_only
- (diagnostic) ASO vs autoregressive

## 6) Guardrails
- Success guardrail: ASO task success >= best single baseline - 0.02
- Hard abort signal: >5pp task success drop at checkpoint

## 7) Promotion-readiness statistical rule
- p < 0.05 is necessary, not sufficient.
- Promote-ready if either:
  - point estimate >=20% CAL gain and 95% CI lower bound >5%
  - point estimate 15–20% CAL gain and 95% CI lower bound >8%
- Soft promote:
  - point estimate 15–20%, p<0.05, CI lower bound in 0–8%
- Not promote-ready:
  - point estimate <15% OR CI includes 0 near threshold

## 8) Runtime/budget limits
- Total phase-1 budget cap: $500
- Per-run cap: $50
- Per-run timeout: 4h
- Platform lock: all runs on Modal

## 9) Stop-loss and checkpoint aborts
Hard stop immediately if:
- run cost > $50
- runtime > 4h
- persistent runtime error rate >2%
- sustained SPEC acceptance <20%
- task success drop >5pp vs best baseline checkpoint

Checkpoint aborts:
- n=50: CAL gain <5% AND success down >3pp
- n=100: CAL gain <10% AND no variant promising
- n=150: CAL gain <12%

## 10) Required logging schema
Per query:
- condition, seed, query_id
- route (DIRECT/SPEC/FULL)
- latency
- normalized_cost
- cal_contrib
- task_success
- spec_accepted_tokens
- spec_tokens
- runtime_error

Rolling/cumulative:
- cumulative_spend_estimate
- cumulative_runtime
- rolling_spec_acceptance
- rolling_route_share

## 11) Mandatory n=100 pause gate
Report exactly:
1. CAL point estimate vs each baseline
2. 95% CI for each comparison
3. task success delta vs best baseline
4. route distribution DIRECT/SPEC/FULL
5. SPEC acceptance rate

Then include decision: continue / abort / pivot with one-line rationale tied to prereg thresholds.

## 12) Claims policy
Allowed: “evidence for … on AgenticSQL phase-1.”
Disallowed: SOTA/general validation/cross-domain claims.

## 13) Promotion policy
Do not call promotion until:
- n=100 gate reviewed
- prereg thresholds satisfied (or explicitly caveated)
- explicit Sohail go
