---
name: visual-audit
description: Adversarial visual-layout audit of .qmd or .tex deck. Flags overflow, font inconsistency, box fatigue, spacing issues. Trigger: "visual audit", "check layout", "does this overflow", "look for visual issues".
argument-hint: "[QMD or TEX filename]"
---

# Visual Audit of Slide Deck

Thorough visual layout audit. Does NOT check writing or pedagogy — pair with `/proofread` or `/pedagogy-review`.

## Steps

1. Read the slide file in `$ARGUMENTS`.

2. For Quarto (`.qmd`) files:
   - Render: `quarto render Quarto/$ARGUMENTS`
   - Inspect each slide in the rendered HTML

3. For Beamer (`.tex`) files:
   - Compile and check for overfull hbox warnings

4. Adopt the **slide-auditor** role by reading `.codex/agents/slide-auditor.md`. Audit every slide for:
   - **OVERFLOW:** Content exceeding slide boundaries
   - **FONT CONSISTENCY:** Inline size overrides, inconsistent sizes
   - **BOX FATIGUE:** 2+ colored boxes on one slide (INV-7)
   - **SPACING:** Missing negative margins, missing fig-align
   - **LAYOUT:** Missing transitions, missing framing sentences, semantic colors

5. Produce a report organized by slide with severity and recommendations.

6. Follow the spacing-first principle when recommending fixes:
   1. Reduce vertical spacing with negative margins
   2. Consolidate lists
   3. Move displayed equations inline
   4. Reduce image/SVG size
   5. Last resort: font size reduction (never below 0.85em)
