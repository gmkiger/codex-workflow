---
name: devils-advocate
description: Adversarial 5-7 question challenge to a deck's pedagogical choices. Trigger: "devil's advocate", "poke holes in this deck", "push back on my slides", "stress-test the design", "what would a skeptical student ask".
argument-hint: "[QMD or TEX filename]"
---

# Devil's Advocate Review

Read-only adversarial challenge to slide design choices. Surfaces questions that force rethinking.

This is lighter than `/pedagogy-review` — it produces pointed questions rather than a comprehensive report.

## Protocol

1. Read the slide file in `$ARGUMENTS`.

2. Generate 5–7 adversarial questions targeting:
   - **Ordering:** Why this topic before that one? Is the prerequisite chain stated?
   - **Prerequisites:** What does a student need to know that's not on these slides?
   - **Cognitive load:** Is this too much for one lecture? Where's the bottleneck?
   - **Motivation:** Why should a student care about this? Is the "so what" explicit?
   - **Examples:** Does the worked example actually illuminate the concept, or obscure it?
   - **Formalism:** Could this be stated more simply without losing rigor?
   - **Transitions:** How does this slide follow from the previous one?

3. For each question, state:
   - The specific slide or moment where the issue is clearest
   - What a skeptical student would think/say
   - What would need to change to address it

4. Do NOT propose comprehensive fixes (that's `/pedagogy-review`). Just surface the hard questions.

## Tone

Pointed but constructive. The goal is to surface assumptions the author made unconsciously — not to tear down the work. Good devil's advocate questions start with "Why did you decide to..." or "A student who doesn't already know X would..."
