# Activation Steering Series — Claim Ledger (Rigor-Gated)

Date: 2026-02-23
Purpose: master-doc drafting gate. Only claims in KEEP and REWORD buckets are eligible.
Decision policy: when audits conflict, default to conservative handling (REWORD or HOLD) until direct primary-source pass resolves disagreement.

Primary inputs:
- `activation-steering-rigor-audit-2026-02-23.md` (Claude audit)
- `activation-steering-gemini-source-verification-audit-2026-02-23.csv` (Gemini verification response)

---

## 1) KEEP (Verified enough to include now)

1. **Core arc + paper findings remain anchor**
   - Keep the 6-episode research-first structure from locked source-of-truth doc.
   - Confidence: High

2. **Inverse scaling framing (non-monotonic wording)**
   - Keep claim that steering effectiveness degrades with scale in reported experiments.
   - Wording constraint: do not use “monotonic.”
   - Confidence: High

3. **DIM as strong baseline in your experiments**
   - Keep empirical comparison outcomes from your own tables, with exact setup references.
   - Confidence: High

4. **Mistral architecture sensitivity (empirical anomaly in your data)**
   - Keep “same conditions, opposite outcomes” as observed result.
   - Confidence: High

5. **Quantization caveat at scale**
   - Keep geometric-vs-functional divergence framing (direction preserved but behavior diverges).
   - Confidence: High

6. **Bricken/Cunningham citation correction**
   - Keep correction: arXiv:2309.08600 is Cunningham et al.; Bricken is transformer-circuits publication.
   - Confidence: High

7. **Preprint caveat policy**
   - Keep explicit labeling for 2025–2026 preprints/under-review citations.
   - Confidence: High

8. **Jafari mechanistic-indicator headline (with caveat)**
   - Keep NBF/KL as promising diagnostics, not deterministic predictors.
   - Confidence: Medium

9. **Xiong externalities high-level warning (with caveat)**
   - Keep qualitative finding that benign steering can increase jailbreak risk.
   - Confidence: Medium

---

## 2) KEEP WITH REWORDING (Use canonical wording only)

1. **Scale claim wording**
   - Use: “degrades with scale, with decline observed by mid-to-large scales in our experiments.”
   - Avoid: “monotonic degradation.”

2. **Frontier extrapolation**
   - Use: “may become impractical if trend continues; no direct evidence above tested regime in this study.”
   - Avoid certainty claims.

3. **Cristofano transfer claim**
   - Use: “Cristofano (2026, single-author preprint) reports large refusal-rate reduction with <1% perplexity degradation in Ministral-3-14B under transfer protocol.”
   - Add replication caveat.

4. **Mistral spectral-healing mechanism**
   - Use: “hypothesized/reported mechanism in recent literature; not established as universal causal mechanism.”

5. **Quantization guidance**
   - Use: “extract and apply interventions in matched precision environments when possible.”
   - Avoid universal absolute mandates unless directly proven in specific setup.

6. **ActAdd performance language**
   - Use: “competitive at time of publication.”
   - Avoid blanket “SOTA” claims.

7. **Tooling sensitivity**
   - Use: “in our setup, tooling correlated with large effectiveness swings; treat as reproducibility risk requiring strict protocol controls.”
   - Avoid universal statement that library choice alone changes math.

8. **Cross-family transfer framing**
   - Use: “our experiments found weak cross-family transfer in this setting; newer transfer methods report stronger cross-architecture transfer under different protocols.”
   - Keep both true by scoping conditions.

---

## 3) HOLD / REMOVE UNTIL PRIMARY-SOURCE VERIFIED

1. **Random-noise 1–13% compliance increase**
   - Status: Hold
   - Reason: conflicting audit confidence + weak source trace in local corpus.

2. **Universal vector up to 50% on Llama-3.1-70B**
   - Status: Hold/Remove
   - Reason: unsourced in local corpus unless primary paper passage is pinned.

3. **QwQ-32B exact percentages (10.2%, 28.9%)**
   - Status: Hold
   - Reason: direct conflict between audits; include only after direct paper excerpt is attached locally.

4. **Concept cones as established ICML citation**
   - Status: Hold
   - Reason: venue/citation chain unresolved across corpus.

5. **ACE and RepIt detailed claims**
   - Status: Hold
   - Reason: require stable bibliographic entries (authors + IDs + exact claims) in final citation table.

6. **“DIM outperformed COSMIC” as method-vs-method claim**
   - Status: Recast only
   - Reason: potential category mismatch depending on COSMIC interpretation in cited source.

7. **Gemma 27B 0%/100% statements**
   - Status: Hold for external citation; keep only if clearly marked as your internal experimental result with protocol/sample size.

---

## 4) Episode Gate (what can be drafted now)

- **E1–E4:** Draftable now from KEEP + REWORD buckets.
- **E5:** Draftable with cautious language; treat many 2025–2026 methods as emerging.
- **E6:** Draftable if all speculative claims are explicitly labeled and high-risk imported numbers remain out unless verified.

---

## 5) Master-Doc Drafting Rules (enforced)

1. Every quantitative claim includes source pointer (paper + table/figure/section).
2. Every non-peer-reviewed source gets a status tag.
3. Imported claim with unresolved conflict defaults to HOLD.
4. Separate [EMPIRICAL], [HYPOTHESIS], [SPECULATION] inline.
5. No storytelling phrase that upgrades uncertainty into certainty.
