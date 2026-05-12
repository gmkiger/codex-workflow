---
name: research-ideation
description: Generate structured research questions, hypotheses, and candidate empirical strategies. Trigger: "research ideas on X", "brainstorm questions about Y", "what could I study with this data", "generate hypotheses for".
argument-hint: "[topic, phenomenon, or dataset description] [--no-verify]"
---

# Research Ideation

Generate structured research questions, testable hypotheses, and empirical strategies.

**Input:** `$ARGUMENTS` — topic (e.g., "carbon tax effects on firm location"), phenomenon, or dataset description.

## Steps

1. Understand the input. Check `master_supporting_docs/` for related papers. Check `.codex/references/discipline-cards.md` for field conventions.

2. Generate 3–5 research questions ordered from descriptive to causal:
   - **Descriptive:** What are the patterns?
   - **Correlational:** What factors are associated?
   - **Causal:** What is the effect?
   - **Mechanism:** Through what channel?
   - **Policy:** What are the implications?

3. Tag each RQ with paper type: `reduced-form` / `structural` / `theory+empirics` / `descriptive` / `formal-theory` / `survey-experiment` / `unsure`. Use `.codex/references/discipline-cards.md` to calibrate field frequencies.

4. For each RQ develop:
   - **Hypothesis:** testable prediction with expected sign/magnitude
   - **Identification strategy:** DiD, IV, RDD, synthetic control, etc.
   - **Data requirements:** what data, is it available?
   - **Key assumptions:** what must hold?
   - **Pitfalls:** threats to identification
   - **Related literature:** 2-3 papers using similar approaches

5. Rank by feasibility and contribution.

6. Save to `quality_reports/research_ideation_[sanitized_topic].md`.

## Post-Flight Verification (mandatory unless `--no-verify`)

Research ideation is hallucination-prone in three ways: negative-literature claims ("no prior work"), dataset structure claims (variable names, coverage years), and estimator feasibility claims.

Run claim-verifier subprocess:
```bash
./scripts/run-workflow.sh --fork claim-verifier \
  "Claims: [negative-lit claims + dataset claims + estimator claims]" \
  "Questions: [one specific question per claim]" \
  "Sources: [NBER/SSRN/IPUMS/dataset codebook URLs]"
```
Reconcile: PASS → attach block. PARTIAL → mark uncertain RQs. FAIL → rewrite affected section.

## Principles

- Creative but grounded — every suggestion must be empirically feasible
- Think like a referee: identify the identification challenge immediately
- Consider data availability — brilliant questions with no data are not actionable
- Suggest specific datasets (FRED, Census, PSID, administrative data)
