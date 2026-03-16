# Atlassian Plugin

Manage Jira Cloud work items directly from the terminal using the Atlassian CLI (`acli`).

## Install

```bash
copilot plugin install atlassian@jomaxso-copilot-marketplace
```

## Included skills

| Skill | Description |
|-------|-------------|
| `jira` | Create, edit, search, and transition Jira work items with proper ADF-formatted descriptions |

## Prerequisites

- **Atlassian CLI (`acli`)** — install scripts are in `skills/jira/scripts/`:
  - Windows: `.\install-windows.ps1`
  - Linux: `chmod +x install-linux.sh && ./install-linux.sh`
  - macOS: `chmod +x install-macos.sh && ./install-macos.sh`
- An Atlassian Cloud account with the required permissions

## Usage

After installing the plugin, the `jira` skill is available automatically. Verify with:

```
/skills list
```

Then ask Copilot to help with Jira — creating stories, editing tickets, searching with JQL, transitioning issues, and more.

