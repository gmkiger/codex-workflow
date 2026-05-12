---
name: new-diagram
description: Scaffold a new TikZ diagram from the snippet gallery with prevention rules pre-applied. Compiles standalone, runs tikz-reviewer, loops until APPROVED. Trigger: "new diagram", "scaffold tikz", "create TikZ diagram".
argument-hint: "[snippet-name] [output.tex] (interactive if omitted)"
---

# Create a New TikZ Diagram

Scaffold from `templates/tikz-snippets/` to embed prevention invariants from the start.

> For extracting existing TikZ from a Beamer deck, use `/extract-tikz` instead.

## Step 1: Pick a Snippet

```bash
ls -1 templates/tikz-snippets/*.tex
```

Available snippets:
- `dag-basic` — 3-node causal DAG (X → Y with confounder U)
- `dag-mediation` — X → M → Y with direct path
- `did-two-period` — two-period difference-in-differences
- `event-study` — event-time coefficients with 95% CIs
- `timeline` — horizontal timeline with staggered events
- `regression-scatter` — scatter + OLS fit + confidence band
- `flowchart-3step` — vertical flow with decision diamond
- `supply-demand` — supply/demand with shifted demand

If `$ARGUMENTS` doesn't specify one, list gallery and ask user to pick.

## Step 2: Copy Snippet to Output Path

```bash
SRC="templates/tikz-snippets/$0.tex"
DST="${1:-Figures/new_diagram.tex}"
# Confirm before overwriting if $DST exists
mkdir -p "$(dirname "$DST")" && cp "$SRC" "$DST"
```

## Step 3: Customize Content

Edit `$DST` to fit the user's intent:
1. Update the intent sentence in the comment block
2. Update the coordinate map comment if coordinates change
3. Rename nodes and edit labels
4. **No bare `scale=X`** — use `scale=X, every node/.style={scale=X}` or `scale=X, transform shape` (P3)
5. **Every edge label must carry a directional keyword** (`above`, `below`, `left`, `right`) — `midway` alone is P4 violation

## Step 4: Prevention Pre-check (MANDATORY)

```bash
python3 scripts/check-tikz-prevention.py "$DST"
```

Exit 0 → continue. Exit 1 → fix violations and re-run. Exit 2 → usage error.

## Step 5: Standalone Compile

```bash
cd "$(dirname "$DST")"
xelatex -interaction=nonstopmode "$(basename "$DST")"
```

Check exit code and PDF size. Fix compile errors if any.

## Step 6: Visual Review via tikz-reviewer

Adopt the **tikz-reviewer** role (`.codex/agents/tikz-reviewer.md`). Review the `.tex` source and compiled PDF. Reviewer must cite specific passes and formulas from `.codex/rules/tikz-measurement.md` for each finding.

Loop (max 5 rounds, stop at APPROVED):
1. APPROVED → Step 7
2. NEEDS REVISION → fix `$DST`, re-run Step 4, recompile, re-review

## Step 7: Optional SVG for Quarto

```bash
pdf2svg "${DST%.tex}.pdf" "${DST%.tex}.svg" 1
```

Single-page diagram → single `.svg` with same basename.

## Step 8: Clean Up Build Artifacts

```bash
cd "$(dirname "$DST")" && rm -f *.aux *.log *.out *.synctex.gz
```

## Step 9: Report

Print: snippet used → output path → reviewer verdict → rounds → PDF/SVG sizes → reminder to `\includegraphics{}` in the target file.

## Cross-references

- `.codex/rules/tikz-prevention.md` — P1–P6 authoring rules
- `.codex/agents/tikz-reviewer.md` — review agent
- `templates/tikz-snippets/README.md` — gallery inventory
