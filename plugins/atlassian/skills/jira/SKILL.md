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

Reusable Jira review agent:

- `plugins/atlassian/agents/jira-ticket-review.agent.md`

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
> - `KEY` — Project Name 1
> - `PROJ` — Project Name 2`
> - ...
>
> Which project should I use for this task?

**Do NOT proceed to Step 3 until the user has explicitly confirmed or selected a project.**

If the user has a clear default context (e.g., previously confirmed `KEY` in this session), you may suggest it as the default but still ask for confirmation.

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

1. Build the ADF JSON object in memory (or programmatically — see helper below)
2. Write it to a temp file
3. Pass it via `--description-file` (for create/edit) or `--body-file` (for comments)

**Never use `--description "some markdown text"` directly.**

### ADF structure reference — Block nodes

Every ADF document is `{ "version": 1, "type": "doc", "content": [ ...block nodes... ] }`.

| ADF block node | Purpose | Markdown equivalent |
|----------------|---------|---------------------|
| `{ "type": "heading", "attrs": { "level": N }, "content": [...] }` | Heading (N = 1–6) | `## Heading` |
| `{ "type": "paragraph", "content": [...] }` | Paragraph | plain text |
| `{ "type": "bulletList", "content": [ listItem, ... ] }` | Bullet list | `- item` |
| `{ "type": "orderedList", "content": [ listItem, ... ] }` | Numbered list | `1. item` |
| `{ "type": "listItem", "content": [ paragraph, ... ] }` | List item (always wraps a paragraph) | list entry |
| `{ "type": "table", "content": [ tableRow, ... ] }` | Table | `\| col \| col \|` |
| `{ "type": "tableRow", "content": [ tableHeader \| tableCell, ... ] }` | Table row | table row |
| `{ "type": "tableHeader", "content": [ paragraph ] }` | Header cell | `\| **header** \|` |
| `{ "type": "tableCell", "content": [ paragraph ] }` | Data cell | `\| data \|` |
| `{ "type": "codeBlock", "attrs": { "language": "..." }, "content": [text] }` | Code block | `` ```lang `` |
| `{ "type": "blockquote", "content": [ paragraph, ... ] }` | Block quote | `> text` |
| `{ "type": "rule" }` | Horizontal divider | `---` |

### ADF structure reference — Inline nodes and marks

Inline nodes go inside the `content` array of paragraphs, headings, list items, etc.

| ADF inline | Purpose | Markdown equivalent |
|------------|---------|---------------------|
| `{ "type": "text", "text": "..." }` | Plain text | text |
| `{ "type": "text", "text": "...", "marks": [{ "type": "strong" }] }` | **Bold** | `**text**` |
| `{ "type": "text", "text": "...", "marks": [{ "type": "em" }] }` | *Italic* | `*text*` |
| `{ "type": "text", "text": "...", "marks": [{ "type": "code" }] }` | `Inline code` | `` `code` `` |
| `{ "type": "text", "text": "...", "marks": [{ "type": "link", "attrs": { "href": "..." } }] }` | Hyperlink | `[text](url)` |

Marks can be combined: `"marks": [{ "type": "strong" }, { "type": "em" }]` produces ***bold italic***.

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
    },
    {
      "type": "table",
      "content": [
        {
          "type": "tableRow",
          "content": [
            { "type": "tableHeader", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Column A" }] }] },
            { "type": "tableHeader", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Column B" }] }] }
          ]
        },
        {
          "type": "tableRow",
          "content": [
            { "type": "tableCell", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Value 1" }] }] },
            { "type": "tableCell", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Value 2" }] }] }
          ]
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

### ADF Helper Functions (PowerShell)

When building descriptions programmatically, use these helper functions to construct ADF nodes:

```powershell
# --- ADF builder helpers ---
function New-AdfText($text, $marks) {
    $node = @{ type = "text"; text = $text }
    if ($marks) { $node.marks = $marks }
    $node
}
function New-AdfParagraph($content) {
    @{ type = "paragraph"; content = @($content) }
}
function New-AdfHeading($level, $text) {
    @{ type = "heading"; attrs = @{ level = $level }; content = @((New-AdfText $text)) }
}
function New-AdfBulletList($items) {
    @{ type = "bulletList"; content = @($items | ForEach-Object {
        @{ type = "listItem"; content = @((New-AdfParagraph @((New-AdfText $_)))) }
    }) }
}
function New-AdfDoc($content) {
    @{ version = 1; type = "doc"; content = @($content) }
}

# --- Usage example ---
$doc = New-AdfDoc @(
    (New-AdfHeading 2 "Goal"),
    (New-AdfParagraph @((New-AdfText "Implement the feature."))),
    (New-AdfHeading 2 "Acceptance Criteria"),
    (New-AdfBulletList @("First criterion", "Second criterion"))
)
$doc | ConvertTo-Json -Depth 20 | Out-File "$env:TEMP\desc.json" -Encoding UTF8
acli jira workitem edit --key "PROJ-123" --description-file "$env:TEMP\desc.json" --yes
```

### Red Lines — Description Formatting

- ❌ `--description "## Heading\n**Bold** text"` — Markdown not rendered, shows as raw symbols
- ❌ `--description "Plain text with\nnewlines"` — No formatting at all
- ❌ Stuffing Markdown into a single ADF paragraph text node — same problem, raw `##`/`**`/`-` visible
- ✅ Always build structured ADF JSON with proper node types (heading, bulletList, table, etc.)
- ✅ Write ADF JSON to a temp file and use `--description-file` / `--body-file`

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
| **View** | `acli jira workitem view` | `KEY-123`, `--fields`, `--json`, `--web` |
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
  --project "KEY" \
  --type "Story" \
  --assignee "dev@example.com" \
  --label "frontend,sprint-42"

# Create an Epic
acli jira workitem create \
  --summary "User Authentication Module" \
  --project "KEY" \
  --type "Epic" \
  --description "Complete auth system with login, logout, and password reset"

# Create a Bug
acli jira workitem create \
  --summary "Login button unresponsive on mobile" \
  --project "KEY" \
  --type "Bug" \
  --assignee "@me"

# Create a Task with description from file
acli jira workitem create \
  --summary "Set up CI/CD pipeline" \
  --project "KEY" \
  --type "Task" \
  --from-file description.txt

# Create a sub-task under a parent
acli jira workitem create \
  --summary "Write unit tests for login" \
  --project "KEY" \
  --type "Sub-task" \
  --parent "KEY-42"

# Create from JSON template
acli jira workitem create --generate-json   # outputs template
acli jira workitem create --from-json workitem.json
```

### 2. Search and List Work Items

```bash
# List all issues in a project
acli jira workitem search --jql "project = KEY" --paginate

# Search with specific fields as CSV
acli jira workitem search \
  --jql "project = KEY AND type = Story AND status = 'In Progress'" \
  --fields "key,summary,assignee,status,priority" \
  --csv

# My open issues
acli jira workitem search --jql "assignee = currentUser() AND status != Done"

# Bugs in current sprint
acli jira workitem search \
  --jql "project = KEY AND type = Bug AND sprint in openSprints()" \
  --json

# Recently updated (last 7 days)
acli jira workitem search --jql "project = KEY AND updated >= -7d"

# Count issues only
acli jira workitem search --jql "project = KEY AND status = 'To Do'" --count

# Open in browser
acli jira workitem search --jql "project = KEY" --web

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
  --jql "project = KEY AND status = 'In Review'" \
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
  --jql "project = KEY AND status = 'To Do' AND assignee is EMPTY" \
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
  --jql "project = KEY AND status = 'In Review'" \
  --assignee "reviewer@example.com" \
  --yes

# Bulk transition: move all bugs to "In Progress"
acli jira workitem transition \
  --jql "project = KEY AND type = Bug AND status = 'To Do'" \
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
acli jira workitem link create --out "KEY-10" --in "KEY-20" --type "Blocks"

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
acli jira project view --key "KEY" --json

# List boards
acli jira board search --project "KEY"

# List sprints on a board
acli jira board list-sprints --id 123 --state active,closed --json

# Sprint work items report
acli jira sprint list-workitems --sprint 42 --board 123 \
  --fields "key,summary,status,assignee,priority" --csv

# Sprint report via JQL
acli jira workitem search \
  --jql "project = KEY AND sprint = 42" \
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
--jql "project = KEY AND assignee is EMPTY"

# By type
--jql "project = KEY AND type = Bug"
--jql "project = KEY AND type = Story"
--jql "project = KEY AND type = Epic"
--jql "project = KEY AND type = Task"

# By status
--jql "project = KEY AND status = 'In Progress'"
--jql "project = KEY AND status != Done"

# Multiple criteria
--jql "project = KEY AND type = Bug AND priority = High AND status != Done"

# Sprint-specific
--jql "project = KEY AND sprint = 42"
--jql "project = KEY AND sprint in openSprints()"

# Time-based
--jql "project = KEY AND created >= -7d"
--jql "project = KEY AND updated >= -30d"

# Text search
--jql "project = KEY AND summary ~ 'login'"
```

## Common Mistakes — STOP and Re-read

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Using Markdown in `--description` | Jira Cloud does not render Markdown — raw symbols show up literally | Always build ADF JSON, write to temp file, use `--description-file` |
| Stuffing Markdown into a single ADF paragraph | Even inside ADF, Markdown text in one paragraph node renders as raw `##`/`**`/`-` | Build separate ADF nodes: headings, bulletLists, tables, etc. |
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
- ❌ Putting Markdown text inside a single ADF paragraph node (same result — raw `##`/`**`/`-` visible)
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
