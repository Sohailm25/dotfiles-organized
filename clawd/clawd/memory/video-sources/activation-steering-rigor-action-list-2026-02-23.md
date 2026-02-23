# Activation Steering Series — Rigor Action List (Executed)

Date: 2026-02-23
Owner: Sohail + assistant
Objective: enforce scientific rigor before consolidating master series doc.

## A) Actions Executed Now

1. **Locked canonical source stack**
   - Confirmed canonical anchor remains:
     - `activation-steering-deep-dive-source-of-truth-2026-02-23.md`
   - Attached supporting corpus in locked entry:
     - supporting notes
     - reconciliation feedback
     - Gemini research dump
     - Gemini verification audit
     - ground-truth vs Gemini reconciliation

2. **Resolved episode-structure conflict in backlog**
   - Marked alternate "6-Episode Technical Series" section as:
     - **[ARCHIVED — SUPERSEDED BY LOCKED SOURCE OF TRUTH]**
   - Added explicit note to avoid accidental reuse.

3. **Rigor gate enabled in backlog metadata**
   - Added status line requiring claim triage:
     - Verified / Needs Rewording / Remove Unless Verified

4. **Rigor audit captured as primary decision input**
   - Audit file available at:
     - `activation-steering-rigor-audit-2026-02-23.md`

5. **Gemini source-verification response stored**
   - File:
     - `activation-steering-gemini-source-verification-audit-2026-02-23.csv`

---

## B) Canonical Decision Policy (Effective Immediately)

For master doc drafting, each candidate claim must be tagged:

- **VERIFIED**: primary source confirms wording/number
- **REWORD**: directionally valid but wording overstates certainty
- **HOLD/REMOVE**: no primary source or contradictory evidence

No untagged claims enter the master doc.

---

## C) Immediate Editing Rules for Master Consolidation

1. Replace "monotonic degradation" with threshold/scale-correlated wording.
2. Keep Mistral mechanism language as hypothesis unless directly demonstrated.
3. Label all 2025–2026 preprints as preprint/under review on first mention.
4. Remove hard numbers that lack source trail.
5. Distinguish empirical result vs hypothesis vs speculation in-line.

---

## D) Pre-Consolidation Verification Queue (Must Resolve)

1. Arditi model count/size phrasing ("13 models up to 72B").
2. Tooling-effectiveness swing claim (raw hooks vs nnsight) exact provenance.
3. Specific imported numbers from Gemini responses where there is disagreement across audits.
4. Any citation with missing author + venue + stable identifier.

---

## E) What happens next

Next output should be a **Claim Ledger** with three buckets:
1. Keep (Verified)
2. Keep with Rewording
3. Hold/Remove until primary-source verification

Master document should be drafted only from buckets 1 + 2.
