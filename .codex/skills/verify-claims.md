---
name: verify-claims
description: Run Chain-of-Verification (CoVe) on a draft with factual claims. Uses claim-verifier subprocess with fresh context. Trigger: "verify these citations", "fact-check this draft", "did I hallucinate anything", "run CoVe on this".
argument-hint: "[file-or-text-path] [--source <path-or-url>] [--no-fail-closed]"
---

# /verify-claims — Chain-of-Verification on a Draft

Fact-check a draft using the Post-Flight Verification protocol (`.codex/rules/post-flight-verification.md`).

This implements the CoVe loop from Dhuliawala et al. 2023 (arXiv:2309.11495) with architectural enforcement of the fresh-context independence trick.

**Not for:** style/grammar (use `/proofread`) or full manuscript review (use `/review-paper`).
**Note:** `/lit-review`, `/research-ideation`, `/respond-to-referees`, `/review-paper --peer` auto-run Post-Flight internally — no need to call this separately.

## Phase 0: Pre-Flight

Confirm: draft file exists, at least one source pointer available, `.codex/agents/claim-verifier.md` exists.

**`--source` flag:** Treat the following path or URL as source material for the verifier. Repeat in the task text if there are multiple sources.

**`--no-fail-closed` flag:** Report verification failures without regenerating affected draft sections.

## Phase 1: Extract Claims

Read the draft. Identify:
- Citation claims: "Smith (2019, *JEL*) shows X"
- Numerical facts: "N = 10,000", "ATT = 0.42"
- Negative literature: "No prior work studies X"
- Named entities: researcher names, paper titles, venues, packages
- Dataset claims: "The CPS contains field `educ_attain`"

Skip: opinions, forward-looking suggestions, definitions introduced in the draft.

Output a claims table: `| ID | Claim | Source hint |`

## Phase 2: Generate Verification Questions

One specific, answerable question per claim.

## Phase 3: Spawn claim-verifier (fresh context)

```bash
./scripts/run-workflow.sh --fork claim-verifier \
  "Claims: [claims table]" \
  "Questions: [verification questions]" \
  "Sources: [source file paths, DOIs, URLs]"
```

**DO NOT include the draft text in the subprocess call.** Fresh context is what makes CoVe work.

## Phase 4: Reconcile

- **PASS:** green Post-Flight block → return
- **PARTIAL:** yellow block flagging claims needing manual review
- **FAIL:** red block with evidence. If `--no-fail-closed` not set: regenerate affected sections using verifier's evidence. Otherwise report and let user decide.

## Output Block (append to report)

```markdown
## Post-Flight Verification

**Claims extracted:** N
**Verified independently:** N (forked claim-verifier)
**Outcome:** PASS | PARTIAL | FAIL → regenerated

### Discrepancies (regenerated)
### Unverifiable (user review recommended)
### Verified
| ID | Claim | Evidence |
```
