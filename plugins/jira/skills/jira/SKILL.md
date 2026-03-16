---
name: jira
description: >
  Use when managing Jira work items from the command line using the Atlassian CLI (acli).
  Covers creating, editing, searching, and transitioning Stories, Epics, Tasks, and Bugs.
  Includes authentication, JQL queries, bulk operations, sprint management, assigning people,
  adding comments, linking work items, and generating reports in CSV or JSON format.
license: MIT
---

# Jira Management with Atlassian CLI (acli)

## Overview

The Atlassian CLI (`acli`) is the official command-line tool for interacting with Jira Cloud. This skill teaches you how to manage Jira work items — **Stories, Epics, Tasks, and Bugs** — directly from the terminal.

> **Mandatory workflow before every task:** Check authentication → list projects → ask user to select a project → then execute the task with the selected project key.

**Use this skill when:**
- Creating, editing, or deleting Jira issues
- Searching and listing work items with JQL
- Changing issue status (transitions)
- Assigning or reassigning people
- Adding comments to issues
- Performing bulk operations on multiple issues
- Generating sprint reports (CSV/JSON)
- Linking work items (parent/child, blocks, etc.)

**Prerequisites:**
- Atlassian CLI (`acli`) installed:
  - **Windows:** `.\install-windows.ps1`
  - **Linux:** `chmod +x install-linux.sh && ./install-linux.sh`
  - **macOS:** `chmod +x install-macos.sh && ./install-macos.sh` (or `brew tap atlassian/homebrew-acli && brew install acli`)
  - See also: [official install guide](https://developer.atlassian.com/cloud/acli/guides/install-acli/)
- An Atlassian Cloud account with appropriate permissions
- OAuth or API token authentication configured

## Mandatory Startup Workflow — ALWAYS EXECUTE BEFORE EVERY TASK

Every Jira task **must** follow this exact three-step sequence. Do not skip any step.

### Step 1 — Check Authentication

```bash
acli jira auth status
```

If not authenticated, prompt the user to log in first:

```bash
acli jira auth login --web          # OAuth (browser-based, recommended)

# Or with API token (Unix)
echo <token> | acli jira auth login --site "mysite.atlassian.net" --email "user@example.com" --token

# Or with API token (Windows/PowerShell)
Get-Content token.txt | acli jira auth login --site "mysite.atlassian.net" --email "user@example.com" --token
```

**Other auth commands:**
- `acli jira auth logout` — Log out
- `acli jira auth switch` — Switch between accounts
- `acli jira auth switch --site mysite.atlassian.net` — Switch to specific site

### Step 2 — List Available Projects and Ask the User to Select One

After confirming authentication, **always** run:

```bash
acli jira project list
```

This outputs all projects the user has access to with their keys and names. Present the list clearly to the user and **ask them which project they want to work with** before proceeding. Example prompt:

> The following Jira projects are available:
> - `QSPLM` — SlothPLM
> - `INFRA` — Infrastructure
> - `OPS` — Operations
>
> Which project should I use for this task?

**Do NOT proceed to Step 3 until the user has explicitly confirmed or selected a project.**

If the user has a clear default context (e.g., previously confirmed `QSPLM` in this session), you may suggest it as the default but still ask for confirmation.

### Step 3 — Execute the Task with the Selected Project Key

Only after the user selects a project, proceed with the actual task. Replace `<PROJECT>` in all commands and JQL with the confirmed project key:

```bash
# Example: use the user-selected project key in all subsequent commands
acli jira workitem search --jql "project = <PROJECT> AND status != Done"
acli jira workitem create --project "<PROJECT>" --summary "..."
```

### Red Line — NEVER Skip This Workflow

- ❌ Do not guess or hard-code a project key without listing and confirming
- ❌ Do not run any JQL or create/edit commands before the user selects a project
- ❌ Do not skip `acli jira project list` even if you think you already know the project

---

## Description Formatting — ALWAYS Use ADF, NEVER Markdown

Jira Cloud **does not render Markdown**. All descriptions and comments must be written in **Atlassian Document Format (ADF)** — a structured JSON format. Passing plain Markdown will result in raw symbols (`##`, `**`, `-`) showing up literally in the ticket.

### Mandatory workflow for descriptions

1. Build the ADF JSON object in memory
2. Write it to a temp file
3. Pass it via `--description-file` (for create/edit) or `--body-file` (for comments)

**Never use `--description "some markdown text"` directly.**

### ADF structure reference

| ADF node | Purpose | Markdown equivalent |
|----------|---------|---------------------|
| `{ "type": "heading", "attrs": { "level": 2 }, "content": [...] }` | Heading | `## Heading` |
| `{ "type": "paragraph", "content": [...] }` | Paragraph | plain text |
| `{ "type": "bulletList", "content": [ listItem, ... ] }` | Bullet list | `- item` |
| `{ "type": "orderedList", "content": [ listItem, ... ] }` | Numbered list | `1. item` |
| `{ "type": "listItem", "content": [ paragraph ] }` | List item | list entry |
| `{ "type": "text", "text": "..." }` | Plain text | text |
| `{ "type": "text", "text": "...", "marks": [{ "type": "strong" }] }` | **Bold** text | `**text**` |
| `{ "type": "text", "text": "...", "marks": [{ "type": "em" }] }` | *Italic* text | `*text*` |
| `{ "type": "rule" }` | Horizontal divider | `---` |

### Full ADF template (PowerShell)

```powershell
$adf = @'
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Overview" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Description text here." }]
    },
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Acceptance Criteria" }]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "First criterion" }] }]
        },
        {
          "type": "listItem",
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Second criterion" }] }]
        }
      ]
    }
  ]
}
'@
$adf | Out-File -FilePath "$env:TEMP\jira-description.json" -Encoding UTF8

# Then use it:
acli jira workitem create --summary "..." --project "PROJ" --type "Story" --description-file "$env:TEMP\jira-description.json"
# Or for editing:
acli jira workitem edit --key "PROJ-123" --description-file "$env:TEMP\jira-description.json" --yes
# Or for comments:
acli jira workitem comment create --key "PROJ-123" --body-file "$env:TEMP\jira-description.json"
```

### Red Lines — Description Formatting

- ❌ `--description "## Heading\n**Bold** text"` — Markdown not rendered, shows as raw symbols
- ❌ `--description "Plain text with\nnewlines"` — No formatting at all
- ✅ Always write ADF JSON to a temp file and use `--description-file`

---

## Command Structure

**Format:** `acli <product> <entity> <action> [flags]`

```bash
# ❌ WRONG — old syntax, does NOT work
acli jira --action getIssueList --jql "..."

# ✅ CORRECT — modern syntax
acli jira workitem search --jql "..."
```

**DO NOT** use `--action`, `--outputFormat 999`, `--columns`, or made-up command names.
When unsure about a command, run `acli jira <entity> --help`.

## Quick Reference: Work Item Management

| Action | Command | Key Flags |
|--------|---------|-----------|
| **Create** | `acli jira workitem create` | `--summary`, `--project`, `--type`, `--assignee`, `--label`, `--description` |
| **Bulk Create** | `acli jira workitem create-bulk` | `--from-csv`, `--from-json`, `--generate-json` |
| **Edit** | `acli jira workitem edit` | `--key`, `--jql`, `--summary`, `--assignee`, `--labels`, `--type` |
| **View** | `acli jira workitem view` | `QSPLM-123`, `--fields`, `--json`, `--web` |
| **Search** | `acli jira workitem search` | `--jql`, `--filter`, `--fields`, `--csv`, `--json`, `--count` |
| **Transition** | `acli jira workitem transition` | `--key`, `--jql`, `--status`, `--yes` |
| **Assign** | `acli jira workitem assign` | `--key`, `--jql`, `--assignee` (`@me`, email) |
| **Comment** | `acli jira workitem comment create` | `--key`, `--body`, `--body-file` |
| **Link** | `acli jira workitem link create` | `--out`, `--in`, `--type` |
| **Clone** | `acli jira workitem clone` | `--key`, `--to-project` |
| **Delete** | `acli jira workitem delete` | `--key`, `--jql`, `--yes` |
| **Archive** | `acli jira workitem archive` | `--key`, `--jql`, `--yes` |

## Core Workflows

### 1. Create a Work Item (Story, Epic, Task, Bug)

```bash
# Check auth first
acli jira auth status

# Create a Story
acli jira workitem create \
  --summary "Implement user login page" \
  --project "QSPLM" \
  --type "Story" \
  --assignee "dev@example.com" \
  --label "frontend,sprint-42"

# Create an Epic
acli jira workitem create \
  --summary "User Authentication Module" \
  --project "QSPLM" \
  --type "Epic" \
  --description "Complete auth system with login, logout, and password reset"

# Create a Bug
acli jira workitem create \
  --summary "Login button unresponsive on mobile" \
  --project "QSPLM" \
  --type "Bug" \
  --assignee "@me"

# Create a Task with description from file
acli jira workitem create \
  --summary "Set up CI/CD pipeline" \
  --project "QSPLM" \
  --type "Task" \
  --from-file description.txt

# Create a sub-task under a parent
acli jira workitem create \
  --summary "Write unit tests for login" \
  --project "QSPLM" \
  --type "Sub-task" \
  --parent "QSPLM-42"

# Create from JSON template
acli jira workitem create --generate-json   # outputs template
acli jira workitem create --from-json workitem.json
```

### 2. Search and List Work Items

```bash
# List all issues in a project
acli jira workitem search --jql "project = QSPLM" --paginate

# Search with specific fields as CSV
acli jira workitem search \
  --jql "project = QSPLM AND type = Story AND status = 'In Progress'" \
  --fields "key,summary,assignee,status,priority" \
  --csv

# My open issues
acli jira workitem search --jql "assignee = currentUser() AND status != Done"

# Bugs in current sprint
acli jira workitem search \
  --jql "project = QSPLM AND type = Bug AND sprint in openSprints()" \
  --json

# Recently updated (last 7 days)
acli jira workitem search --jql "project = QSPLM AND updated >= -7d"

# Count issues only
acli jira workitem search --jql "project = QSPLM AND status = 'To Do'" --count

# Open in browser
acli jira workitem search --jql "project = QSPLM" --web

# Use a saved filter
acli jira workitem search --filter 10001 --csv
```

### 3. View a Single Work Item

```bash
# View details
acli jira workitem view TEAM-123

# View specific fields as JSON
acli jira workitem view TEAM-123 --fields "summary,status,assignee,comment" --json

# Open in browser
acli jira workitem view TEAM-123 --web
```

### 4. Edit an Existing Work Item

```bash
# Change summary
acli jira workitem edit --key "TEAM-123" --summary "Updated title"

# Change assignee
acli jira workitem edit --key "TEAM-123" --assignee "newdev@example.com"

# Add labels
acli jira workitem edit --key "TEAM-123" --labels "urgent,hotfix"

# Remove labels
acli jira workitem edit --key "TEAM-123" --remove-labels "old-label"

# Change issue type
acli jira workitem edit --key "TEAM-123" --type "Bug"

# Update description from file
acli jira workitem edit --key "TEAM-123" --description-file updated-desc.txt

# Edit from JSON
acli jira workitem edit --generate-json   # get template
acli jira workitem edit --from-json changes.json
```

### 5. Change Status (Transition)

```bash
# Move a single issue to "In Progress"
acli jira workitem transition --key "TEAM-123" --status "In Progress"

# Move multiple issues to "Done"
acli jira workitem transition --key "TEAM-1,TEAM-2,TEAM-3" --status "Done"

# Transition all issues matching JQL (skip confirmation)
acli jira workitem transition \
  --jql "project = QSPLM AND status = 'In Review'" \
  --status "Done" \
  --yes

# Transition using a saved filter
acli jira workitem transition --filter 10001 --status "To Do" --yes
```

### 6. Assign / Reassign People

```bash
# Assign to yourself
acli jira workitem assign --key "TEAM-123" --assignee "@me"

# Assign to someone by email
acli jira workitem assign --key "TEAM-123" --assignee "dev@example.com"

# Bulk assign via JQL
acli jira workitem assign \
  --jql "project = QSPLM AND status = 'To Do' AND assignee is EMPTY" \
  --assignee "dev@example.com" \
  --yes

# Unassign
acli jira workitem assign --key "TEAM-123" --remove-assignee

# Assign multiple keys at once
acli jira workitem assign --key "TEAM-1,TEAM-2,TEAM-3" --assignee "@me"
```

### 7. Add Comments

```bash
# Add a comment
acli jira workitem comment create --key "TEAM-123" --body "Reviewed and approved"

# Comment from file
acli jira workitem comment create --key "TEAM-123" --body-file review-notes.txt

# List comments
acli jira workitem comment list --key "TEAM-123" --json

# Update a comment
acli jira workitem comment update --key "TEAM-123" --id 10001 --body "Updated text"

# Delete a comment
acli jira workitem comment delete --key "TEAM-123" --id 10001
```

### 8. Bulk Operations

**Use JQL, filters, or key lists — do NOT write bash loops.**

```bash
# Bulk edit: change assignee for all "In Review" issues
acli jira workitem edit \
  --jql "project = QSPLM AND status = 'In Review'" \
  --assignee "reviewer@example.com" \
  --yes

# Bulk transition: move all bugs to "In Progress"
acli jira workitem transition \
  --jql "project = QSPLM AND type = Bug AND status = 'To Do'" \
  --status "In Progress" \
  --yes --ignore-errors

# Bulk assign from file
acli jira workitem assign --from-file issue-keys.txt --assignee "@me" --yes

# Bulk create from CSV
acli jira workitem create-bulk --from-csv issues.csv --yes

# Bulk create from JSON
acli jira workitem create-bulk --generate-json   # get format
acli jira workitem create-bulk --from-json issues.json --yes
```

### 9. Link Work Items

```bash
# Link one issue as blocking another
acli jira workitem link create --out "QSPLM-10" --in "QSPLM-20" --type "Blocks"

# List links on an issue
acli jira workitem link list --key "TEAM-10" --json

# Get available link types
acli jira workitem link type --json

# Bulk create links from JSON
acli jira workitem link create --from-json links.json

# Delete a link
acli jira workitem link delete --id 10001
```

### 10. Sprint Reports and Project Overview

```bash
# List projects
acli jira project list --json

# View project details
acli jira project view --key "QSPLM" --json

# List boards
acli jira board search --project "QSPLM"

# List sprints on a board
acli jira board list-sprints --id 123 --state active,closed --json

# Sprint work items report
acli jira sprint list-workitems --sprint 42 --board 123 \
  --fields "key,summary,status,assignee,priority" --csv

# Sprint report via JQL
acli jira workitem search \
  --jql "project = QSPLM AND sprint = 42" \
  --fields "key,summary,status,assignee" \
  --csv > sprint-report.csv
```

## Output Formats

| Flag | Format | Use Case |
|------|--------|----------|
| *(default)* | Table | Human-readable terminal output |
| `--json` | JSON | Scripting, automation, piping |
| `--csv` | CSV | Spreadsheets, data analysis |
| `--web` | Browser | Opens in Jira web UI |
| `--fields "k,s,a"` | Custom | Select specific fields |
| `--count` | Count | Only return number of results |
| `--paginate` | All pages | Fetch all results (not just first page) |

## Common JQL Patterns

```bash
# My issues
--jql "assignee = currentUser()"

# Unassigned issues
--jql "project = QSPLM AND assignee is EMPTY"

# By type
--jql "project = QSPLM AND type = Bug"
--jql "project = QSPLM AND type = Story"
--jql "project = QSPLM AND type = Epic"
--jql "project = QSPLM AND type = Task"

# By status
--jql "project = QSPLM AND status = 'In Progress'"
--jql "project = QSPLM AND status != Done"

# Multiple criteria
--jql "project = QSPLM AND type = Bug AND priority = High AND status != Done"

# Sprint-specific
--jql "project = QSPLM AND sprint = 42"
--jql "project = QSPLM AND sprint in openSprints()"

# Time-based
--jql "project = QSPLM AND created >= -7d"
--jql "project = QSPLM AND updated >= -30d"

# Text search
--jql "project = QSPLM AND summary ~ 'login'"
```

## Common Mistakes — STOP and Re-read

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Using Markdown in `--description` | Jira Cloud does not render Markdown — raw symbols show up literally | Always build ADF JSON, write to temp file, use `--description-file` |
| Skipping auth + project selection | Hard-coded keys may be wrong; user must confirm | Always run Steps 1–3 of the Mandatory Startup Workflow |
| Skipping `acli auth status` | Commands fail silently without auth | Always check auth first |
| Skipping `acli jira project list` | User may want a different project than assumed | Always list projects and ask before proceeding |
| Using `--action createIssue` | Old syntax, does not work | `acli jira workitem create` |
| Using `--outputFormat 999` | Wrong flag name | Use `--csv` |
| Using `--columns` | Does not exist | Use `--fields` |
| Bash loops for bulk operations | Inefficient, error-prone | Use `--jql`, `--filter`, `create-bulk` |
| One-by-one edits on many items | Slow, unnecessary | Use `--jql` or `--key "K1,K2,K3"` with `--yes` |
| Making up command names | Will fail | Run `acli jira <entity> --help` first |
| Skipping `--yes` on bulk ops | Gets stuck on confirmation prompt | Add `--yes` for automated workflows |

## Red Flags — If You Catch Yourself Doing This, STOP

- ❌ Using Markdown syntax in `--description` (renders as raw text in Jira)
- ❌ Skipping authentication check
- ❌ Skipping `acli jira project list` and the project selection question
- ❌ Hard-coding a project key without asking the user to confirm
- ❌ Using `--action` in any command
- ❌ Writing a bash/PowerShell loop to create multiple issues
- ❌ Using `--outputFormat` instead of `--csv`
- ❌ Using `--columns` instead of `--fields`
- ❌ Guessing command names without checking `--help`
- ❌ Thinking "The old syntax probably still works"
- ❌ Thinking "They're probably already authenticated"
- ❌ Thinking "A loop is more flexible than built-in bulk commands"

**→ All of these mean: Stop, re-read this skill, use correct syntax.**

## Getting Help

```bash
acli --help                           # Top-level help
acli jira --help                      # Jira product help
acli jira workitem --help             # Work item entity help
acli jira workitem search --help      # Specific action help
acli jira workitem comment --help     # Nested entity help
```

For the full command reference with all flags and examples, see [references/REFERENCE.md](references/REFERENCE.md).
