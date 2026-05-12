---
name: checkpoint
description: Save a structured state snapshot before stopping or handing off. Trigger: "checkpoint", "save state", "snapshot before stopping", "capture current state".
argument-hint: "[optional: topic or session description]"
---

# Save Checkpoint

Capture the current session state to disk before stopping, switching tasks, or when context is getting long.

## Steps

1. **Determine current state:**
   - Read the most recent plan in `quality_reports/plans/`
   - Read the most recent session log in `quality_reports/session_logs/`
   - Run `git status` and `git log --oneline -5`

2. **Run the state capture script:**
   ```bash
   bash .codex/hooks/session-state.sh
   ```
   This writes `.codex/state/session.json` with the active plan, status, and next task.

3. **Append a checkpoint note to the session log:**
   ```markdown
   ---
   **Checkpoint at [HH:MM]:** [brief description from $ARGUMENTS or auto-generated]
   - Active plan: [plan name and status]
   - Next task: [first unchecked item]
   - Git status: [clean / N files changed]
   - Open questions: [any unresolved items]
   ```

4. **Output a recovery prompt** the user can use to resume:
   ```
   Session state saved. To resume:
   1. Run: ./scripts/codex.sh  (runs session-init automatically)
   2. Or manually: bash .codex/hooks/session-init.sh
   3. Read: quality_reports/plans/[active-plan].md
   4. Next task: [task description]
   ```

## When to Use

- Before stopping for the day
- Before a context-intensive operation (long analysis run)
- When switching from one major task to another
- After completing a significant milestone
