---
name: audit-reproducibility
description: Cross-check numeric claims in a manuscript against actual R outputs. Report PASS/FAIL per claim against tolerance thresholds. Trigger: "audit reproducibility", "check paper vs code", "replication audit".
argument-hint: "[manuscript path] [outputs-dir defaults to scripts/R/_outputs/]"
---

# Audit Reproducibility

Compare numeric claims in a manuscript against actual pipeline outputs. Report PASS/FAIL per claim.

**Core principle:** If the paper says `ATT = -1.632 (0.584)` and the code produces `-1.628 (0.591)`, verify numerically that the difference is within documented tolerance.

## Phase 0: Pre-flight

1. Read `.codex/rules/replication-protocol.md` for tolerance thresholds.
2. Verify outputs directory exists and is non-empty. If stale (older than manuscript), prompt user to re-run pipeline first.
3. Check for `sessionInfo.txt` or equivalent environment capture in outputs dir.

## Phase 1: Extract Claims from Manuscript

Parse for numeric claims:
- Point-estimate + SE: `ATT = -1.632 (0.584)`, `$\beta = 0.342$ (0.091)`
- Table cells: `& -1.632$^{***}$ & 0.584 &`
- Counts: `our sample of 2,847 firms`, `$N = 2{,}847$`
- P-values: `p < 0.01`, `$p = 0.003$`

Save extracted claims to `quality_reports/reproducibility_claims_[manuscript-name].json`.

## Phase 2: Extract Results from Outputs

Priority order:
1. `.rds` files — use `Rscript -e "saveRDS(readRDS(...)$coef, '/tmp/audit.rds')"`
2. `.tex` tables — parse LaTeX table cells
3. `.csv` summary files
4. `.out`/`.log` files (Stata/R output)

## Phase 3: Match Claims to Results

Fuzzy matching on name similarity and magnitude. Claims below 0.7 confidence → "UNMATCHED — manual review needed."

## Phase 4: Tolerance Check

| Kind | Tolerance |
|------|-----------|
| Integers (N, counts) | Exact |
| Point estimates | `abs(reported - computed)` < 0.01 |
| Standard errors | `abs(reported - computed)` < 0.05 |
| P-values | Same significance level |
| Percentages | ±0.1pp |

## Phase 5: Report

Save `quality_reports/reproducibility_audit_[manuscript-name].md`:
- Summary: PASS/FAIL/UNMATCHED counts + overall verdict
- PASS table (all within tolerance)
- FAIL table (BLOCKER — outside tolerance)
- UNMATCHED (manual review needed)
- Environment excerpt

## Exit Behavior

- All PASS → continue
- Any FAIL → report as blocker (git pre-commit hook uses this)
- UNMATCHED > 0 with 0 FAIL → warn, user must manually verify

## Long Batch Reruns

For full pipeline reruns taking >2 minutes:
```bash
Rscript scripts/R/00_run_all.R > scripts/R/_outputs/rerun.log 2>&1 &
tail -f scripts/R/_outputs/rerun.log
```
React to errors mid-stream rather than waiting for completion.
