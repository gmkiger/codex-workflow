---
name: data-analysis
description: End-to-end R data analysis pipeline — exploration → cleaning → regression → publication-ready tables and figures. Trigger: "analyze this dataset", "run regression on X", "explore this CSV", "full analysis workflow".
argument-hint: "[dataset path or analysis goal description]"
---

# Data Analysis Workflow

End-to-end R data analysis: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/county_panel.csv`) or a description of the analysis goal (e.g., "regress emissions on carbon policy with country fixed effects using panel data").

## Constraints

- Follow R code conventions in `scripts/AGENTS.md`
- Save all scripts to `scripts/R/` with descriptive names
- Save all outputs (figures, tables, RDS) to `scripts/R/_outputs/`
- `saveRDS()` for every computed object — Quarto slides may need them
- Use project theme for all figures
- Adopt **r-reviewer** role to review the generated script before presenting results

## Phase 0: Pre-Flight Report (MANDATORY)

Before writing any code, output:

```markdown
## Pre-Flight Report

**Dataset:** [path]
- Variables found: [list from names()]
- Rows: [count]
- Key types: [outcome=numeric, treatment=binary, state=factor]
- Missing-data summary: [% missing per key var]

**Project conventions read:** scripts/AGENTS.md (R standards)

**Task interpretation:** [one sentence]

**Plan:**
- [ ] Load and inspect data
- [ ] EDA: summary stats + distributions
- [ ] Main analysis: [regression specs]
- [ ] Tables + figures (modelsummary + ggplot2)
- [ ] Export (RDS + tex + png)
```

If any input cannot be read, STOP and ask before proceeding.

## Phase 1: Setup and Data Loading

Create R script with proper header. Load packages. Set seed. Load data. Inspect.

## Phase 2: Exploratory Data Analysis

- Summary statistics, missingness rates, variable types
- Histograms for key continuous variables
- Time patterns if panel data; group comparisons if treatment/control
- Save diagnostic figures to `scripts/R/_outputs/diagnostics/`

## Phase 3: Main Analysis

- Panel regressions: `fixest::feols()` — fast, flexible FE + clustering
- Staggered DiD / event studies: `fect` package
- Cluster at appropriate level; document why
- Multiple specifications: start simple, progressively add controls
- Report standardized effects alongside raw coefficients

## Phase 4: Publication-Ready Output

**Tables:** Use `modelsummary` — coefficients, SEs, significance stars, N, R²; export `.tex` + `.html`.

**Figures:** `ggplot2` + project theme; `bg = "transparent"`; explicit dimensions; both `.pdf` + `.png`.

## Phase 5: Save and Review

1. `saveRDS()` for all key objects
2. Adopt the **r-reviewer** role by reading `.codex/agents/r-reviewer.md`. Apply full review protocol to the generated script. Address any Critical or High issues.

## Long-Running Fits

For regressions/simulations taking >2 minutes:
1. Launch in background: `Rscript scripts/R/03_analyze.R > scripts/R/_outputs/run.log 2>&1 &`
2. Monitor: `tail -f scripts/R/_outputs/run.log`
3. Report progress to user as milestones appear in the log
