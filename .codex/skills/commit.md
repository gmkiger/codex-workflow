---
name: commit
description: Stage, commit, push, open a PR, and merge to main. Trigger ONLY on explicit commit intent: "commit", "ship it", "push this", "open a PR", "merge to main". Do NOT auto-invoke on vague end-of-task phrases.
argument-hint: "[optional: commit message]"
---

# Commit, PR, and Merge

Stage changes, verify quality gates, commit, create a PR, and merge to main.

## Step 0: Quality Gate (Pre-Commit)

For every changed `.qmd`, `.tex`, or `.R` file:
```bash
python3 scripts/quality_score.py <changed-file-paths>
```

If any file scores below **80**, halt and report issues. User must fix or explicitly override ("commit anyway" + reason).

Note: the `.git/hooks/pre-commit` hook also enforces this automatically on `git commit`.

## Step 0b: Surface-Sync Gate

```bash
./scripts/check-surface-sync.sh
```

Exit 0 → continue. Exit 1 → drift detected → fix stale counts before proceeding.

## Step 1: Check Current State

```bash
git status && git diff --stat && git log --oneline -5
```

## Step 2: Create a Branch

```bash
git checkout -b <short-descriptive-branch-name>
```

## Step 3: Stage Files

Add specific files (never `git add -A`):
```bash
git add <file1> <file2> ...
```

Do NOT stage `.codex/state/`, `.claude/settings.local.json`, or any files containing secrets.

## Step 4: Commit

Use `$ARGUMENTS` as commit message if provided. Otherwise analyze staged changes and write a message explaining WHY, not WHAT.

```bash
git commit -m "$(cat <<'EOF'
<commit message>
EOF
)"
```

## Step 5: Push and Create PR

```bash
git push -u origin <branch-name>
gh pr create --title "<short title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

## Test plan
<checklist>
EOF
)"
```

## Step 6: Merge and Clean Up

```bash
gh pr merge <pr-number> --merge --delete-branch
git checkout main && git pull
```

## Step 7: Report

Report the PR URL and what was merged.

## Rules

- **Never skip Step 0.** Quality gates catch broken compilation before reaching main.
- Always create a NEW branch — never commit directly to main.
- Use `--merge` (not `--squash` or `--rebase`) unless asked otherwise.
