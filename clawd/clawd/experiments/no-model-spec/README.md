# no-model-spec

## Status
Phase-1 execution plan locked (Professor directive approved). This README is the handoff contract for #experiment-work execution.

## Hypothesis (phase-1 scoped)
For structured agentic workloads (AgenticSQL), **ASO** (difficulty-aware routing + model-free speculation) can outperform either component alone on **Cost-Adjusted Latency (CAL, λ=0.5)** while preserving task success within guardrails.

## Scope Lock (non-negotiable)
- Phase: **phase-1 only**
- Benchmark: **AgenticSQL only**
- Dataset size: **n=200 stratified queries**
- Conditions (mandatory):
  1. Autoregressive baseline
  2. SuffixDecoding-only baseline
  3. Routing-only baseline
  4. ASO variants (static policy; bandit policy if available)
- Do not relax preregistered thresholds mid-run.

## Primary Decision Target
Decide whether to invest in full ASO stage-2 build.

Decision mapping:
- ASO beats both single-component baselines on CAL (with prereg statistical clarity) → invest in stage-2
- ASO beats only one → narrow to winning component
- ASO loses to both → reject hybrid and pivot
- Tie within uncertainty/noise → inconclusive, redesign benchmark or sample plan

## Must-Win Metric
- **CAL = Latency × (1 + λ × NormalizedCost)**
- λ fixed at **0.5**
- NormalizedCost anchored so FULL path cost = 1.0

Secondary (non-gating):
- p95 latency
- task success rate (guardrail)
- tokens/sec (diagnostic)

## Hard Thresholds / Gates
- Minimum meaningful gain target:
  - CAL_ASO < 0.85 × min(CAL_SuffixDecoding, CAL_Routing)
- Success guardrail:
  - TaskSuccess_ASO ≥ TaskSuccess_BestBaseline − 0.02
- Hard abort if task success drop >5pp at checkpoint.

## Statistical Clarity Rule (promotion-readiness)
- p < 0.05 is necessary, not sufficient.
- Promote-ready if:
  - Point estimate ≥20% and 95% CI lower bound >5%, or
  - Point estimate 15–20% and 95% CI lower bound >8%
- Soft promote if 15–20% and CI lower bound in 0–8% (must caveat uncertainty).
- Not promote-ready if CI includes 0 near threshold or point estimate <15%.

## Budget / Runtime Controls
- Phase-1 total cap: **$500**
- Per-run stop-loss: **$50**
- Per-run timeout: **4h**
- Pause and reassess by ~$400 if signal is unclear.

## Required Run Matrix (single source of truth)
For each run include:
- condition_name
- seed
- query_slice_id
- intended_n
- model_config_hash
- budget_cap_usd (=50)
- timeout_seconds (=14400)

First pass minimum:
- 3 baselines × >=1 seed for checkpoint
- ASO static + bandit variant if available

## Data Protocol (bias control)
- Construct and freeze stratified 200-query slice before execution.
- Write frozen query IDs to file before first run.
- Use the exact same query IDs across all conditions for paired comparisons.

## Instrumentation (required fields)
Per-query:
- condition, seed, query_id
- route (DIRECT/SPEC/FULL)
- latency
- normalized_cost
- CAL contribution
- task_success (0/1 or canonical)
- SPEC accepted/speculated tokens (when SPEC used)
- runtime_error flag

Rolling/cumulative:
- cumulative spend estimate
- cumulative runtime
- rolling SPEC acceptance rate
- rolling routing share by path

## Runtime Stop-Loss + Abort Logic
Hard stop immediately if:
- run exceeds $50 or 4h
- runtime error rate persistently >2%
- SPEC acceptance <20% sustained
- task success drops >5pp vs best baseline checkpoint

Checkpoint abort:
- n=50: CAL gain <5% and success down >3pp
- n=100: CAL gain <10% and no variant promising
- n=150: CAL gain <12%

## Mandatory n=100 Pause Report
Must report before continuing:
1. CAL point estimate vs each baseline
2. 95% CI for each comparison
3. task success delta vs best baseline
4. routing distribution (DIRECT/SPEC/FULL)
5. SPEC acceptance rate

Include recommendation: continue / abort / pivot, tied to prereg thresholds.

## Claim Hygiene
Allowed wording:
- “evidence for … on AgenticSQL phase-1”

Disallowed wording:
- “validated generally”
- “SOTA”
- cross-domain generalization claims

## Checkpoint Deliverables
For each checkpoint attach:
- command(s) run
- config snapshot
- metrics artifact path
- brief interpretation vs gates
- explicit ask: “requesting professor gate review”

## Promotion Policy
Do NOT call promotion until all are true:
- n=100 gate reviewed
- thresholds satisfied (or caveated per prereg)
- explicit go from Sohail

## First Step (smallest valid test)
1) Build and freeze run matrix + stratified query slice artifact files.
2) Execute one dry-run batch (e.g., 10 paired queries) across all mandatory baselines to validate logging schema, stop-loss enforcement, and report pipeline.
3) If dry-run artifacts are clean, start full n=200 execution with mandatory n=100 pause gate.
