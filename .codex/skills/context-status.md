---
name: context-status
description: Show current session health — active plan, session log status, git state, and context management recommendations. Trigger: "context status", "how much context", "session health", "what's the state".
argument-hint: ""
---

# Context Status

Show session health and context management recommendations.

## Steps

1. **Active plan:**
   ```bash
   ls -t quality_reports/plans/*.md 2>/dev/null | head -3
   ```
   Read the most recent non-COMPLETED plan. Report name, status, next unchecked task.

2. **Session log:**
   ```bash
   ls -t quality_reports/session_logs/*.md 2>/dev/null | head -1
   ```
   Report name and last-modified time. Flag if no session log exists.

3. **Git state:**
   ```bash
   git status --short && git log --oneline -5
   ```
   Report: uncommitted files, current branch, recent commits.

4. **Context guidance** (since Codex CLI has no auto-compact):
   - If the conversation is getting long (many tool calls), recommend: "Save a checkpoint with `/checkpoint` before continuing."
   - If no session log: "Create one now — it survives session boundaries."
   - If DRAFT plan: "Plan is still DRAFT — confirm with user before executing."

5. **Output summary:**
   ```
   SESSION STATUS
   Active plan:    [name] [STATUS]
   Next task:      [task]
   Session log:    [name] (last updated: [time])
   Git:            [branch] — [N uncommitted files]
   Recommendation: [one sentence]
   ```
