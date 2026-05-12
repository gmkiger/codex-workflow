---
name: deploy
description: Render Quarto .qmd slides to HTML and sync to docs/ for GitHub Pages. Trigger: "deploy", "publish slides", "ship to pages", "push lecture live".
argument-hint: "[LectureN or 'all']"
---

# Deploy Slides to GitHub Pages

Render Quarto slides and sync to `docs/` for GitHub Pages deployment.

## Steps

1. Run the sync script:
   - With argument: `./scripts/sync_to_docs.sh $ARGUMENTS`
   - Without argument: `./scripts/sync_to_docs.sh` (syncs all)

2. Verify deployment:
   - HTML files exist in `docs/slides/`
   - `_files/` directories were copied (RevealJS assets)
   - `docs/Figures/` was synced from `Figures/`

3. Verify interactive charts (if applicable):
   - Grep HTML for interactive widget count

4. Verify TikZ SVGs (if applicable):
   - All referenced SVG files exist in `docs/Figures/LectureN/`

5. Open in browser:
   ```bash
   open docs/slides/LectureX_Name.html     # macOS
   xdg-open docs/slides/LectureX_Name.html # Linux
   ```
   Confirm slides render, images display, navigation works.

6. Report results to user.

## What the sync script does
- Renders all `.qmd` files in `Quarto/` (skips `*_backup*`)
- Copies HTML and `_files/` to `docs/slides/`
- Copies Beamer PDFs from `Slides/` to `docs/slides/`
- Syncs `Figures/` to `docs/Figures/` via rsync
