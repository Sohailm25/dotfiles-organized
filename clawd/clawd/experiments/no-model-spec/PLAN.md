# PLAN — no-model-spec (Phase-1 only)

1. Freeze stratified 200-query slice and write frozen query IDs artifact.
2. Generate run matrix as single source of truth (conditions, seeds, hash, caps).
3. Validate instrumentation via small paired dry-run batch.
4. Run mandatory baselines on Modal.
5. Run ASO static (and bandit if available) on Modal.
6. Enforce hard stop-loss continuously.
7. Evaluate checkpoint gates at n=50/100/150.
8. Pause exactly at n=100 and publish gate report.
9. Request professor gate review.
10. Continue/abort/pivot per gate outcome.

## Artifacts expected
- `README.md` (execution contract)
- `PREREG.md` (this file’s matching prereg)
- `RUN_MATRIX.csv`
- `artifacts/frozen_query_ids.json`
- `artifacts/metrics/*.jsonl|csv`
- `reports/checkpoint_n100.md`

## Immediate next single action
Create `RUN_MATRIX.csv` template + `frozen_query_ids.json` placeholder and stop for execution handoff.
