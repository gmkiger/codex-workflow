---
name: respond-to-referees
description: Draft a response to referee comments, cross-referencing each concern against the revised manuscript. Trigger: "respond to referees", "draft R&R response", "address referee comments".
argument-hint: "[referee-report path] [revised-manuscript path]"
---

# Respond to Referees

Draft a complete response-to-referees document, cross-referencing each referee concern against the revised manuscript.

**Use this skill when:** you have referee comments and need a response document.
**Use `/review-paper --peer --r2` when:** you want to simulate another round of review.

## Steps

1. **Parse arguments:** identify referee report path and revised manuscript path from `$ARGUMENTS`.

2. **Read the referee report** in full. Extract and number every distinct concern (Major/Minor, by referee).

3. **Read the revised manuscript** in full.

4. **For each concern, produce a response entry:**
   - **Referee's concern:** (quote the relevant excerpt)
   - **Our response:** (what we changed and why, or why we disagree with specific evidence)
   - **Location in manuscript:** (section, page, equation, or table where the change appears)
   - **Status:** Addressed / Partially Addressed / Disagree (with rationale)

5. **Format as a complete response document** using `templates/response-to-referees.md` as the base template.

6. **Save to** `quality_reports/response_to_referees_round[N].md`

## Post-Flight Verification (mandatory)

The response document contains assertions about the revised manuscript ("We added X on page Y"). These must be verified:
```bash
./scripts/run-workflow.sh --fork claim-verifier \
  "Claims: [assertions about manuscript changes]" \
  "Questions: [does section Y actually contain X?]" \
  "Sources: [revised manuscript path]"
```

## Principles

- Every concern deserves a substantive response. "We disagree" is valid only with evidence.
- Page and section numbers must be precise — verify against actual manuscript.
- Distinguish: what changed in the text vs what changed in the analysis vs what was already present.
- Tone: collegial and professional, never defensive.
