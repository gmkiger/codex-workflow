---
name: review-r
description: R code quality review for academic scripts. Checks reproducibility, domain correctness, figures, RDS pattern, numerical discipline. Trigger: "review R code", "check this script", "R code review".
argument-hint: "[script path or 'all']"
---

# R Code Review

Thorough code review of R scripts for academic research. Read-only — report only.

## Steps

1. Identify scripts to review from `$ARGUMENTS`.

2. Adopt the **r-reviewer** role by reading `.codex/agents/r-reviewer.md`. Apply its full protocol to each script:
   - Script structure and header
   - Console output hygiene
   - Reproducibility (`set.seed`, `library()`, relative paths, `dir.create()`)
   - Function design (snake_case, roxygen docs, no magic numbers)
   - Domain correctness (estimator matches theory, correct estimand, known pitfalls)
   - Figure quality (transparent bg, explicit dimensions, project theme, legend position)
   - RDS data pattern (`saveRDS()` for every computed object)
   - Comment quality (WHY not WHAT, no dead code)
   - Error handling (NA/NaN checks, parallel backend registration)
   - Professional polish (indentation, line length, pipe consistency)
   - Numerical discipline (no float `==`, CDF clamping, pre-allocation, explicit `na.rm`)

3. Save report to `quality_reports/[script_name]_r_review.md` using the format in the r-reviewer agent file.

4. Summarize: total issues by severity (Critical/High/Medium/Low).

5. **Do NOT edit source files.** Propose fixes in the report.
