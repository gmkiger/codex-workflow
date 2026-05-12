---
name: interview-me
description: Interactive research interview to refine a research idea or topic. Ask questions, probe assumptions, identify gaps. Trigger: "interview me", "quiz me on", "research interview", "help me develop this idea".
argument-hint: "[topic or research question to develop]"
---

# Research Interview

Interactive dialogue to develop and refine a research idea. Multi-turn (unlike `/research-ideation` which is one-shot).

**Input:** `$ARGUMENTS` — a topic, embryonic research question, or "I want to develop an idea about X."

## Protocol

1. **Read** any papers or notes the user references in `$ARGUMENTS`. Read `master_supporting_docs/` for context.

2. **Start with 3 grounding questions** to understand:
   - What is the core phenomenon they want to understand?
   - What is the proposed identification strategy or approach?
   - What data do they have or plan to obtain?

3. **For each answer, follow up with:**
   - What assumptions does this require?
   - What's the main threat to validity?
   - Is there prior work on this?
   - What would falsify the hypothesis?

4. **After 5–7 exchanges, synthesize** what you've learned:
   - The research question as currently formulated
   - Identification strategy and its key assumption
   - Main threats to validity and possible mitigations
   - Suggested next steps (papers to read, data to locate, robustness checks)

5. **Ask** if the user wants a formal `/research-ideation` output document, or to continue the interview.

## Principles

- Push back on vague claims ("X affects Y") — ask for a mechanism
- Challenge identification assumptions — "What makes the treatment exogenous?"
- Surface the alternative explanation the user hasn't considered
- Be Socratic, not prescriptive — the user's thinking develops through questions, not your answers
