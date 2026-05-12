---
name: learn
description: Extract a discovery or workflow improvement into persistent memory or a skill file. Trigger: "learn this", "capture this as a skill", "extract discovery", "save this workflow".
argument-hint: "[description of what to capture]"
---

# Learn — Extract Discovery

Capture a discovery, correction, or workflow improvement for future sessions.

## Decision: Memory or Skill?

- **MEMORY.md** (generic pattern): use when the learning applies to anyone using this workflow
- **`.codex/state/personal-memory.md`** (machine-specific): use when the learning is specific to your setup
- **New skill file in `.codex/skills/`**: use when the discovery is a reusable multi-step workflow

## Steps

1. Understand the discovery from `$ARGUMENTS`.

2. Determine the right destination (see above).

3. **For MEMORY.md entries:**
   Append a `[LEARN:category]` entry at the bottom of `MEMORY.md`:
   ```markdown
   [LEARN:category] Brief rule or discovery → what changed or what to do differently.
   ```
   Categories: `workflow`, `documentation`, `design`, `files`, `governance`, `skills`, `memory`, `drift`, `hooks`, `pattern`, `framing`, `audit`, `safety`, `privacy`, `edits`, `permissions`

4. **For skill files:**
   Create `.codex/skills/[skill-name].md` using `templates/skill-template.md` as the base.
   Update the skill reference table in `AGENTS.md` to include the new skill.

5. Confirm what was saved and where.

## Principles

- Save the learning in a way a future session can act on it, not just recall it
- Generic insights belong in MEMORY.md (committed, syncs across machines)
- Machine-specific quirks belong in `.codex/state/personal-memory.md` (gitignored)
