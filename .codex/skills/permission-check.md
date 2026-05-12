---
name: permission-check
description: Diagnose why Codex CLI is prompting unexpectedly or refusing actions. Trigger: "permission check", "why is it prompting", "codex won't do X", "permission error".
argument-hint: "[optional: description of what's failing]"
---

# Permission Check

Diagnose and resolve Codex CLI permission issues.

## Step 1: Check Approval Mode

```bash
# Are you using the session launcher (recommended)?
cat scripts/codex.sh | grep approval-mode
```

The recommended mode is `--approval-mode full-auto`. If you launched `codex` directly, you may be in `suggest` or `auto-edit` mode.

**Fix:** Use `./scripts/codex.sh` instead of bare `codex`.

## Step 2: Check Model

Some Codex CLI operations require specific model capabilities. Verify:
```bash
# Run: codex --version
# Check: gpt-4.1 or o3 is the active model
```

## Step 3: Check File Paths

Codex CLI may hesitate on operations outside the project directory. Verify:
- All file paths are relative to the repo root
- No `..` navigation out of the project
- `PROJECT_ROOT` is set correctly: `$(git rev-parse --show-toplevel)`

## Step 4: Check API Key

```bash
echo $OPENAI_API_KEY | head -c 10
```
Key must be set in environment. If missing, set in `~/.zshrc` or `~/.bashrc`.

## Step 5: Check AGENTS.md

If the model refuses to perform a known task, verify the relevant instruction is in `AGENTS.md` or the appropriate subdirectory `AGENTS.md`.

Run: `grep -n "<task keyword>" AGENTS.md`

## Step 6: Report

Summarize what was found and the recommended fix.
