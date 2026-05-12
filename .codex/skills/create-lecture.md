---
name: create-lecture
description: Scaffold a full lecture from scratch — Beamer .tex file, Quarto .qmd mirror, and session setup. Trigger: "create lecture", "new lecture", "scaffold lecture N".
argument-hint: "[LectureN: title and topic description]"
---

# Create Lecture

Scaffold a complete new lecture including Beamer `.tex`, Quarto `.qmd`, and project registration.

## Phase 0: Pre-Flight

1. Parse `$ARGUMENTS` for lecture number and title.
2. Check existing lectures in `Slides/` to avoid numbering conflicts.
3. Output Pre-Flight Report:
   - Proposed filename: `Slides/LectureN_Title.tex` / `Quarto/LectureN_Title.qmd`
   - Lecture number and position in the sequence
   - Topic description and intended content

Ask user to confirm before creating files.

## Phase 1: Create Beamer Source

Create `Slides/LectureN_Title.tex` with:
- Full preamble (`\input{header}`)
- Title slide
- Outline/roadmap slide
- Placeholder content sections (3-5 frames minimum)
- Follow `Slides/AGENTS.md` rules: no `\pause`, single bibliography, max 2 boxes/slide

## Phase 2: Create Quarto Mirror

Create `Quarto/LectureN_Title.qmd` with:
- Full YAML header (title, author, date, format: revealjs, bibliography)
- Content mirroring the Beamer source
- CSS classes where needed
- Follow `Quarto/AGENTS.md` rules

## Phase 3: Register Lecture

1. Add to the lecture table in `AGENTS.md`:
   ```markdown
   | N: [Title] | `Slides/LectureN_Title.tex` | `Quarto/LectureN_Title.qmd` | [brief description] |
   ```

2. Update `CLAUDE.md` lecture table similarly.

3. Create session log entry: `quality_reports/session_logs/YYYY-MM-DD_lecture-N-creation.md`

## Phase 4: Verify

1. Compile Beamer: 3-pass xelatex
2. Render Quarto: `quarto render Quarto/LectureN_Title.qmd`
3. Report: compilation success, page counts, any warnings

## Phase 5: Document

Create the first session log entry with: lecture goals, content outline, planned analysis scripts (if any).
