---
name: proofread
description: Read-only proofreading pass over lecture .tex or .qmd files. Checks grammar, typos, overflow, terminology, academic quality. Trigger: "proofread", "check typos", "grammar issues", "copy-edit".
argument-hint: "[filename or 'all']"
---

# Proofread Lecture Files

Read-only protocol — produces a report WITHOUT editing source files.

## Steps

1. Identify files to review:
   - Specific filename in `$ARGUMENTS`: review that file only
   - "all": review all lecture files in `Slides/` and `Quarto/`

2. Adopt the **proofreader** role by reading `.codex/agents/proofreader.md`. Apply the review protocol to each file, checking:
   - **GRAMMAR:** Subject-verb agreement, articles, prepositions, tense
   - **TYPOS:** Misspellings, search-replace artifacts, duplicated words
   - **OVERFLOW:** Overfull hbox (LaTeX), content exceeding slide boundaries (Quarto)
   - **CONSISTENCY:** Citation format, notation, terminology
   - **ACADEMIC QUALITY:** Informal language, missing words, awkward constructions

3. Produce a detailed report for each file:
   - Location (line number or slide title)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. Save each report to `quality_reports/`:
   - `.tex` files: `quality_reports/FILENAME_report.md`
   - `.qmd` files: `quality_reports/FILENAME_qmd_report.md`

5. **Do NOT edit source files.** Report only.

6. Present summary: total issues per file, breakdown by category, critical issues highlighted.
