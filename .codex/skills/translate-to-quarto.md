---
name: translate-to-quarto
description: Translate a Beamer .tex lecture to a Quarto RevealJS .qmd mirror. Multi-phase: TikZ extraction → slide-by-slide translation → citation conversion → QA parity check. Trigger: "translate to quarto", "port to revealjs", "make html version".
argument-hint: "[LectureN_Topic.tex]"
---

# Beamer → Quarto Translation Workflow

Full translation of a Beamer LaTeX lecture to Quarto RevealJS HTML slides.

**CRITICAL: The Beamer .tex file is the SINGLE SOURCE OF TRUTH.**

## Phase 0: Pre-Flight Checks

**0A. Environment Parity Audit**
Scan Beamer for all custom environments (`keybox`, `definitionbox`, etc.). Verify CSS equivalents exist in `Quarto/theme-template.scss`. If any are missing, create them FIRST.

**0B. TikZ Freshness**
Run `/extract-tikz` to verify SVGs match current Beamer source.

**0C. RDS Data Inventory**
List all RDS files needed for interactive charts.

**0D. Citation Key Mapping**
Extract all citations from Beamer; map to `Bibliography_base.bib` keys.

## Phase 1: Pre-Translation Preparation

- Read complete Beamer source, count frames
- Inventory figures: TikZ → SVG, R plots → plotly/SVG, other → SVG

## Phase 2: Create QMD File with YAML Header

Standard RevealJS YAML with theme, bibliography, optional footer/logo.

## Phase 3: Slide-by-Slide Translation

Adopt the **beamer-translator** role by reading `.codex/agents/beamer-translator.md`. Follow its slide-by-slide protocol: 1:1 frame-to-slide mapping, verbatim math, environment parity, no font reduction.

## Phase 4: TikZ Diagram Integration

Reference extracted SVGs with 0-based indexing (e.g., `tikz_exact_00.svg`).

## Phase 5: R Figure Integration (Plotly-First)

Interactive plotly from RDS data, static SVG for TikZ/complex figures.

## Phase 6: First Render & Content Fidelity Check

```bash
quarto render Quarto/$ARGUMENTS.qmd
```

Count slides, check every slide for issues (overflow, missing content, broken math).

## Phase 6.5: Pedagogical Review

Adopt the **pedagogy-reviewer** role. Run the review protocol before visual polish.

## Phase 7: Visual Polish

Semantic colors, transition slides, framing sentences, `.smaller` class where needed.

## Phase 8: Proofreading

Run `/proofread` on the QMD file.

## Phase 9: Final Verification & Deployment

Render → open in browser → verify all elements → run `./scripts/sync_to_docs.sh LectureN`.

## Phase 10: Beamer Source Sync

Apply any content corrections back to Beamer source (SSOT).

## Phase 11: Documentation

Update `CLAUDE.md` lecture table, session log, create PR if ready.
