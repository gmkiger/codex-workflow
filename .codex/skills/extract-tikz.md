---
name: extract-tikz
description: Extract TikZ diagrams from Beamer .tex source, compile each to standalone PDF, convert to SVG with 0-based indexing. Trigger: "extract tikz", "regenerate diagrams", "rebuild SVGs", "sync tikz to quarto".
argument-hint: "[LectureN, e.g., Lecture2]"
---

# Extract TikZ Diagrams to SVG

Extract TikZ diagrams from Beamer source, compile to multi-page PDF, convert each page to SVG.

> Creating a brand-new diagram? Use `/new-diagram` which scaffolds from templates with prevention rules pre-applied.

## Step 0: Freshness Check (MANDATORY)

Verify `extract_tikz.tex` matches the current Beamer source:
1. Find Beamer source: `ls Slides/$ARGUMENTS*.tex`
2. Extract all `\begin{tikzpicture}` blocks from Beamer
3. Compare with `Figures/$ARGUMENTS/extract_tikz.tex`
4. If any difference: update extract_tikz.tex from Beamer source
5. If extract_tikz.tex doesn't exist: create it from scratch

## Step 1: Prevention Pre-check (MANDATORY)

```bash
python3 scripts/check-tikz-prevention.py "Figures/$ARGUMENTS/extract_tikz.tex"
```

Checks P3 (scale without node scaling) and P4 (directional keyword on edge labels). If exit non-zero: halt and report violations. Do NOT compile.

## Step 2: Navigate and Compile

```bash
cd Figures/$ARGUMENTS
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode extract_tikz.tex
```

## Step 3: Count Pages

```bash
pdfinfo extract_tikz.pdf | grep "Pages:"
```

## Step 4: Convert to SVG (0-BASED INDEXING — CRITICAL)

PDF pages are 1-indexed; output SVG files are 0-indexed.

```bash
PAGES=$(pdfinfo extract_tikz.pdf | grep "Pages:" | awk '{print $2}')
for i in $(seq 1 $PAGES); do
  idx=$(printf "%02d" $((i-1)))
  pdf2svg extract_tikz.pdf tikz_exact_$idx.svg $i
done
```

## Step 5: Sync to docs/

```bash
cd ../..
./scripts/sync_to_docs.sh $ARGUMENTS
```

## Step 6: Verify SVGs

Read 2-3 SVG files to confirm valid SVG markup; check file sizes are non-zero.

## Step 7: Visual Quality Review

Adopt the **tikz-reviewer** role by reading `.codex/agents/tikz-reviewer.md`. Apply the review protocol to the TikZ source blocks. If NEEDS REVISION or REJECTED:
1. Fix the Beamer `.tex` source (single source of truth)
2. Re-copy block to extract_tikz.tex
3. Re-run prevention pre-check and compile
4. Regenerate SVGs, re-sync
5. Re-review (max 5 rounds, stop at APPROVED)

## Source of Truth
TikZ diagrams MUST be edited in the Beamer `.tex` first, then copied to `extract_tikz.tex`.
