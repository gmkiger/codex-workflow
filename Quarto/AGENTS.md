# Quarto/RevealJS Slides — Codex Context (Quarto/)

These rules apply when working on any `.qmd` or `.scss` file under `Quarto/`. They supplement the root `AGENTS.md`.

---

## Single Source of Truth

Beamer `.tex` files are authoritative. Quarto `.qmd` files derive from them. When content diverges, Beamer wins. HTML-only decorations (`.smaller`, `.scrollable`, plotly embeds) may exist only in Quarto and should not be overwritten during sync.

## Rendering and Deployment

```bash
# Render a single lecture and sync to docs/
./scripts/sync_to_docs.sh LectureN

# Render all lectures
for f in Quarto/*.qmd; do quarto render "$f"; done
```

Never commit raw HTML output to `Quarto/` — it belongs in `docs/` only. The `sync_to_docs.sh` script handles the move.

## Theme and Palette

- Theme file: `Quarto/theme-template.scss`
- Must stay in sync with `Preambles/header.tex` color definitions (INV-1)
- Check sync: `./scripts/check-palette-sync.sh`
- Styles that must override Bootstrap go in `include-in-header` as raw `<style>`, NOT in the SCSS file (INV-3)

## CSS Classes

| Class | Effect | Use |
|-------|--------|-----|
| `.smaller` | 85% font size | Dense content slides |
| `.positive` | Green, bold | Good/positive annotations |
| `.negative` | Red | Bad/negative annotations |
| `.emorygold` | Emory gold highlight | Key terms |
| `.muted` | Gray text | Secondary information |
| `.keybox` | Gold background callout | Key takeaways |
| `.definitionbox` | Blue-bordered box | Formal definitions |
| `.scrollable` | Scrollable slide | Long content |

*Update this table when adding new CSS classes to `theme-template.scss`.*

## TikZ Diagrams (INV-4 — non-negotiable)

- Browsers **cannot** display PDF images inline.
- All TikZ diagrams must be converted to SVG before embedding in `.qmd` files.
- Workflow: `/extract-tikz LectureN` → produces SVGs in `Figures/LectureN/`
- Include as: `![](../Figures/LectureN/diagram-name.svg)`
- Never use `![](../Figures/LectureN/diagram.pdf)` in a `.qmd`

**Freshness check:** Before using any TikZ SVG, verify the SVG was generated from the current Beamer source. Stale SVGs silently show outdated content.

## Math and Notation

- Math notation must be identical to the corresponding Beamer `.tex` slide (INV-2)
- Use `$$...$$` for display math, `$...$` for inline
- MathJax renders in RevealJS — most LaTeX math works directly
- Exceptions: some custom Beamer macros (`\key{}`, `\muted{}`) need explicit translation to CSS spans

## Quarto YAML Front Matter

Required fields for all lecture `.qmd` files:

```yaml
---
title: "Lecture N: [Topic]"
subtitle: "[Course name]"
author: "[Your name]"
date: "[YYYY-MM-DD]"
format:
  revealjs:
    theme: [default, theme-template.scss]
    slide-number: true
    preview-links: auto
    include-in-header:
      text: |
        <style>
        /* CSS overrides that must beat Bootstrap cascade */
        </style>
bibliography: ../Bibliography_base.bib
---
```

## Verification Checklist

After any Quarto edit:
```
[ ] quarto render runs without errors
[ ] All TikZ references use .svg (not .pdf)
[ ] Math notation matches Beamer .tex exactly
[ ] CSS class table in Quarto/AGENTS.md updated if new classes added
[ ] Palette sync verified (./scripts/check-palette-sync.sh)
[ ] Deployed via sync_to_docs.sh and visually checked in browser
```
