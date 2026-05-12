---
name: slide-excellence
description: Multi-agent comprehensive slide review (visual + pedagogy + proofreading, plus TikZ / parity / substance conditionally). Trigger: "full review", "excellence pass", "comprehensive check", "slide excellence", before teaching/shipping.
argument-hint: "[QMD or TEX filename] [--fast] [--skip-substance | --acknowledge-template-domain-reviewer]"
---

# Slide Excellence Review

Comprehensive multi-dimensional review using sequential role-switching.

> For a single lens: use `/visual-audit`, `/pedagogy-review`, or `/proofread` directly.
> For adversarial Beamer↔Quarto parity: use `/qa-quarto`.

## Step 1: Identify the File

Parse `$ARGUMENTS` for the filename. Resolve path in `Quarto/` or `Slides/`.

## Step 2: Pre-flight — Detect Conditions

```bash
FILE="$resolved_path"
has_tikz=$(grep -c '\\begin{tikzpicture}' "$FILE" 2>/dev/null || echo 0)
# Check for .tex pair (if .qmd) or .qmd pair (if .tex)
# Check for R code chunks
```

Report what was detected before proceeding.

## Step 3: Domain Reviewer Customization Check

Before running substance review on `.tex`, check if `.codex/agents/domain-reviewer.md` has been customized:
- If it contains `AUTO-DETECT-TEMPLATE-MARKER` or `<!-- Customize: ... -->` placeholders → warn and offer: skip substance / proceed with template / customize first.
- Do NOT silently run template domain-reviewer.

## Step 4: Sequential Review Agents

Run each applicable agent in sequence (read the agent file, adopt role, produce output, save, return to orchestrating role):

**Always-on:**
- **Visual Audit** (`slide-auditor`): overflow, fonts, box fatigue, spacing → `quality_reports/[FILE]_visual_audit.md`
- **Pedagogical Review** (`pedagogy-reviewer`): narrative, prerequisites, worked examples → `quality_reports/[FILE]_pedagogy_report.md`
- **Proofreading** (`proofreader`): grammar, typos, consistency → `quality_reports/[FILE]_proofread_report.md`

**Conditional:**
- **TikZ Review** (`tikz-reviewer`) — only if `has_tikz > 0` → `quality_reports/[FILE]_tikz_review.md`
- **Content Parity** (`quarto-critic`) — only if counterpart file exists → `quality_reports/[FILE]_parity_report.md`
- **R Code Review** (`r-reviewer`) — only if R chunks present → `quality_reports/[FILE]_r_review.md`
- **Substance Review** (`domain-reviewer`) — MANDATORY for `.tex` (gated by Step 3) → `quality_reports/[FILE]_substance_review.md`

**`--fast` flag:** Skip separate agents; synthesize directly in one pass (cheaper, less thorough).

**`--skip-substance` flag:** Do not run the domain-reviewer substance pass. Use only when the file is layout-only or the project has no customized domain reviewer yet.

**`--acknowledge-template-domain-reviewer` flag:** Proceed with the template domain-reviewer despite Step 3 warnings. Report that substance findings are low-confidence until the reviewer is customized.

## Step 5: Synthesize Combined Summary

```markdown
# Slide Excellence Review: [Filename]
**Agents run:** [list]
## Overall Quality Score: [EXCELLENT / GOOD / NEEDS WORK / POOR]
| Dimension | Critical | Medium | Low |
### Critical Issues (Immediate Action)
### Medium Issues (Next Revision)
### Recommended Next Steps
```

## Quality Score Rubric

| Score | Critical | Medium |
|-------|----------|--------|
| Excellent | 0–2 | 0–5 |
| Good | 3–5 | 6–15 |
| Needs Work | 6–10 | 16–30 |
| Poor | 11+ | 31+ |
