# Activation Steering Deep Dive: Video Mini-Series Plan

**Anchor Paper:** *Inverse Scaling in Activation Steering: Architecture and Scale Dependence of Refusal Manipulation* — Siraj Mohammad & Sohail Mohammad (Feb 2026)

**Series Thesis:** Activation steering is one of the most elegant ideas in modern AI safety — but it breaks in ways nobody talks about. This series takes you from the foundations through the frontier, using original research to show where the clean story gets complicated.

**Target Audience:** ML engineers, AI safety researchers, interpretability enthusiasts, and anyone who wants to understand how we can control what's happening inside neural networks without retraining them.

**Format:** 6 episodes, 15–25 minutes each. Talking head + screen share with diagrams/code. Conversational but technically rigorous.

---

## Series Arc

The series follows a narrative arc: start with the beautiful, clean story (behaviors = directions in activation space), then systematically complicate it with real experimental evidence, and end with the open frontier.

| Ep | Title | Core Question | Your Paper's Role |
|----|-------|---------------|-------------------|
| 1 | The Geometry of Behavior | What if model behaviors are just directions in a vector space? | Motivation — why you ran these experiments |
| 2 | Extracting the Signal | How do you actually find these directions? DIM vs SVD vs SAEs | Your DIM vs COSMIC comparison; simple beats complex |
| 3 | The Inverse Scaling Problem | Why do larger models resist steering? | Your central finding — the scaling wall |
| 4 | Architecture as a Gate | Why does the same method work perfectly on one model and completely fail on another? | The Mistral anomaly; cross-family transfer failure |
| 5 | The SAE Revolution | Can sparse autoencoders give us finer-grained control? | Your Hypothesis 1 (refusal fragmentation); bridge to SAE-based methods |
| 6 | Where Steering Breaks — and What Comes Next | What does all of this mean for AI safety? | Synthesis of all findings; safety implications; open problems |

---

## Episode 1: The Geometry of Behavior

**Runtime:** ~18 min
**Thesis:** If you could find a "refusal direction" inside a neural network and just add or subtract it, you'd have a surgical tool for controlling AI behavior without retraining. That's activation steering — and it's more real than it sounds.

### Script Outline

**Opening Hook (2 min)**
- Demo: show a model refusing a harmless prompt ("How do I bake a cake?" → "I cannot assist with illegal activities...") after adding a single vector to its internals
- "What you just saw isn't a jailbreak. It's not prompt engineering. I added one vector — a direction in the model's internal space — and it started refusing everything. This is activation steering."

**Act 1: The Linear Representation Hypothesis (5 min)**
- Start with word2vec analogy: king − man + woman ≈ queen
- Scale up: this property doesn't just exist in word embeddings — it exists inside the hidden layers of LLMs
- Key idea: high-level concepts (sentiment, truthfulness, refusal) correspond to directions in activation space
- Visual: show a 2D projection of activation space with harmful vs harmless prompts clustered separately, with the "refusal direction" as the vector between cluster means

**Act 2: The Foundational Papers (6 min)**
Walk through the lineage, explaining each contribution:

1. **Turner et al. (2023) — Activation Addition (ActAdd):** The original insight. Compute steering vectors from contrastive prompt pairs ("Love" vs "Hate"), add them during inference. Showed SOTA on sentiment shift and detoxification. The key realization: you don't need to optimize anything — just compute and add.

2. **Zou et al. (2023) — Representation Engineering (RepE):** Formalized the idea. Used mean-difference and PCA over contrastive datasets to extract "concept vectors" for properties like truthfulness and safety. Showed this works across many concepts, not just sentiment.

3. **Li et al. (2023) — Inference-Time Intervention (ITI):** Shifted activations along truthful directions across attention heads. Showed you could improve factuality at inference time.

4. **Panickssery et al. (2023) — Contrastive Activation Addition (CAA):** Demonstrated on Llama 2 that steering vectors from harmful/harmless pairs could suppress dangerous outputs while preserving capabilities.

5. **Arditi et al. (2024) — "Refusal Is Mediated by a Single Direction":** The paper that changed everything. Showed across 13 models up to 72B parameters that refusal lives in a one-dimensional subspace. Ablate it → model stops refusing. Add it → model refuses everything. This gave geometric grounding to the entire approach.

**Act 3: Why This Matters for Safety (3 min)**
- If behaviors are directions, we have a surgical tool: no retraining, no RLHF, just vector arithmetic
- The promise: monitor model internals in real time, intervene when you detect dangerous directions
- The question this series will answer: does this actually hold up under real conditions?

**Closing / Tease (2 min)**
- "Arditi et al. found a beautiful result: one direction, one behavior. But they tested existence — not reliability. What happens when you try to actually use this across different model sizes, different architectures, different precision levels? That's what we set out to test. And what we found... is complicated."

### Key Papers to Reference
- Turner et al. (2023) — ActAdd [arXiv:2308.10248]
- Zou et al. (2023) — Representation Engineering [arXiv:2310.01405]
- Li et al. (2023) — Inference-Time Intervention [arXiv:2306.03341]
- Panickssery et al. (2023) — CAA on Llama 2 [arXiv:2312.06681]
- Arditi et al. (2024) — Single Refusal Direction [arXiv:2406.11717]
- Elhage et al. (2022) — Toy Models of Superposition [arXiv:2209.10652]
- Marks & Tegmark (2023) — Geometry of Truth [arXiv:2310.06824]
- Bolukbasi et al. (2016) — Word embedding geometry (historical context)

### Visuals Needed
- Animated 2D projection of activation space (harmful vs harmless clusters)
- Timeline graphic of the foundational papers
- Side-by-side: unsteered output vs steered output on same prompt
- Diagram: residual stream with vector addition at a target layer

---

## Episode 2: Extracting the Signal — Simple vs Complex

**Runtime:** ~22 min
**Thesis:** There are fundamentally different ways to extract steering directions. The surprising finding: the simplest method (mean difference) matches or beats more sophisticated approaches at every scale.

### Script Outline

**Opening (2 min)**
- Recap: we know behaviors correspond to directions. Now: how do you actually find these directions?
- "Turns out, how you extract the direction matters more than you'd think — and not in the way you'd expect."

**Act 1: Difference-in-Means (DIM) — The Simple Approach (6 min)**
- Walk through the math step by step:
  - Collect activations on harmful prompts (the ones that trigger refusal)
  - Collect activations on harmless prompts (the ones that get helpful responses)
  - Subtract the means, normalize
  - d̂ = (μ_harmful − μ_harmless) / ‖μ_harmful − μ_harmless‖
- Why this works: if refusal is a consistent shift in activation space, the mean difference is the maximum-likelihood estimator of that shift under Gaussian assumptions
- Show the actual contrastive prompt pairs used (5 harmful, 5 harmless — that's it)
- "This is absurdly simple. Five examples of each. A single subtraction. And it works."

**Act 2: COSMIC — The Complex Alternative (5 min)**
- Explain SVD-based extraction: instead of mean difference, take the top singular vector of contrastive activation matrices
- COSMIC's automated layer selection: score each layer by how well its direction agrees with all other layers, pick the highest agreement
- The appeal: architecture-agnostic, behavior-agnostic, no assumptions about where concepts are encoded
- Walk through the SVD decomposition visually

**Act 3: Head-to-Head Results (5 min)**
- Present your paper's Table 7 comparison:
  - At 3B and 14B: tied (100%, 90%)
  - At 32B: DIM wins by 50 percentage points (60% vs 10%, p < 0.001)
  - At Gemma 9B: DIM wins by 20pp (90% vs 70%)
- The critical failure: COSMIC's automated layer selection picks L43 (67% depth) at 32B when the optimum is L32 (50%). The aggregation-based scoring breaks at scale.
- Key insight: "A human applying the heuristic 'use 50% depth' outperforms the algorithm."

**Act 4: Why Simple Wins — and When It Won't (3 min)**
- Connect to Marks & Tegmark: difference-in-mean probes generalize as well as complex classifiers for truth representations
- Theoretical argument: if the signal is truly one-dimensional, the mean difference is optimal. SVD extracts maximum variance, which coincides with the mean shift only when signal dominates noise.
- But: this doesn't mean complex methods are never warranted. Your inverse scaling finding suggests exactly the opposite — at frontier scale, you may need nonlinear methods.
- Bridge to Beaglehole et al. (2025) — RFM (nonlinear kernel method) with all-block steering and 768 training examples works at larger scales where DIM fails

**Act 5: The Hidden Variable — Tooling Sensitivity (3 min)**
- Your discovery: nnsight vs raw PyTorch hooks produces directions with 100% vs 10% effectiveness on the same model, same data, same layer
- Walk through what likely causes this (in-place tensor operations corrupting activation reads)
- Implications for reproducibility: "If extraction tooling can cause a 90-percentage-point swing, how many papers that report 'steering doesn't work on model X' are actually reporting 'our hooks were wrong'?"
- Practical recommendation: always specify extraction libraries/versions, validate directions against known baselines

### Key Papers to Reference
- Arditi et al. (2024) — DIM methodology [arXiv:2406.11717]
- Siu et al. (2025) — COSMIC [arXiv:2506.00085]
- Jorgensen et al. (2023) — Mean-centring [arXiv:2312.03813]
- Marks & Tegmark (2023) — Geometry of Truth [arXiv:2310.06824]
- Fiotto-Kaufman et al. (2024) — nnsight [arXiv:2407.14561]
- Beaglehole et al. (2025) — Representation Function Matching [arXiv:2502.03708]
- Postmus & Abreu (2024) — Conceptors for steering [arXiv:2410.16314]

### Visuals Needed
- Animated walkthrough of DIM computation (collect, subtract, normalize)
- SVD decomposition diagram for COSMIC
- Bar chart: DIM vs COSMIC across scales (from your paper's Figure 3)
- Code comparison: nnsight tracing API vs raw hooks

---

## Episode 3: The Inverse Scaling Problem

**Runtime:** ~20 min
**Thesis:** The central finding of our research — steering works perfectly on small models and degrades monotonically with scale. This is a problem for AI safety.

### Script Outline

**Opening (2 min)**
- "Here's the finding that made us rethink everything: larger models are harder to steer. Not a little harder — categorically harder. And the pattern is monotonic."
- Show Figure 1 from the paper (the inverse scaling curve)

**Act 1: The Data (5 min)**
- Walk through the Qwen family results (holding architecture constant):
  - 3B: 100% coherent refusal
  - 7B: 100%
  - 14B: 90%
  - 32B: 77% (n=30) / 60% (n=50)
- Gemma family: even more dramatic
  - 2B: 100%
  - 9B: 97%
  - 27B: 0% (complete failure — 100% garbled)
- Statistical significance: Fisher's exact test, 3B vs 32B (50-prompt): p = 0.005, Cohen's h = 1.06
- Show the actual steered outputs — coherent refusals at small scale vs garbled repetition at large scale

**Act 2: Three Competing Hypotheses (6 min)**
Present each hypothesis from Section 9, making them accessible:

1. **Distributed Representation Hypothesis:**
   - Connect to superposition (Elhage et al., 2022): models represent more features than they have dimensions
   - Larger models may represent refusal in a more polysemantic way — entangled with safety, ethics, uncertainty, helpfulness
   - A single DIM vector captures the average, but the "cluster" spreads across more dimensions at scale
   - Supporting evidence: Gemma 27B direction norms of 350+ (vs 24–93 for steerable models)

2. **Redundancy Hypothesis:**
   - Larger models may implement refusal via redundant pathways
   - Wei et al. (2024): safety-critical parameters are sparse (~3%), but 3% of a bigger model is more room for redundancy
   - Your intervention is one shared linear direction across layers — methods that learn richer per-layer interventions are strictly more expressive

3. **Narrowing Window Hypothesis:**
   - Your multiplier sweep on Qwen 32B: 15× works (60%), 20× drops to 20%, 25× = 90% garbled
   - Small models tolerate 15×–25× without degradation
   - Larger models operate closer to a nonlinear response regime — the intervention must be precisely calibrated

**Act 3: Reconciling with Beaglehole et al. (5 min)**
- The apparent contradiction: they find larger models are MORE steerable
- The resolution: their method (RFM) is nonlinear, multi-layer, uses 768 training examples
- Your method: linear, single direction, ~10 contrastive pairs
- "The gap between these results quantifies the scaling wall separating simple linear from complex nonlinear methods"
- Key insight: the "refusal direction" may be a real feature at small scales but an increasingly lossy summary of higher-dimensional structure at large scales

**Act 4: The Layer Depth Shift (2 min)**
- Optimal depth moves shallower with scale: 60% → 50% in Qwen, 30–40% in Gemma
- The common heuristic of ~67% depth is wrong for large models
- Practical guidance: start at 50% for models ≥14B, sweep ±10%

### Key Papers to Reference
- Elhage et al. (2022) — Toy Models of Superposition [arXiv:2209.10652]
- Wei et al. (2024) — Brittleness of Safety Alignment [arXiv:2402.05162]
- Beaglehole et al. (2025) — Universal Steering/Monitoring [arXiv:2502.03708]
- Templeton et al. (2024) — Scaling Monosemanticity [transformer-circuits.pub]
- Jafari et al. (2026) — Mechanistic Indicators of Steering Effectiveness [arXiv:2602.01716] ← brand new, directly relevant
- Xiong et al. (2026) — Steering Externalities [arXiv:2602.04896] ← brand new, safety implications

### Visuals Needed
- Figure 1 from your paper (inverse scaling curve) — animated build
- Multiplier sensitivity chart (Figure 5) — the narrow window
- Visual metaphor: "trying to thread a needle that gets smaller as the model gets bigger"
- Comparison table: your method specs vs Beaglehole et al.'s

---

## Episode 4: Architecture as a Gate

**Runtime:** ~20 min
**Thesis:** Steerability isn't a universal property of language models — it's architecture-dependent in ways we don't fully understand. The Mistral anomaly is the most striking evidence.

### Script Outline

**Opening (2 min)**
- "Same parameter count. Same method. Same data. Same multiplier. One model: 100% coherent refusal. The other: 100% garbled gibberish. Why?"
- Play the Mistral garbled output: "illegal illegal illegal illegal illegal..."

**Act 1: The Mistral Anomaly (6 min)**
- Setup: Qwen 7B vs Mistral 7B — identical conditions, opposite outcomes
- Walk through what you tried:
  - Multiple layers (50%, 60%, 70% depth)
  - Both DIM and COSMIC directions
  - Both methods: 0% coherent, 100% garbled
  - DIM–COSMIC cosine on Mistral: 0.008 (essentially orthogonal) — yet both fail identically
- Key insight: "When two independent methods both fail to find a consistent direction, the parsimonious explanation is that refusal isn't linearly represented in this architecture's residual stream"
- Three hypotheses:
  - Sliding window attention changes how perturbation propagates
  - Mistral's alignment training distributes refusal differently
  - Mistral's residual stream norms make the same multiplier effectively too large

**Act 2: Cross-Family Transfer (5 min)**
- Within Qwen family: 14B → 32B transfer efficiency = 1.25 (better than native!)
- Cross-family (Qwen 7B → Gemma 9B): TE = 0.17
- Cross-cosine: 0.324 (same-family) vs 0.019 (cross-family, near-orthogonal)
- Despite identical hidden dimensionality (3584)
- "If refusal were encoded in a geometry determined by training data (which overlaps substantially), we'd expect at least moderate cross-family transfer. The near-orthogonality suggests architecture shapes the geometry more than data does."

**Act 3: What This Means — Refusal Is Not Universal Geometry (4 min)**
- Connect to the broader interpretability question: are features universal across architectures?
- Discuss the Platonic Representation Hypothesis and how these results complicate it
- For safety: steering-based monitoring must be validated per-architecture — no guaranteed transfer
- For the field: if you report "steering doesn't work on model X," first check architecture compatibility and tooling

**Act 4: The Quantization Story (3 min)**
- Your quantization results: a clean story with a twist
- INT8: safe across scales (100% at 7B, 83% at 32B)
- INT4: safe at 7B (100%), degrades at 32B (77% → 57%)
- The striking finding: direction cosines stay ~0.97 at both scales, but functional performance diverges
- "The quantized directions point in almost exactly the same direction, but the quantized model's response to that direction differs at scale"
- Connect to the narrowing window: quantization doesn't corrupt the direction — it subtly changes the landscape

### Key Papers to Reference
- Arditi et al. (2024) — Tests across 13 models but focused on existence [arXiv:2406.11717]
- Dettmers et al. (2022) — LLM.int8() and outlier features [arXiv:2208.07339]
- Frantar et al. (2023) — GPTQ quantization [arXiv:2210.17323]
- Lin et al. (2024) — AWQ [arXiv:2306.00978]
- Lermen et al. (2023) — LoRA undoes safety training [arXiv:2310.20624]
- CAST (ICLR 2025) — Conditional Activation Steering, shows context-dependent control can help
- Hua et al. (2025/2026) — Steering to suppress evaluation-awareness [arXiv:2510.20487]

### Visuals Needed
- Side-by-side output comparison: Qwen 7B (clean refusal) vs Mistral 7B (garbled)
- Transfer efficiency bar chart (Figure 6 from your paper)
- Geometric vs functional preservation under quantization (Figure 9)
- Architecture comparison diagram: full attention vs sliding window

---

## Episode 5: The SAE Revolution

**Runtime:** ~22 min
**Thesis:** Sparse autoencoders let us decompose model internals into interpretable features — and they're transforming how we think about steering. But they come with their own tradeoffs.

### Script Outline

**Opening (2 min)**
- Bridge from the inverse scaling problem: "If single linear directions become lossy at scale, what if we could decompose the model's representations into many specific features and steer those individually?"
- "Enter sparse autoencoders."

**Act 1: SAEs — What They Are and Why They Matter (6 min)**
- The superposition problem: models pack more features than they have dimensions
- SAEs learn to decompose activations into sparse, interpretable features
- Walk through the architecture: encoder projects to a much larger space, forces sparsity, decoder reconstructs
- Anthropic's Scaling Monosemanticity (Templeton et al., 2024): trained SAEs on Claude 3 Sonnet, found millions of interpretable features — including safety-relevant ones
- Key realization: instead of one "refusal direction," SAEs reveal many refusal-related features

**Act 2: SAE-Based Steering Methods (6 min)**
Walk through the evolution of SAE steering:

1. **Direct SAE Feature Steering** (Templeton et al., 2024):
   - Simply amplify or suppress individual SAE features
   - Very interpretable, but side effects are hard to predict

2. **SAE-Targeted Steering (SAE-TS)** (Chalnev, Siu & Conmy, 2024):
   - Finds steering vectors that target specific SAE features while minimizing unintended side effects
   - Uses SAEs to measure the causal effects of any steering intervention
   - Better balance of steering effect vs coherence than CAA or direct feature steering

3. **Feature Guided Activation Additions (FGAA)** (Soo et al., 2025):
   - Combines insights from CAA and SAE-TS
   - Operates in SAE latent space, uses optimization to select desired features
   - Outperforms CAA, SAE decoder steering, and SAE-TS on Gemma 2B and 9B

4. **SAE-RSV** (OpenReview, ICLR 2026 submission):
   - Refines steering vectors from limited data by denoising through SAE feature semantics
   - Addresses the key practical problem: most methods need large contrastive datasets

5. **CorrSteer** (OpenReview, ICLR 2026 submission):
   - Selects features by correlating sample correctness with SAE activations at inference time
   - Fully automated pipeline — no contrastive datasets needed

6. **Control Reinforcement Learning (CRL)** (Feb 2026):
   - Trains an RL policy to select which SAE features to steer at each token
   - Token-level interpretable intervention logs
   - Discovers that early layers encode syntactic features, later layers encode semantic ones

**Act 3: The Refusal-Capability Tradeoff (4 min)**
- O'Brien et al. (2024) — "Steering Language Model Refusal with Sparse Autoencoders"
  - SAE feature steering improves robustness against jailbreaks
  - But: systematic degradation of performance on benchmark tasks, even safe inputs
  - "Features mediating refusal may be more deeply entangled with general capabilities than previously understood"
- Connect to your paper's Hypothesis 1: SAE analysis of large models should reveal multiple distinct refusal features where small models have one or two
- This is the core tension: the more precisely you try to control a model, the more you discover that the features you care about are entangled with everything else

**Act 4: Brand New — Steering Externalities (2 min)**
- Xiong et al. (Feb 2026) — even benign steering vectors (enforcing compliance, JSON output) inadvertently erode safety guardrails
- Attack success rates increase to over 80% on standard benchmarks
- "Inference-time utility improvements must be rigorously audited for unintended safety externalities"

**Closing — Where SAEs Meet Your Paper's Findings (2 min)**
- Your Hypothesis 1: SAE analysis of Qwen 32B should reveal multiple distinct refusal features where Qwen 3B has one or two. The number of refusal features should correlate with model scale.
- If confirmed, this would explain the inverse scaling: DIM captures a single direction, but at larger scales, refusal is distributed across multiple SAE features
- "This is the experiment someone needs to run."

### Key Papers to Reference
- Templeton et al. (2024) — Scaling Monosemanticity [transformer-circuits.pub]
- Bricken et al. (2023) — Sparse autoencoders in language models [arXiv:2309.08600]
- Cunningham et al. (2023) — SAEs find interpretable features [arXiv:2309.08600]
- Chalnev, Siu & Conmy (2024) — SAE-TS [arXiv:2411.02193]
- O'Brien et al. (2024) — SAE steering for refusal [arXiv:2411.11296]
- Soo et al. (2025) — FGAA [arXiv:2501.09929]
- Xiong et al. (2026) — Steering Externalities [arXiv:2602.04896]
- CRL (2026) — Control RL for SAE steering [arXiv:2602.10437]
- Cho & Hockenmaier (EMNLP 2025) — SAE-guided steering for ICL
- LessWrong post: "Finding Features Causally Upstream of Refusal" — uses SAE gradients to trace refusal circuits in Gemma-2-2B

### Visuals Needed
- SAE architecture diagram (encoder → sparse representation → decoder)
- Feature activation heatmap showing multiple refusal-related features
- Comparison chart: CAA vs SAE-TS vs FGAA vs CorrSteer
- The refusal-capability tradeoff curve

---

## Episode 6: Where Steering Breaks — and What Comes Next

**Runtime:** ~20 min
**Thesis:** Activation steering faces fundamental limitations at frontier scale, but the community is pushing through them. Here's what the open problems are and what they mean for AI safety.

### Script Outline

**Opening (2 min)**
- Recap the series arc: "We started with a beautiful geometric story. Then we systematically showed where it breaks. Now: what do we do about it?"

**Act 1: The Safety Case — Why This Matters Beyond Research (5 min)**
- The scaling problem: linear steering degrades precisely at the scales where safety matters most
  - Your data: 2B–32B. Frontier models are 10–100× larger
  - "Extrapolating suggests single-direction steering would be minimally effective at frontier scale"
- The architecture problem: steering-based monitoring must be validated per-architecture
- The tooling problem: 90pp swings from extraction implementation details
- Connect to CAST (ICLR 2025): conditional activation steering as a step toward more targeted control
- Connect to Hua et al. (2025): steering can suppress evaluation-awareness — models adjusting behavior during evals

**Act 2: The Methods Pushing Through the Wall (5 min)**
- **Nonlinear methods** (Beaglehole et al. — RFM): operate nonlinearly across all layers, succeed where DIM fails
- **Conceptors** (Postmus & Abreu, 2024): represent activation sets as ellipsoidal regions (matrices, not vectors). Boolean operations for combined steering goals
- **SAE-based approaches**: decompose the problem into many precise features
- **Conditional steering** (CAST, ICLR 2025): context-dependent control — steer only when specific conditions are met
- **Mechanistic indicators** (Jafari et al., Feb 2026): entropy-based measures (Normalized Branching Factor) and KL divergence can predict when steering will succeed or fail — no more black-box evaluation
- **Geometry of Refusal** (ICML 2025): gradient-based approach to RepE, "concept cones" and representational independence

**Act 3: Your Four Testable Hypotheses (4 min)**
Present each as an open challenge to the community:

1. **Refusal fragmentation at scale:** SAE analysis should reveal more refusal features in larger models. Run SAEs on Qwen 3B vs 32B — count the refusal-related features.

2. **Mistral encodes refusal nonlinearly:** Try nonlinear steering (RFM) or attention-head-level intervention on Mistral. If it works, the failure is about linear limitations. If not, it's deeper.

3. **The "refusal direction" is a low-rank artifact at small scales:** Train a deliberately larger model on the same data as a small model — does DIM get harder?

4. **Extraction tooling indicates feature fragility:** Compute DIM directions from multiple independent contrastive datasets. If cosine similarity across runs exceeds 0.95, the direction is robust. If lower, it's fragile.

**Act 4: The Bigger Picture — What Steering Teaches Us About Models (3 min)**
- Activation steering isn't just a safety tool — it's a window into how models represent concepts
- The inverse scaling finding tells us something about how the geometry of knowledge changes with capacity
- The architecture dependence tells us that training dynamics shape internal representations more than we thought
- The transfer results suggest that we may not have universal feature geometry across model families
- "Every failure of steering is a clue about how these models actually work inside"

**Closing (1 min)**
- "This is a field that moves fast. Between when I started this research and when I'm recording this, three new papers dropped that directly extend what we found. If you want to contribute to this space — the open problems are clear, the tools are accessible, and the stakes are high."
- "The code for our paper is open. Go break it."

### Key Papers to Reference
- Everything cited in previous episodes, plus:
- CAST (ICLR 2025) — Conditional Activation Steering
- Jafari et al. (2026) — Mechanistic Indicators [arXiv:2602.01716]
- ICML 2025 — Geometry of Refusal: Concept Cones
- Xiong et al. (2026) — Steering Externalities [arXiv:2602.04896]
- Beaglehole et al. (2025) — RFM [arXiv:2502.03708]

### Visuals Needed
- "What we know" vs "What we don't" summary chart
- Timeline of the field: 2023 → Feb 2026
- Your four hypotheses as testable experiment cards
- Closing slide with links to paper, code, and references

---

## Production Notes

### Positioning Strategy
- You're not just explaining other people's work — you ran experiments, found novel results, and are presenting them alongside the broader landscape
- Lean into the intellectual honesty of your paper (stating what's speculative, acknowledging limitations) — this builds trust with a technical audience
- Frame each episode as "here's the clean story from the literature" → "here's where our experiments complicate it" → "here's what's still open"

### Thumbnail / Branding Ideas
- Series title: "Inside the Residual Stream" or "Steering from the Inside"
- Color scheme: use the green/teal/red from your paper's figures
- Each thumbnail: a key figure from your paper or a striking visual metaphor

### Cross-Promotion
- Link to the arXiv paper in every video description
- Pin a comment with links to all referenced papers
- Create a GitHub companion repo with:
  - Notebook recreating key experiments
  - Links to every paper cited
  - A reading list organized by episode

### Recording Tips
- Screen share your actual Jupyter notebooks/code when walking through extraction methods
- Show real model outputs (the garbled Mistral outputs are viscerally compelling)
- Use diagrams from your paper directly — they're publication quality
- Keep a "jargon sidebar" approach: when you use a term like "residual stream" for the first time, briefly define it, then move on

---

## Complete Paper Reference List

### Foundational (Episode 1)
| Paper | Key Contribution | Year |
|-------|-----------------|------|
| Turner et al. — ActAdd | Original activation steering method | 2023 |
| Zou et al. — RepE | Formalized concept vectors | 2023 |
| Li et al. — ITI | Truthfulness intervention | 2023 |
| Panickssery et al. — CAA | Safety steering on Llama 2 | 2023 |
| Arditi et al. — Single Direction | Refusal = 1D subspace | 2024 |
| Elhage et al. — Superposition | Features > dimensions | 2022 |

### Extraction Methods (Episode 2)
| Paper | Key Contribution | Year |
|-------|-----------------|------|
| Siu et al. — COSMIC | SVD-based direction extraction | 2025 |
| Jorgensen et al. — Mean-centring | Improved DIM | 2023 |
| Marks & Tegmark — Geometry of Truth | Simple probes match complex ones | 2023 |
| Fiotto-Kaufman et al. — nnsight | Graph-level tracing library | 2024 |
| Postmus & Abreu — Conceptors | Matrix-based steering | 2024 |

### Scaling & Safety (Episodes 3–4)
| Paper | Key Contribution | Year |
|-------|-----------------|------|
| Beaglehole et al. — RFM | Nonlinear multi-layer steering | 2025 |
| Wei et al. — Brittleness | Safety params are sparse (~3%) | 2024 |
| Lermen et al. — LoRA Undoes Safety | $200 to remove alignment | 2023 |
| Dettmers et al. — LLM.int8() | Outlier features in quantization | 2022 |
| CAST (ICLR 2025) | Conditional activation steering | 2025 |
| Hua et al. — Eval-Awareness Steering | Steering suppresses sandbagging | 2025/2026 |

### SAE Methods (Episode 5)
| Paper | Key Contribution | Year |
|-------|-----------------|------|
| Templeton et al. — Scaling Monosemanticity | SAE features in Claude 3 Sonnet | 2024 |
| Chalnev et al. — SAE-TS | Targeted SAE feature steering | 2024 |
| O'Brien et al. — SAE Refusal Steering | Refusal-capability tradeoff | 2024 |
| Soo et al. — FGAA | Optimized SAE feature selection | 2025 |
| CorrSteer (ICLR 2026 sub) | Inference-time feature selection | 2025 |
| CRL (Feb 2026) | RL policy over SAE features | 2026 |
| Cho & Hockenmaier (EMNLP 2025) | SAE steering for ICL | 2025 |

### Frontier (Episode 6)
| Paper | Key Contribution | Year |
|-------|-----------------|------|
| Jafari et al. — Mechanistic Indicators | Predict steering success from internal signals | Feb 2026 |
| Xiong et al. — Steering Externalities | Benign steering erodes safety | Feb 2026 |
| ICML 2025 — Geometry of Refusal | Concept cones, gradient-based RepE | 2025 |
| LessWrong — Upstream Refusal Features | SAE gradient tracing of refusal circuits | 2024 |
