# WORKING_MEMORY — no-model-spec

## Focus
Execute phase-1 decision-grade test on AgenticSQL with frozen gates and strict stop-loss controls.

## Locked constraints
- AgenticSQL only
- n=200 stratified
- Modal-only runs
- Mandatory baselines: autoregressive, suffix_decoding_only, routing_only
- ASO variants: static (+ bandit if available)

## Promotion logic snapshot
- Need meaningful CAL gain + CI lower-bound thresholds (not p-value alone)
- Must preserve task success within guardrails
- Must show routing discrimination (avoid path-collapse)

## Open uncertainties
- Final availability/readiness of bandit policy implementation
- Exact stratification bucket boundaries for frozen query slice
- Model config hash convention to enforce matrix integrity

## Waiting for
- Execution in #experiment-work once run matrix + frozen query IDs are prepared
- n=100 checkpoint report for professor gate review

## Next single action
Produce `RUN_MATRIX.csv` and freeze query IDs artifact skeleton, then request execution handoff.
