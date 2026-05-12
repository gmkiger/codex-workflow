---
name: lit-review
description: Structured literature search + synthesis with citation extraction, thematic clustering, gap identification. Trigger: "lit review on", "find papers on", "what's the literature on", "review recent work on".
argument-hint: "[topic, paper title, or research question] [--no-verify]"
---

# Literature Review

Structured search and synthesis on the given topic.

**Input:** `$ARGUMENTS` — topic, paper title, or research question.

## Steps

1. Parse topic from `$ARGUMENTS`. If a specific paper named, use as anchor.

2. Search for related work:
   - `master_supporting_docs/supporting_papers/` — uploaded papers
   - WebSearch for recent publications
   - WebFetch for working paper repositories (NBER, SSRN, arXiv)
   - Existing `Bibliography_base.bib` for already-cited papers

3. Organize findings:
   - **Theoretical contributions** — models, frameworks, mechanisms
   - **Empirical findings** — key results, effect sizes, data sources
   - **Methodological innovations** — estimators, identification strategies
   - **Open debates** — unresolved disagreements

4. Identify gaps and opportunities.

5. Extract BibTeX citations for all papers discussed.

6. Save report to `quality_reports/lit_review_[sanitized_topic].md`.

## Output Format

```markdown
# Literature Review: [Topic]
**Date:** YYYY-MM-DD
**Query:** [original query]

## Summary [2-3 paragraph overview]

## Key Papers
### [Author (Year)] — [Short Title]
- **Main contribution:** ...
- **Method:** [identification strategy / data]
- **Key finding:** [result with effect size]
- **Relevance:** [why it matters]

## Thematic Organization
### Theoretical / Empirical / Methodological

## Gaps and Opportunities
1. [Gap + why it matters]

## BibTeX Entries
```bibtex
@article{...}
```
```

## Post-Flight Verification (mandatory unless `--no-verify`)

Literature reviews are HIGH hallucination risk (WebSearch returns plausible-sounding fabricated citations).

1. Extract all citation claims and paraphrased findings from the draft.
2. Generate one specific verification question per claim.
3. Run claim-verifier subprocess (fresh context — do NOT pass the draft):
   ```bash
   ./scripts/run-workflow.sh --fork claim-verifier \
     "Claims: [claims list]" \
     "Questions: [verification questions]" \
     "Sources: [DOIs, URLs, file paths]"
   ```
4. Reconcile: PASS → return draft. PARTIAL → mark unverifiable claims. FAIL → correct contradicted citations.

Include Post-Flight block in the final report.
