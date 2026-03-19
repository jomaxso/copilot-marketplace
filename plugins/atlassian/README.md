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

After installing the plugin, both skills are available automatically. Verify with:

```
/skills list
```

Then ask Copilot to help with Jira — creating stories, editing tickets, searching with JQL, transitioning issues, and more.

For Confluence, ask Copilot to create or update pages, search with CQL, manage comments and attachments, and more.


