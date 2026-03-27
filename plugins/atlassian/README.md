# Atlassian Plugin

Manage Jira Cloud work items and Confluence Cloud content directly from the terminal.

## Install

```bash
copilot plugin install atlassian@jomaxso-plugins
```

## Included skills

| Skill | Description |
|-------|-------------|
| `jira` | Create, edit, search, and transition Jira work items with proper ADF-formatted descriptions (uses `acli`) |
| `confluence` | Create, read, update, and delete Confluence pages, comments, attachments, and labels with CQL search (uses `curl` + REST API) |

## Included agents

| Agent | Description |
|-------|-------------|
| `jira-ticket-review` | Reusable subagent for reviewing existing Jira issues, refining summaries and descriptions, and validating relations while following the Jira skill workflow |

## Prerequisites

- **Jira skill:**
  - **Atlassian CLI (`acli`)** — install scripts in `skills/jira/scripts/`:
    - Windows: `.\install-windows.ps1`
    - Linux: `chmod +x install-linux.sh && ./install-linux.sh`
    - macOS: `chmod +x install-macos.sh && ./install-macos.sh`
- **Confluence skill:**
  - `curl` (pre-installed on Windows 10+, macOS, and Linux)
  - Environment variables: `CONFLUENCE_SITE`, `CONFLUENCE_EMAIL`, `CONFLUENCE_TOKEN`
- An Atlassian Cloud account with the required permissions

## Usage

After installing the plugin, the skills and agents from this plugin are available automatically. Verify with:

```
/skills list
```

Then ask Copilot to help with Jira — creating stories, editing tickets, searching with JQL, transitioning issues, and more.

For Confluence, ask Copilot to create or update pages, search with CQL, manage comments and attachments, and more.

For repeatable Jira review work, use the reusable agent at `agents/jira-ticket-review.agent.md`.


