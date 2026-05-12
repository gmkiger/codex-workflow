# LaTeX/Beamer Slides — Codex Context (Slides/)

These rules apply when working on any `.tex` file under `Slides/`. They supplement the root `AGENTS.md`.

---

## Compilation (always 3-pass XeLaTeX)

```bash
cd Slides
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode FILE.tex
BIBINPUTS=..:$BIBINPUTS bibtex FILE
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode FILE.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode FILE.tex
```

- **Always XeLaTeX** — never pdflatex. The Beamer theme requires XeLaTeX.
- `TEXINPUTS=../Preambles:$TEXINPUTS` is required — the theme header lives in `Preambles/`.
- `BIBINPUTS=..:$BIBINPUTS` is required — `Bibliography_base.bib` lives in the repo root.
- After compilation, check for `Overfull \\hbox` warnings and undefined citations.

## Beamer Authoring Rules

### No overlays (INV-6 — non-negotiable)

`\pause`, `\onslide`, `\only`, `\uncover`, `\visible` are **forbidden**. Every occurrence is a bug.

Use multiple slides for progressive builds. Use color emphasis for attention. Use standout slides for pacing. If any tool or co-author suggests adding `\pause`, reject it.

### Single bibliography (INV-5)

The only `.bib` file is `Bibliography_base.bib` in the repo root. Never create a per-lecture `.bib` file. All `\cite{}` keys must resolve against this one file.

### Custom environments

| Environment | Syntax | Effect | Use |
|-------------|--------|--------|-----|
| `keybox` | `\begin{keybox}...\end{keybox}` | Gold background box | Key takeaways |
| `definitionbox` | `\begin{definitionbox}[Title]...\end{definitionbox}` | Blue-bordered titled box | Formal definitions |

Maximum 2 colored boxes per slide (INV-7). More creates "box fatigue."

### Slide design

- Every definition must be preceded by a motivating example or intuition (INV-8).
- Dense math: use `\small` or `\footnotesize` sparingly; prefer splitting across slides.
- No overfull hboxes: if text overflows a slide, restructure the content.

## TikZ Diagrams

### Prevention first

Before creating a new TikZ diagram, check whether an existing one in the repository can be reused or adapted. New TikZ from scratch is high-effort and high-risk.

### Size and layout rules

- All TikZ coordinates must be verified to avoid label overlaps.
- Font sizes in TikZ must be readable at projection: `\small` minimum, `\normalsize` preferred.
- Bounding boxes must be explicitly set or verified — stray coordinates create overfull hboxes.

### SVG export for Quarto (INV-4)

When a TikZ diagram is used in a corresponding `.qmd` file:
1. Export via `/extract-tikz` workflow → produces SVG
2. **Never embed a `.pdf` in a `.qmd`** — browsers cannot render PDFs inline
3. Place SVG in `Figures/LectureN/` and sync via `sync_to_docs.sh`

## Beamer↔Quarto Auto-Sync

Every edit to a `.tex` file must be synced to the corresponding `.qmd` in the same task (see root `AGENTS.md` §5 for the full protocol). Do not wait to be asked.

**LaTeX → Quarto translation reference:**

| Beamer | Quarto |
|--------|--------|
| `\muted{text}` | `[text]{style="color: #525252;"}` |
| `\key{text}` | `[**text**]{.emorygold}` |
| `\textcolor{positive}{text}` | `[text]{.positive}` |
| `\textcolor{negative}{text}` | `[text]{.negative}` |
| `\begin{keybox}` | `::: {.keybox}` |
| `\begin{definitionbox}[T]` | `::: {.definitionbox}` with `**T**` heading |
| `\item text` | `- text` |
| `$formula$` | `$formula$` |

## Verification Checklist

After any Beamer edit:
```
[ ] 3-pass xelatex compilation succeeds
[ ] No overfull hbox warnings
[ ] No undefined citations
[ ] No \pause or overlay commands
[ ] Quarto .qmd counterpart updated in same task
[ ] PDF opened and visually verified
```
