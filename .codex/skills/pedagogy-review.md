---
name: pedagogy-review
description: Holistic pedagogical review of a lecture deck (.qmd or .tex). Checks narrative arc, prerequisites, worked examples, notation clarity, pacing. Trigger: "pedagogy review", "does this teach well", "flow right", "will students follow".
argument-hint: "[QMD or TEX filename]"
---

# Pedagogical Review of Lecture Deck

Holistic pedagogical review. Read-only — produces a report without editing.

## Steps

1. Read the lecture file in `$ARGUMENTS`.

2. Adopt the **pedagogy-reviewer** role by reading `.codex/agents/pedagogy-reviewer.md`. Apply the review protocol, checking:
   - **Narrative arc:** Is there a clear story from motivation → theory → application → conclusion?
   - **Prerequisite assumptions:** Are prerequisites stated? Is the cognitive load appropriate?
   - **Worked examples:** Do examples precede formal results? Are they fully worked through?
   - **Notation clarity:** Is notation introduced before use? Consistent throughout?
   - **Deck-level pacing:** Is there an appropriate mix of content types? Enough breathing room?
   - **Motivation:** Is every definition preceded by a motivating example (INV-8)?

3. Produce a report with findings organized by severity:
   - Critical (students will be lost)
   - Major (significantly impedes learning)
   - Minor (polish improvements)

4. Save report to `quality_reports/FILENAME_pedagogy_report.md`.

5. Do NOT edit source files. Recommendations only.
