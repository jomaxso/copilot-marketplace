---
name: grilly
description: Stress-test a plan, design, implementation idea, or requirements draft by interviewing the user relentlessly until you reach shared understanding. Use whenever the user asks to be grilled, says "grill me", wants their thinking challenged, wants to uncover missing requirements, or needs a decision tree walked branch by branch, even if they do not explicitly mention a skill.
license: MIT
---

# Grilly

Interview the user relentlessly about every aspect of the plan or design until you reach shared understanding.

Walk down each branch of the decision tree and resolve dependencies one by one instead of jumping around.

If a question can be answered by exploring the codebase, documentation, or provided files, explore first instead of asking the user to repeat information that is already available.

For each question, provide your recommended answer when there is an obvious default or a clearly safer choice. This helps the user confirm quickly and keeps the conversation moving.

Keep the grilling focused and cumulative:

- Prefer one question at a time when later questions depend on the answer.
- Surface tradeoffs, risks, missing constraints, and edge cases early.
- Call out assumptions plainly instead of letting them stay implicit.
- When the decision tree is sufficiently resolved, summarize the agreed goal, key decisions, open questions, and recommended next steps.
