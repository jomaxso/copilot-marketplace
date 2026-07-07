# Engineering Plugin

Engineering planning and decision-support skills for GitHub Copilot.

## Install

```bash
copilot plugin install engineering@jomaxso
```

## Included skills

| Skill | Description |
|-------|-------------|
| `grilly` | Grills the user on a plan or design, walks the decision tree branch by branch, and recommends sensible defaults while uncovering missing requirements |

## Usage

After installing the plugin, the `grilly` skill is available automatically. Verify with:

```
/skills list
```

Then ask Copilot to grill you on a plan, design, requirements draft, migration idea, architecture decision, or implementation approach.

Starter eval prompts for iterating on the skill live in `skills/grilly/evals/evals.json`.
