---
name: compile-latex
description: Compile a Beamer LaTeX slide deck with XeLaTeX (3 passes + bibtex). Trigger: "compile", "build slides", "run latex", "render the tex".
argument-hint: "[filename without .tex extension]"
---

# Compile Beamer LaTeX Slides

Compile a Beamer slide deck using XeLaTeX with full citation resolution.

## Steps

1. Navigate to `Slides/` and run the 3-pass sequence:

```bash
cd Slides
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
BIBINPUTS=..:$BIBINPUTS bibtex $ARGUMENTS
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
```

2. Check for warnings:
   - `Overfull \hbox` warnings → flag each one
   - `undefined citations` or `Label(s) may have changed`

3. Open the PDF for visual verification:
   ```bash
   open Slides/$ARGUMENTS.pdf          # macOS
   xdg-open Slides/$ARGUMENTS.pdf      # Linux
   ```

4. Report: compilation success/failure, overfull count, undefined citations, page count.

## Why 3 passes?
1. First xelatex: creates `.aux` with citation keys
2. bibtex: reads `.aux`, generates `.bbl`
3. Second xelatex: incorporates bibliography
4. Third xelatex: resolves all cross-references

## Rules
- **Always XeLaTeX** — never pdflatex
- `TEXINPUTS=../Preambles:$TEXINPUTS` required — theme lives in `Preambles/`
- `BIBINPUTS=..:$BIBINPUTS` required — `Bibliography_base.bib` in repo root
