---
name: simplify
description: Review changed code for reuse, quality, and efficiency, then fix any issues found. Trigger: "simplify", "review for quality", "clean this up", "is there a simpler way".
argument-hint: "[file path or 'staged']"
---

# Simplify

Review code for unnecessary complexity and fix issues found.

## Steps

1. Identify the target:
   - Specific file path from `$ARGUMENTS`
   - "staged": `git diff --cached` for staged changes
   - If neither: `git diff` for all unstaged changes

2. Review for:
   - **Reuse:** Is there an existing function/utility that does this? Check for duplication.
   - **Complexity:** Can this be expressed more simply without losing correctness?
   - **Efficiency:** Any obvious performance issues (growing vectors in loops, unnecessary passes)?
   - **Abstraction level:** Is this the right level of abstraction? Too much or too little?

3. For R scripts, apply the conventions from `scripts/AGENTS.md`:
   - Functions documented with roxygen
   - No magic numbers
   - Pre-allocated vectors
   - Consistent pipe style

4. Apply fixes directly (this skill edits files, unlike review-only skills).

5. Report what was simplified and why.

## Constraints

- Don't over-abstract. Three similar lines is better than a premature abstraction.
- Don't add error handling for scenarios that can't happen.
- Don't refactor beyond what the task requires.
- If simplification would change behavior, ask the user first.
