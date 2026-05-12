---
name: validate-bib
description: Validate bibliography entries against citations in all lecture files. Structural checks (missing/unused, malformed fields) by default; --semantic adds citation-drift detection, DOI verification, style-consistency. Trigger: "validate bibliography", "check citations", "bib errors".
argument-hint: "[--semantic] [--skip-doi] [--cite-claim]"
---

# Validate Bibliography

Cross-reference citations in lecture files against `Bibliography_base.bib`. Two modes.

## Mode 1: Structural (default)

1. Read `Bibliography_base.bib` and extract all citation keys.

2. Scan lecture files for citation keys:
   - `.tex`: `\cite{`, `\citet{`, `\citep{`, `\citeauthor{`, `\citeyear{`, `\textcite{`, `\parencite{`
   - `.qmd`/`.md`: `@key`, `[@key]`, `[@key1; @key2]`

3. Cross-reference:
   - **Missing entries (CRITICAL):** cited in lectures, absent from `.bib`
   - **Unused entries (INFO):** in `.bib` but never cited
   - **Typo candidates:** keys within edit-distance 2 of a `.bib` key

4. Check entry quality: required fields present (author, title, year, journal), year 1900-current, no malformed characters, DOI normalized.

5. Save: `quality_reports/bib_audit_structural.md`

## Mode 2: Semantic (`--semantic`)

Everything in Mode 1, plus:

**Citation drift detection:**
- Same DOI across keys → CRITICAL
- Same title (case-insensitive) → CRITICAL
- Same author+year+journal → MEDIUM

**DOI verification (WebFetch, skip with `--skip-doi`):**
- Fetch `https://api.crossref.org/works/{doi}`
- Compare author, year, title, journal
- Author/title mismatch → CRITICAL; year mismatch → MEDIUM; journal → LOW
- Rate limit: 50 lookups, 0.5s delay. Cache in `quality_reports/.doi_cache.json`

**Style consistency:** Flag files mixing `\citet`/`\citep` without pattern.

**Cite-claim sanity (`--cite-claim`):** For top-10 cited works, surface crossref abstract beside in-text context. No auto-judgment.

Save: `quality_reports/bib_audit_semantic.md`

## Files Scanned

```
Slides/*.tex
Quarto/*.qmd
guide/*.qmd
master_supporting_docs/**/*.tex
```

## Exit Behavior

- Structural: exit 0; enumerate issues
- Semantic: exit 0 if only LOW; exit 1 on any CRITICAL (usable as pre-submission gate)
