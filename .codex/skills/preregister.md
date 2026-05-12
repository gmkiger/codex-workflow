---
name: preregister
description: Draft a preregistration document for OSF, AsPredicted, or AEA-RCT Registry. Trigger: "preregister", "draft preregistration", "OSF pre-reg", "AEA-RCT preregistration".
argument-hint: "[research spec or paper path] [--style osf|aspredicted|aea-rct]"
---

# Draft Preregistration

Draft a preregistration document from a research specification.

**Input:** `$ARGUMENTS` — a research spec, paper draft, or `/research-ideation` output. Flag `--style` selects format (default: osf).

## Formats

- **OSF (default):** Open Science Framework format — research question, hypotheses, design, outcome measures, analysis plan, sample size, exclusion criteria.
- **AsPredicted:** 9 core questions (existence of data, hypothesis, key dependent variable, conditions, analyses, outliers, sample size, studywide-alpha, anything else).
- **AEA-RCT:** American Economic Association Registry — RCT-specific fields: intervention, randomization unit, outcomes, power calculations, IRB status.

## Steps

1. Read the input document. If a research spec or `/research-ideation` output, extract the key elements. If a paper draft, extract from the methods section.

2. Draft the preregistration using `templates/preregistration-template.md` as base.

3. For each section, be specific:
   - **Hypotheses:** state the direction and expected magnitude, not just "X affects Y"
   - **Analysis plan:** specify the exact regression specification, including controls and clustering
   - **Sample restrictions:** exactly which observations will be excluded and why
   - **Primary vs secondary outcomes:** distinguish pre-specified from exploratory

4. Flag any ambiguities: sections where the spec is unclear → mark as `[NEEDS CLARIFICATION: ...]`

5. Save to `quality_reports/preregistration_[project_name]_[format].md`

## Principles

- Pre-registration creates commitment — every vague element gives you wiggle room (which is the problem)
- If you can't specify the exact regression, the research design isn't ready to pre-register
- Flag the difference between confirmatory and exploratory analyses explicitly
