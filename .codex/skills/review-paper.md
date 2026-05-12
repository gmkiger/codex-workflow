---
name: review-paper
description: Comprehensive manuscript review — single-pass (default), --adversarial critic-fixer loop, --peer [journal] simulated peer-review pipeline. Trigger: "review paper", "manuscript review", "peer review this".
argument-hint: "[paper path] [--adversarial | --peer <journal> [--r2|--r3|--stress]] [--no-cross-artifact] [--no-novelty-check]"
---

# Manuscript Review

Thorough review of an academic manuscript — the kind a top-journal referee would write.

## Mode Selection

- **Default:** Single comprehensive report. Fast, suitable for early drafts.
- **`--adversarial`:** Critic-fixer loop (max 5 rounds) for pre-submission drafts.
- **`--peer <JOURNAL>`:** Simulated editorial pipeline (editor + 2 referees). Calibrated to journal from `.codex/references/journal-profiles.md`. Available: AER, QJE, JPE, ECMA, ReStud.
- **`--r2`/`--r3`:** R&R continuation (requires `--peer`).
- **`--stress`:** Hostile-editor mode — forces SKEPTIC dispositions.
- **`--no-cross-artifact`:** Skip code/reproducibility checks.
- **`--no-novelty-check`:** Skip WebSearch novelty probes.

## Steps (all modes)

1. **Locate and read the manuscript.** Strip flags to get bare path. Check: direct path, `master_supporting_docs/`, glob for partial matches.
2. **Read the full paper** end-to-end (for long PDFs, read in 5-page chunks).
3. **Evaluate across 6 dimensions** (below).
4. **Generate 3–5 referee objections** — the tough questions a top referee would ask.
5. **Produce review report.** Save: `quality_reports/paper_review_[name]_round[N].md`.
6. **Cross-artifact integration** (unless `--no-cross-artifact`): if manuscript references R scripts (via `\input{scripts/...}`, `%% source:` comments, or matching `_outputs/` filenames):
   - Adopt **r-reviewer** role → review each referenced script → save to `quality_reports/cross_artifact_[paper]/review_r_*.md`
   - Adopt **audit-reproducibility** role → check numeric claims → save to `quality_reports/cross_artifact_[paper]/reproducibility.md`
   - Merge critical cross-artifact findings into review report.

## Review Dimensions

1. **Argument Structure** — clear question, logical flow, supported conclusions
2. **Identification Strategy** — credible causal claim, stated assumptions, threats addressed
3. **Econometric Specification** — correct SEs, functional form, multiple testing
4. **Literature Positioning** — key papers cited, contribution differentiated
5. **Writing Quality** — clarity, academic tone, consistent notation
6. **Presentation** — self-contained tables/figures, consistent notation, appropriate length

## `--peer <JOURNAL>` Sequential Pipeline

**Phase 0: Cross-artifact pre-flight** (before desk review)
Run reproducibility audit first (see Step 6 above). Any FAIL is desk-reject evidence.

**Phase 1: Editor desk review**
Adopt the **editor** role (`.codex/agents/editor.md`). Read journal profile from `.codex/references/journal-profiles.md`. Run novelty probes via WebSearch (unless `--no-novelty-check`). Verify novelty claims before including in desk review. Either DESK REJECT (stop) or SEND OUT.

**CoVe for novelty claims:** For any WebSearch-sourced claim ("Smith 2022 already showed X"), use the claim-verifier subprocess:
```bash
./scripts/run-workflow.sh --fork claim-verifier \
  "Claims: [novelty claim]" \
  "Questions: [verification question]" \
  "Sources: [URLs or search results]"
```
Only verified claims enter the desk review narrative.

**Phase 2: Two referees (sequential)**
First: adopt **domain-referee** role (`.codex/agents/domain-referee.md`) with disposition D1 and peeves P1. Save: `quality_reports/peer_review_[paper]/referee_domain.md`.
Second: adopt **methods-referee** role (`.codex/agents/methods-referee.md`) with disposition D2 and peeves P2. Save: `quality_reports/peer_review_[paper]/referee_methods.md`.

**Phase 3: Editorial synthesis**
Return to editor role. Classify each MAJOR concern as FATAL / ADDRESSABLE / TASTE. Produce: `quality_reports/peer_review_[paper]/editorial_decision.md`.

## `--adversarial` Critic-Fixer Loop

```
Phase 0: Verify manuscript compiles; snapshot pre-review version (git stash or copy)
Phase 1: Critic audit → round-N report (zero Major Concerns + zero fatal ROs = APPROVED)
Phase 2: Fixer → propose edits grouped by severity → apply approved edits → re-compile
Phase 3: Fresh critic audit (no memory of prior rounds) → loop back (max 5)
```
After loop: write `quality_reports/paper_review_[name]_FINAL.md` with round summary.
