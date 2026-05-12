# My OpenAI Codex CLI Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/See-CHANGELOG-blue.svg)](CHANGELOG.md)
[![Contributing](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.github/CONTRIBUTING.md)

> **Actively maintained.** A summary of how I use the OpenAI Codex CLI for academic work — slides, papers, data analysis, and more — packaged so you can fork it for your own research. See [CHANGELOG.md](CHANGELOG.md) for the latest changes.
>
> **Using Claude Code instead?** See [README-claude.md](README-claude.md) for the Claude Code version. Both CLIs coexist in this repo — you can use either or switch between them.

A ready-to-fork foundation for AI-assisted academic work using the [OpenAI Codex CLI](https://github.com/openai/codex). You describe what you want — lecture slides, a research paper, a data analysis, a replication package — and Codex plans the approach, steps through specialized agent roles, fixes issues, verifies quality, and presents results. Like a contractor who handles the entire job. Extracted from a production PhD course and extended by a growing community.

---

## Quick Start (5–10 minutes, plus ~30 min for first-time installs)

> **Before you start:** Codex CLI + git are the minimum. To run the included `HelloWorld` demos end-to-end you also need XeLaTeX (Beamer sample) and Quarto (Quarto sample). R and the GitHub CLI are recommended. Python 3 is used by a few internal scripts (`check-palette-sync.py`, `check-tikz-prevention.py`, `quality_score.py`) and is pre-installed on macOS/Linux. Full list in [Prerequisites](#prerequisites) below. Fastest path: clone first, then run `./scripts/validate-setup.sh` — it reports exactly what's missing with install links.
>
> **Only need Python/R/markdown?** You don't need XeLaTeX or Quarto. The agents, rules, skills, and orchestration patterns work for any text/code artifact. Skip the `HelloWorld` demos and head straight to `data-analysis`, `review-paper`, `lit-review`, or `review-r`.
>
> **Session 2 onwards:** [MEMORY.md](MEMORY.md) (committed) collects generic `[LEARN]` entries that help all forkers; `.codex/state/personal-memory.md` (gitignored) is for machine-specific notes. See [`.claude/rules/meta-governance.md`](.claude/rules/meta-governance.md) for the distinction (the governance rules are shared between both CLIs).

### 1. Fork & Clone

```bash
# Fork this repo on GitHub (click "Fork" on the repo page), then:
git clone https://github.com/YOUR_USERNAME/codex-workflow.git my-project
cd my-project
npm install -g @openai/codex          # install the Codex CLI if not already present
./scripts/validate-setup.sh           # reports missing tools with install links
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Start a Session

```bash
./scripts/codex.sh
```

This launcher sets the model (`gpt-4.1`), approval mode (`full-auto`), and runs the session-init hook — which prints your active plan and most recent session log so every session starts oriented.

> **Approval mode:** `--approval-mode full-auto` lets Codex run without prompting for every tool call — equivalent to Claude Code's Bypass mode. For interactive approval on each step, run `codex --model gpt-4.1` directly. The `scripts/codex.sh` launcher hard-codes `full-auto`; edit the file to change this default.

Then paste the starter prompt, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2–3 sentences.]** I've set up the Codex CLI academic workflow. Please read `AGENTS.md` and the configuration files and adapt them for my project. Enter plan mode and start.

**What this does:** Codex reads `AGENTS.md` (your system prompt), plus path-specific `scripts/AGENTS.md`, `Slides/AGENTS.md`, and `Quarto/AGENTS.md` depending on which files it touches. It then enters contractor mode — planning, implementing, and (within the skill you invoke) running the review + verify loop. You approve the plan, name a skill, and the skill handles the rest within its scope.

### 3. Verify Your Setup

Before building real lectures, confirm your environment works:

```bash
./scripts/validate-setup.sh        # Checks XeLaTeX, Quarto, Python, git, etc.
```

Then inside a Codex session:

```text
Run the compile-latex skill on HelloWorld
Run the deploy skill on HelloWorld
```

If both succeed, delete `Slides/HelloWorld.tex` and `Quarto/HelloWorld.qmd` and start on your real work.

---

## How It Works

### Contractor Mode

You describe a task. For complex or ambiguous requests, Codex first creates a requirements specification with MUST/SHOULD/MAY priorities and clarity status (CLEAR/ASSUMED/BLOCKED). You approve the spec, then Codex plans the approach and works through the right skill (e.g. `create-lecture`, `qa-quarto`, `review-paper --adversarial`). That skill implements the orchestrator pattern internally — implement, verify, review, fix, re-verify, score — and returns a summary when the work meets quality standards. Say "just do it" and it auto-commits when the score clears 80.

### Sequential Agent Roles

Instead of one general-purpose reviewer, 14 focused agents each check one dimension. Codex adopts each role in sequence by reading the agent's `.md` file, producing its review, saving output to disk, and returning to orchestrating role — no API-level spawning required. A representative sample:

- **proofreader** — grammar/typos
- **slide-auditor** — visual layout
- **pedagogy-reviewer** — teaching quality
- **r-reviewer** — R code quality
- **domain-reviewer** — field-specific correctness, slides (template — customize for your field)
- **domain-referee** / **methods-referee** / **editor** — manuscript peer-review pipeline (`review-paper --peer`)

Each is better at its narrow task than a generalist would be. The `slide-excellence` skill steps through the slide-review agents in sequence; `review-paper --peer` steps through the paper-review pipeline. The same pattern extends to any academic artifact — manuscripts, data pipelines, proposals.

> **Context isolation for fact-checking:** The `verify-claims` skill uses a different pattern — it spawns a fresh `codex` subprocess via `scripts/run-workflow.sh --fork claim-verifier`. The subprocess sees only the agent instructions, extracted claims, and source material — never the original draft. This is the Chain-of-Verification (CoVe) independence trick: the verifier cannot rationalize existing text because it has never seen it.

### Adversarial QA

Two agent roles work in opposition: the **quarto-critic** reads both Beamer and Quarto and produces harsh findings. The **quarto-fixer** implements exactly what the critic found. Codex steps through them in sequence, looping until the critic returns "APPROVED" (or 5 rounds max). This catches errors that single-pass review misses.

### Quality Review

Every artifact gets a score (0–100). Scores below threshold halt the workflow and surface the findings — the user decides whether to fix or explicitly override:

- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

> **Hard enforcement:** Unlike the advisory `/commit` skill in the Claude Code version, this template ships a `.git/hooks/pre-commit` hook that blocks any direct `git commit` if a staged `.tex`, `.qmd`, or `.R` file scores below 80. This runs `scripts/quality_score.py` on staged files before every commit — whether you use the Codex skill or commit directly. Override with `git commit --no-verify -m "override: [reason]"` when you have a documented reason.

### Context Survival

Plans, specifications, and session logs survive session boundaries. The `scripts/codex.sh` launcher calls `.codex/hooks/session-init.sh` at startup — it finds the most recent non-completed plan and most recent session log and prints them, so every session starts oriented. MEMORY.md accumulates learning across sessions. Plans are saved to `quality_reports/plans/` and session logs to `quality_reports/session_logs/` where they persist indefinitely.

### Path-Scoped Rules via AGENTS.md Stacking

Codex CLI natively reads and stacks `AGENTS.md` files from the working directory upward to the git root. This means:

- When working on `scripts/` files → Codex also loads `scripts/AGENTS.md` (R conventions, numerical discipline, long-running job patterns)
- When working on `Slides/` files → Codex also loads `Slides/AGENTS.md` (3-pass XeLaTeX, no-pause rule, Beamer environments)
- When working on `Quarto/` files → Codex also loads `Quarto/AGENTS.md` (Beamer SSOT, SVG requirement, palette sync)

No custom loading mechanism needed — this is Codex's native behavior.

---

## The Configuration Files

### `AGENTS.md` (root) — Your System Prompt

`AGENTS.md` is the primary Codex configuration file, equivalent to `CLAUDE.md` in the Claude Code version. It contains everything Codex needs in every session: folder structure, commands, behavioral protocols (plan-first, session logging, context management), quality gates, content invariants (INV-1 through INV-12), Beamer↔Quarto auto-sync rules, the full skill reference table, the full agent reference table, multi-agent protocols, R/LaTeX/Quarto standards summaries, and the current project state table.

Fill in the `[BRACKETED PLACEHOLDERS]` at the top with your project details. Replace example rows in the environment/CSS class tables with your own. Update section 14 as you add lectures.

### `.codex/skills/` — Skill Playbooks

31 skill files describe the exact steps for each named workflow. When you tell Codex to "run the review-paper skill" or "use the qa-quarto workflow", Codex reads the relevant skill file and follows its protocol. Skills reference agent files, cross-reference rule files, and describe exactly when to loop, when to stop, and what to report.

You can also invoke skills directly as one-shot operations without an interactive session:

```bash
./scripts/run-workflow.sh compile-latex Lecture01_Topic
./scripts/run-workflow.sh review-paper my-paper.tex
```

### `.codex/agents/` — Agent Role Definitions

14 agent files define each specialized reviewer. When a skill calls for "adopting the proofreader role", Codex reads `.codex/agents/proofreader.md` and operates according to those instructions for that phase of work. No API-level spawning — the same model shifts context by reading the role definition.

### `.codex/rules/` — Protocol Documents

8 rule files define non-negotiable protocols: content invariants, replication tolerances, TikZ prevention rules, cross-artifact review protocol, and more. These are referenced by skills and agents but are not automatically loaded — they are pulled in when a skill explicitly references them.

---

## Use Cases

| Academic Task | How This Workflow Helps |
|---------------|------------------------|
| Lecture slides (Beamer/Quarto) | Full creation, translation, multi-agent review, deployment |
| Research papers | Literature review, manuscript review, simulated peer review |
| Data analysis | End-to-end R pipelines, replication verification, publication-ready output |
| Replication packages | AEA-compliant packaging, reproducibility audit trails |
| Presentations | Visual audit, cognitive load review, rhetoric of decks principles |
| Research proposals | Structured drafting with adversarial critique |

---

## What's Included

<details>
<summary><strong>14 agents, 31 skills, 8 rules, 4 reference files, 3 hooks</strong> (click to expand)</summary>

### Agents (`.codex/agents/`)

| Agent | What It Does |
|-------|-------------|
| `proofreader` | Grammar, typos, overflow, consistency review |
| `slide-auditor` | Visual layout audit (overflow, font consistency, spacing) |
| `pedagogy-reviewer` | 13-pattern pedagogical review (narrative arc, notation density, pacing) |
| `r-reviewer` | R code quality, reproducibility, and domain correctness |
| `tikz-reviewer` | Merciless TikZ diagram visual critique |
| `beamer-translator` | Beamer-to-Quarto translation specialist |
| `quarto-critic` | Adversarial QA comparing Quarto against Beamer benchmark |
| `quarto-fixer` | Implements fixes from the critic agent |
| `verifier` | End-to-end task completion verification |
| `domain-reviewer` | **Template** for your field-specific substance reviewer |
| `domain-referee` | Substantive manuscript referee (calibrated to journal + disposition) |
| `methods-referee` | Methods/econometrics referee (paper-type-aware) |
| `editor` | Journal editor: desk review, selects 2 referees, editorial decision |
| `claim-verifier` | Fresh-context CoVe fact-checker (spawned as subprocess — never sees original draft) |

### Skills (`.codex/skills/`)

| Skill | What It Does |
|-------|-------------|
| `compile-latex` | 3-pass XeLaTeX compilation with bibtex |
| `deploy` | Render Quarto + sync to GitHub Pages |
| `extract-tikz` | TikZ diagrams to PDF to SVG pipeline |
| `proofread` | Launch proofreader role on a file |
| `visual-audit` | Launch slide-auditor role on a file |
| `pedagogy-review` | Launch pedagogy-reviewer role on a file |
| `review-r` | Launch R code reviewer role |
| `qa-quarto` | Adversarial critic-fixer loop (max 5 rounds) |
| `slide-excellence` | Combined multi-agent slide review |
| `translate-to-quarto` | Full 11-phase Beamer-to-Quarto translation |
| `validate-bib` | Cross-reference citations against bibliography |
| `new-diagram` | Scaffold a TikZ diagram from the snippet gallery with prevention + review |
| `devils-advocate` | Challenge design decisions before committing |
| `create-lecture` | Full lecture creation workflow |
| `commit` | Stage, quality-check, commit, create PR, and merge to main |
| `lit-review` | Literature search, synthesis, and gap identification |
| `research-ideation` | Generate research questions and empirical strategies |
| `interview-me` | Interactive interview to formalize a research idea |
| `review-paper` | Manuscript review: structure, methods, referee objections |
| `review-paper --adversarial` | Critic-fixer adversarial loop (max 5 rounds) |
| `review-paper --peer <JOURNAL>` | Full simulated peer-review pipeline: editor + 2 referees + decision |
| `seven-pass-review` | Seven-pass adversarial manuscript review (sequential subagent roles) |
| `respond-to-referees` | R&R response-letter generator (maps referee comments to revisions) |
| `data-analysis` | End-to-end R analysis with publication-ready output |
| `audit-reproducibility` | Enforce tolerance thresholds on paper ↔ code numeric claims |
| `verify-claims` | Chain-of-Verification fact-check (fresh-context subprocess, never sees draft) |
| `preregister` | Generate preregistration document (OSF / AsPredicted / AEA RCT Registry) |
| `learn` | Extract non-obvious discoveries into persistent skills |
| `context-status` | Show session health and context usage |
| `deep-audit` | Repository-wide consistency audit |
| `permission-check` | Diagnose issues when Codex refuses an action or prompts unexpectedly |
| `checkpoint` | Structured session-handoff snapshot (state + plan pointers + next actions) |

### Rules (`.codex/rules/`)

Rules are protocol documents referenced explicitly by skills and agents. Unlike the Claude Code version (where rules auto-load via path-scoped frontmatter), Codex rules are pulled in by the skill or agent that needs them — or can be listed in `AGENTS.md` for always-on behavior.

| Rule | What It Enforces |
|------|-----------------|
| `content-invariants` | INV-1 through INV-12: palette sync, notation parity, no-pause, TikZ-as-SVG, single bibliography, set.seed, relative paths, transparent figures, project theme |
| `replication-protocol` | Replicate original before extending; tolerance thresholds for numeric claims |
| `cross-artifact-review` | Paper claims must be traced to R output files; auto-invokes `review-r` and `audit-reproducibility` |
| `post-flight-verification` | Task completion checklist; verification triggers for `.tex`, `.qmd`, `.R` |
| `tikz-prevention` | P1–P6 authoring rules applied before any TikZ diagram is finalized |
| `tikz-visual-quality` | Visual quality standards for TikZ diagrams |
| `exploration-folder-protocol` | Graduate/archive lifecycle for `explorations/` sandbox |
| `pdf-processing` | Safe handling of large PDFs in `master_supporting_docs/` |

### Reference Files (`.codex/references/`)

| File | What It Contains |
|------|-----------------|
| `journal-profiles.md` | Peer-review calibration profiles (ships with econ + polisci; add your own journals) |
| `discipline-cards.md` | Per-discipline paper-type frequencies, norms, and method conventions |
| `audit-pet-peeves.md` | Common code review findings and anti-patterns |
| `v1.9-backlog.md` | Planned features and deferred items for the next release |

### Hooks (`.codex/hooks/`)

Codex CLI has no native hook events (unlike Claude Code's PreCompact / PostToolUse / Stop system). These hooks are shell scripts called explicitly — `session-init.sh` is called by `scripts/codex.sh` at startup; the others can be called manually or from skill files.

| Hook | What It Does | When Called |
|------|-------------|-------------|
| `session-init.sh` | Prints active plan + most recent session log; prints recovery actions | Automatically by `scripts/codex.sh` on every session start |
| `session-state.sh` | Writes `.codex/state/session.json` with current plan path, status, and log | Manually, or from `scripts/codex.sh` as an exit trap |
| `verify-files.sh` | Prints the correct compile/render command for a modified `.tex`, `.qmd`, or `.R` file | Called from skill files after edits; also callable directly |

### Pre-commit Quality Hook (`.git/hooks/pre-commit`)

A git pre-commit hook runs `scripts/quality_score.py` on every staged `.tex`, `.qmd`, and `.R` file before committing. It blocks the commit (exit 1) if any file scores below 80, and warns (exit 0) if any file scores below 90. This is a hard enforcement mechanism — it runs whether you use the `commit` skill or commit directly.

**Override:** `git commit --no-verify -m "override: [reason]"` — use only with a documented reason.

> **Fresh clone note:** Git hooks are not tracked by git. After cloning, install the hook with:
> ```bash
> cp .codex/hooks/pre-commit-template .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
> ```
> *(Or add a `make setup` / `scripts/setup.sh` step to your project.)*

</details>

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Codex CLI](https://github.com/openai/codex) | Everything | `npm install -g @openai/codex` |
| OpenAI API key | Codex CLI | Set `OPENAI_API_KEY` in your shell profile |
| git | Clone + version control | [git-scm.com](https://git-scm.com/downloads) |
| Python 3 (3.9+) | Quality scorer, palette sync, TikZ prevention checkers | Preinstalled on macOS/Linux; [python.org](https://www.python.org/) for Windows |
| XeLaTeX | LaTeX compilation (Beamer `HelloWorld`, real lectures) | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| [Quarto](https://quarto.org) | Web slides (Quarto `HelloWorld`, real lectures) | [quarto.org/docs/get-started](https://quarto.org/docs/get-started/) |
| R | Figures and analysis (`data-analysis`, `scripts/R/` template) | [r-project.org](https://www.r-project.org/) |
| pdf2svg | TikZ → SVG for Quarto (`extract-tikz`) | `brew install pdf2svg` (macOS), `apt install pdf2svg` (Debian) |
| [gh CLI](https://cli.github.com/) | PR / issue workflow | `brew install gh` (macOS), `apt install gh` (Debian) |

**Minimum to fork this template:** Codex CLI + OpenAI API key + git + Python 3.

**Minimum to run the included HelloWorld demos end-to-end:** add XeLaTeX (for `compile-latex HelloWorld`) and Quarto (for `deploy HelloWorld`).

**Your real work may need more** — R for `scripts/R/` analyses, pdf2svg if you use TikZ extraction, gh CLI if you use the PR-based commit workflow. `./scripts/validate-setup.sh` reports which of these are installed and what each unlocks.

---

## Adapting for Your Field

1. **Fill in `AGENTS.md`** — replace `[YOUR PROJECT NAME]`, `[YOUR INSTITUTION]`, `[YOUR STACK]`, `[YOUR DOMAIN]` at the top with your actual project details
2. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles — this file is shared between both CLIs
3. **Customize the domain reviewer** (`.codex/agents/domain-reviewer.md`) with review lenses specific to your field
4. **Update the color palette** — this is a **two-surface contract**: change the HEX values at the top of **both** [`Preambles/header.tex`](Preambles/header.tex) (Beamer/TikZ) **and** [`Quarto/theme-template.scss`](Quarto/theme-template.scss) (Quarto slides) so they agree. Then run `./scripts/check-palette-sync.sh` to verify. Forgetting one surface silently produces mismatched Beamer vs. Quarto renderings. See [`Preambles/README.md`](Preambles/README.md) for the full contract.
5. **Add domain-specific R packages** to the `[YOUR-PACKAGES]` placeholder in `scripts/AGENTS.md` and update the stack note in `AGENTS.md` §9
6. **Update the CSS class table** in `Quarto/AGENTS.md` with your actual CSS classes from `theme-template.scss`
7. **Update the Beamer environments table** in `Slides/AGENTS.md` with your custom environments from `Preambles/header.tex`
8. **Fill in the lecture mapping** table (section 14 of `AGENTS.md`) as you add lectures

---

## Codex CLI vs. Claude Code — Key Differences

If you have used the Claude Code version of this workflow, here is what changes:

| Aspect | Claude Code | Codex CLI |
|--------|------------|-----------|
| Config file | `CLAUDE.md` | `AGENTS.md` |
| Path-scoped rules | Auto-loaded via `paths:` frontmatter | Subdirectory `AGENTS.md` stacking (native Codex behavior) |
| Invoking a skill | Type `/skill-name` | Tell Codex "run the skill-name skill" — or `./scripts/run-workflow.sh skill-name` for one-shot |
| Autonomous mode | `bypassPermissions` / Bypass mode | `--approval-mode full-auto` (via `./scripts/codex.sh`) |
| Multi-agent | Spawned subagents via `Task` tool | Sequential role-switching: Codex reads agent `.md`, adopts role, saves output, continues |
| Context isolation (CoVe) | Forked subagent with `context: fork` | Fresh `codex` subprocess via `./scripts/run-workflow.sh --fork` |
| Hook events | Native PreCompact / PostToolUse / Stop | Shell scripts called explicitly (`session-init.sh` runs on startup via `codex.sh`) |
| Quality gate | Advisory (halts `/commit` skill) | Hard git pre-commit hook (blocks `git commit` directly) |
| Session config | `.claude/settings.json` | `--model` and `--approval-mode` flags in `scripts/codex.sh` |

---

## Additional Resources

- [OpenAI Codex CLI (GitHub)](https://github.com/openai/codex) — source, docs, and issues
- [OpenAI API Documentation](https://platform.openai.com/docs) — API reference
- [Claude Code version of this workflow](README-claude.md) — the parallel Claude Code setup in this same repo

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory University, developed by Pedro Sant'Anna using Claude Code over 6+ sessions, then adapted for the OpenAI Codex CLI to enable parallel coexistence. The course produced 6 complete PhD lecture decks with 800+ slides, interactive Quarto versions with plotly charts, and full R replication packages — all managed through this multi-agent workflow. The patterns are domain-agnostic: the same agents, rules, and orchestrator work for any academic project.

---

## Community & Extensions

**Extended workflows built on this infrastructure:**

- **[clo-author](https://github.com/hugosantanna/clo-author)** by Hugo Sant'Anna (UAB) — Paper-centric research workflows with 17 specialized agents (6 worker-critic pairs plus referees, data-engineer, verifier), simulated blind peer review, AEA replication compliance, and full research lifecycle management. **The `review-paper --peer <journal>` pipeline in this template is adapted from clo-author with Hugo's permission** (pipeline shape, 6-way disposition taxonomy, journal-calibration schema, paper-type branching). Thanks, Hugo.
- **[claudeblattman](https://github.com/chrisblattman/claudeblattman)** by Chris Blattman (U Chicago) — Comprehensive guide for non-technical academics: executive assistant workflows, proposal writing, agent debates, and self-improving configuration
- **[MixtapeTools](https://github.com/scunning1975/MixtapeTools)** by Scott Cunningham (Baylor) — The Rhetoric of Decks: philosophy and practice of beautiful, rhetorically effective academic presentations
- **[autoresearch](https://github.com/karpathy/autoresearch)** by Andrej Karpathy — Constraint-based autonomous research with `program.md` as constitutional document
- **[ClaudeCodeTools](https://github.com/aspi6246/ClaudeCodeTools)** — "The Editor" persona: seven-audit sequential paper review protocol

---

## Versioning & Contributing

- **What's new:** see [CHANGELOG.md](CHANGELOG.md). We follow loose semver — breaking changes get major bumps so you can decide when to pull updates.
- **How to contribute:** see [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md). PRs welcome for generalizable improvements; fork-specific work stays in your fork.
- **Pin to a version:** `git checkout v1.8.0` (current as of 2026-04-27).

---

## License

MIT License. See [LICENSE](LICENSE).
