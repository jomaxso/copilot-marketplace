# Grill Me Plugin

Stress-test plans, designs, and implementation ideas by having Copilot interview you relentlessly until you reach shared understanding.

## Install

```bash
copilot plugin install grill-me@jomaxso-plugins
```

## Included skills

| Skill | Description |
|-------|-------------|
| `grill-me` | Grills the user on a plan or design, walks the decision tree branch by branch, and recommends sensible defaults while uncovering missing requirements |

## Usage

After installing the plugin, the `grill-me` skill is available automatically. Verify with:

```
/skills list
```

Then ask Copilot to grill you on a plan, design, requirements draft, migration idea, architecture decision, or implementation approach.

Starter eval prompts for iterating on the skill live in `skills/grill-me/evals/evals.json`.
