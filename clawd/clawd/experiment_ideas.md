# Experiment Ideas Log

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
