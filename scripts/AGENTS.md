# R Scripts — Codex Context (scripts/)

These rules apply when working on any file under `scripts/`. They supplement the root `AGENTS.md`.

---

## R Code Standards

### Reproducibility (non-negotiable)

- `set.seed(YYYYMMDD)` exactly once at the top of every script — never inside loops or functions (INV-9)
- All `library()` calls at the top; never `require()`
- All paths relative to repository root (INV-10); no `~`, no `/Users/...`
- `dir.create("scripts/R/_outputs/...", recursive = TRUE, showWarnings = FALSE)` before any output write
- Script must run cleanly from `Rscript` on a fresh clone

### Preferred stack

```r
library(tidyverse)     # dplyr, ggplot2, readr, tidyr, stringr
library(modelsummary)  # regression tables (preferred over stargazer)
# [YOUR-PACKAGES]      # e.g., fixest (panel FE), survival (survival analysis), lme4 (mixed models)
```

### Script header (required)

```r
# ============================================================
# [Descriptive Title]
# Author: [name]
# Purpose: [what this script does]
# Inputs:  [data files]
# Outputs: [figures, tables, RDS files]
# ============================================================
```

### Numbered sections (required)

```r
# 0. Setup ----
# 1. Data Loading ----
# 2. Exploratory Analysis ----
# 3. Main Analysis ----
# 4. Tables and Figures ----
# 5. Export ----
```

### Figure standards

```r
ggsave(path, width = 12, height = 5, bg = "transparent")  # always transparent (INV-11)
# Apply custom project theme to every plot (INV-12)
theme_custom <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(plot.title = element_text(face = "bold"), legend.position = "bottom")
}
```

Save figures as both `.pdf` (for Beamer) and `.png` (for quick view).

### RDS data pattern

```r
saveRDS(result, file.path("scripts/R/_outputs", "descriptive_name.rds"))
```

Every computed object gets a `saveRDS()`. Missing saves break Quarto slide rendering.

### Numerical discipline

- **No float `==`**: use `all.equal()` or `abs(a - b) < tol`
- **CDF clamping**: `eps <- 1e-12; pmin(1 - eps, pmax(eps, p))` before `qnorm()` / `pbinom()`
- **Pre-allocate**: `numeric(n)` or `vector("list", n)` before loops — never `c(vec, new_val)`
- **Integer literals for counts**: `1L`, `nrow(df)` not bare `1`
- **Explicit `na.rm`**: always pass `na.rm = TRUE` or `FALSE` to `mean()`, `sd()`, `sum()`
- **No `T`/`F`**: always write `TRUE` / `FALSE`
- **Bootstrap seed**: set before the loop; for parallel, use `RNGkind("L'Ecuyer-CMRG")`

### Console output hygiene

- Use `message()` sparingly — one per major section maximum
- Never `cat()`, `print()`, or `sprintf()` for status/progress in production code
- No ASCII-art banners; no per-iteration printing inside loops

### Function design

- `snake_case` names, verb-noun pattern (`run_simulation`, `compute_effect`)
- Roxygen-style documentation for every non-trivial function
- Default parameters for all tuning values; no magic numbers

---

## Replication Protocol (summary — full details in `.codex/rules/replication-protocol.md`)

Before extending any analysis, replicate the original results to the dot:
1. Record gold-standard numbers in `quality_reports/LectureNN_replication_targets.md`
2. Match original specification exactly (covariates, sample, clustering, SE method)
3. Verify against tolerance thresholds (point estimates < 0.01, SEs < 0.05, N exact)
4. Only commit extensions after all targets PASS

**Cross-software replication traps:**
- Clustering / SE adjustments differ across implementations — verify df corrections match
- FE/demeaning methods differ across software — confirm the algorithm matches
- Bootstrap: match seed, number of replications, and bootstrap type exactly
- Missing data handling: confirm `na.omit()` / listwise deletion matches original software

---

## Long-Running Jobs

For R scripts that run more than ~2 minutes:
1. Launch in background: `Rscript scripts/R/03_analyze.R > _outputs/run.log 2>&1 &`
2. Monitor: `tail -f scripts/R/_outputs/run.log`
3. Report milestone output to the user as it appears

---

## Quality Checklist (R scripts)

```
[ ] Packages at top via library()
[ ] set.seed() once at top (YYYYMMDD)
[ ] All paths relative
[ ] Functions documented (Roxygen)
[ ] Figures: transparent bg, explicit dimensions, project theme
[ ] RDS: every computed object saved
[ ] Comments explain WHY not WHAT
[ ] Numerical discipline: no float ==, CDF clamping, pre-allocated vectors
[ ] Console output: no cat()/print() for status
```
