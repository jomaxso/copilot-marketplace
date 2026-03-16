# Atlassian CLI — Jira Command Reference

Complete reference for all `acli jira` commands. For quick-start workflows, see the main [SKILL.md](../SKILL.md).

---

## Command Structure

```
acli jira <entity> <action> [flags]
```

**Entities:** `auth`, `board`, `dashboard`, `field`, `filter`, `project`, `sprint`, `workitem`

---

## 1. Authentication (`acli jira auth`)

### `auth login`

| Flag | Short | Description |
|------|-------|-------------|
| `--web` | `-w` | Authenticate via web browser (OAuth) |
| `--site` | `-s` | Site URL (e.g., `mysite.atlassian.net`) |
| `--email` | `-e` | User email |
| `--token` | — | Read API token from standard input |

```bash
acli jira auth login --web
echo <token> | acli jira auth login --site "mysite.atlassian.net" --email "user@example.com" --token
```

### `auth logout`

```bash
acli jira auth logout
```

### `auth status`

```bash
acli jira auth status
```

### `auth switch`

| Flag | Short | Description |
|------|-------|-------------|
| `--site` | `-s` | Target Atlassian site |
| `--email` | `-e` | Target account email |

```bash
acli jira auth switch
acli jira auth switch --site mysite.atlassian.net --email user@example.com
```

---

## 2. Board Commands (`acli jira board`)

### `board search`

| Flag | Description |
|------|-------------|
| `--name` | Partial match on board name |
| `--project` | Filter by project key |
| `--type` | Board type: `scrum`, `kanban`, `simple` |
| `--limit` | Max boards (default 50) |
| `--orderBy` | Sort: `name`, `-name`, `+name` |
| `--paginate` | Fetch all |
| `--json` / `--csv` | Output format |

### `board list-sprints`

| Flag | Description |
|------|-------------|
| `--id` | Board ID (required) |
| `--state` | Filter: `future`, `active`, `closed` (comma-separated) |
| `--limit` | Max sprints (default 50) |
| `--paginate` | Fetch all |
| `--json` / `--csv` | Output format |

```bash
acli jira board list-sprints --id 123 --state active,closed --json
```

---

## 3. Dashboard Commands (`acli jira dashboard`)

### `dashboard search`

| Flag | Short | Description |
|------|-------|-------------|
| `--name` | `-n` | Case-insensitive partial match |
| `--owner` | `-e` | Filter by owner email |
| `--limit` | `-l` | Max results (default 30) |
| `--paginate` | — | Fetch all |
| `--json` / `--csv` | — | Output format |

```bash
acli jira dashboard search --owner user@example.com --name "report" --csv
```

---

## 4. Field Commands (`acli jira field`)

### `field create`

| Flag | Description |
|------|-------------|
| `--name` | Field name |
| `--type` | Full plugin key (e.g., `com.atlassian.jira.plugin.system.customfieldtypes:textfield`) |
| `--searcherKey` | Optional searcher key |
| `--description` | Field description |
| `--json` | JSON output |

```bash
acli jira field create --name "Customer Name" --type "com.atlassian.jira.plugin.system.customfieldtypes:textfield"
```

### `field delete`

Moves field to trash (soft delete).

```bash
acli jira field delete --id customfield_12345
```

### `field cancel-delete`

Restores field from trash.

```bash
acli jira field cancel-delete --id customfield_12345
```

---

## 5. Filter Commands (`acli jira filter`)

### `filter list`

```bash
acli jira filter list --my
acli jira filter list --favourite --json
```

### `filter search`

| Flag | Short | Description |
|------|-------|-------------|
| `--name` | `-n` | Case-insensitive partial match |
| `--owner` | `-e` | Filter by owner email |
| `--limit` | `-l` | Max results (default 30) |
| `--paginate` | — | Fetch all |
| `--json` / `--csv` | — | Output format |

### `filter add-favourite`

```bash
acli jira filter add-favourite --filterId 10001
```

### `filter change-owner`

| Flag | Description |
|------|-------------|
| `--id` | Comma-separated filter IDs |
| `--owner` | New owner email |
| `--from-file` | File with filter IDs |
| `--ignore-errors` | Continue on errors |

```bash
acli jira filter change-owner --id 123,1234,12345 --owner anna@example.com
```

---

## 6. Project Commands (`acli jira project`)

### `project create`

| Flag | Short | Description |
|------|-------|-------------|
| `--from-project` | `-f` | Clone from existing project |
| `--key` | `-k` | New project key |
| `--name` | `-n` | Project name |
| `--description` | `-d` | Description |
| `--lead-email` | `-l` | Project lead email |
| `--from-json` | `-j` | Create from JSON |
| `--generate-json` | `-g` | Generate template JSON |

```bash
acli jira project create --from-project "TEAM" --key "NEW" --name "New Project"
acli jira project create --from-json project.json
acli jira project create --generate-json
```

### `project list`

| Flag | Description |
|------|-------------|
| `--recent` | Up to 20 recently viewed projects |
| `--limit` | Max projects (default 30) |
| `--paginate` | Fetch all |
| `--json` | JSON output |

```bash
acli jira project list --json
```

### `project view`

```bash
acli jira project view --key "TEAM" --json
```

### `project update`

| Flag | Short | Description |
|------|-------|-------------|
| `--project-key` | `-p` | Key of project to update |
| `--key` | `-k` | New key |
| `--name` | `-n` | New name |
| `--description` | `-d` | New description |
| `--lead-email` | `-l` | New lead email |
| `--from-json` | `-j` | Update from JSON |
| `--generate-json` | `-g` | Generate template |

### `project delete`

```bash
acli jira project delete --key "TEAM"
```

### `project archive` / `project restore`

```bash
acli jira project archive --key "TEAM"
acli jira project restore --key "TEAM"
```

---

## 7. Sprint Commands (`acli jira sprint`)

### `sprint list-workitems`

| Flag | Description |
|------|-------------|
| `--sprint` | Sprint ID (required) |
| `--board` | Board ID (required) |
| `--fields` | Comma-separated fields |
| `--jql` | Additional JQL filter |
| `--limit` | Max results (default 50) |
| `--paginate` | Fetch all |
| `--json` / `--csv` | Output format |

```bash
acli jira sprint list-workitems --sprint 1 --board 6 --paginate --csv
```

---

## 8. Work Item Commands (`acli jira workitem`)

### Bulk-Targeting Patterns (shared across many commands)

| Method | Flag | Description |
|--------|------|-------------|
| By key | `--key "KEY-1,KEY-2"` | Comma-separated keys |
| By JQL | `--jql "project = TEAM"` | JQL query |
| By filter | `--filter 10001` | Saved filter ID |
| By file | `--from-file "keys.txt"` | File with keys/IDs |

Common bulk flags: `--yes` (skip confirmation), `--ignore-errors` (continue on failures), `--json` (JSON output).

### `workitem create`

| Flag | Short | Description |
|------|-------|-------------|
| `--summary` | `-s` | Work item summary |
| `--project` | `-p` | Project key |
| `--type` | `-t` | Issue type: Epic, Story, Task, Bug, Sub-task |
| `--description` | `-d` | Plain text or ADF description |
| `--description-file` | — | Read description from file |
| `--assignee` | `-a` | Assignee: email, `@me`, or `default` |
| `--label` | `-l` | Comma-separated labels |
| `--parent` | — | Parent work item ID (for sub-tasks) |
| `--editor` | `-e` | Open text editor |
| `--from-file` | `-f` | Read summary/description from file |
| `--from-json` | — | Create from JSON |
| `--generate-json` | — | Generate template |

```bash
acli jira workitem create --summary "New feature" --project "TEAM" --type "Story" --assignee "@me"
acli jira workitem create --from-json workitem.json
```

### `workitem create-bulk`

| Flag | Description |
|------|-------------|
| `--from-json` | JSON file with array of issues |
| `--from-csv` | CSV file (columns: summary, projectKey, issueType, description, label, parentIssueId, assignee) |
| `--generate-json` | Print example JSON structure |
| `--ignore-errors` | Continue on errors |
| `--yes` | Skip confirmation |

```bash
acli jira workitem create-bulk --from-csv issues.csv --yes
acli jira workitem create-bulk --from-json issues.json --yes
acli jira workitem create-bulk --generate-json
```

### `workitem edit`

| Flag | Short | Description |
|------|-------|-------------|
| `--key` | `-k` | Work item keys (comma-separated) |
| `--jql` | — | JQL query |
| `--filter` | — | Filter ID |
| `--summary` | `-s` | New summary |
| `--description` | `-d` | New description |
| `--description-file` | — | Read description from file |
| `--assignee` | `-a` | New assignee |
| `--remove-assignee` | — | Remove assignee |
| `--labels` | `-l` | Set labels |
| `--remove-labels` | — | Remove specific labels |
| `--type` | `-t` | Change work item type |
| `--from-json` | — | Edit from JSON |
| `--generate-json` | — | Generate template |
| `--yes` | `-y` | Skip confirmation |
| `--ignore-errors` | — | Continue on errors |

```bash
acli jira workitem edit --key "TEAM-1" --summary "Updated title" --assignee "dev@example.com"
acli jira workitem edit --jql "project = TEAM AND status = 'In Review'" --assignee "reviewer@example.com" --yes
```

### `workitem view`

| Flag | Short | Description |
|------|-------|-------------|
| `--fields` | `-f` | Comma-separated fields. `*all`, `*navigable`. Prefix `-` to exclude. |
| `--json` | — | JSON output |
| `--web` | `-w` | Open in browser |

```bash
acli jira workitem view KEY-123
acli jira workitem view KEY-123 --fields "summary,status,comment" --json
acli jira workitem view KEY-123 --web
```

### `workitem search`

| Flag | Short | Description |
|------|-------|-------------|
| `--jql` | `-j` | JQL query string |
| `--filter` | — | Saved filter ID |
| `--fields` | `-f` | Output fields |
| `--limit` | `-l` | Max results |
| `--paginate` | — | Fetch all |
| `--count` | — | Count only |
| `--json` / `--csv` | — | Output format |
| `--web` | `-w` | Open in browser |

```bash
acli jira workitem search --jql "project = TEAM AND type = Bug" --csv
acli jira workitem search --jql "assignee = currentUser()" --fields "key,summary,status" --json
```

### `workitem transition`

| Flag | Short | Description |
|------|-------|-------------|
| `--key` | `-k` | Work item keys |
| `--jql` | — | JQL query |
| `--filter` | — | Filter ID |
| `--status` | `-s` | Target status name |
| `--yes` | `-y` | Skip confirmation |
| `--ignore-errors` | — | Continue on errors |

```bash
acli jira workitem transition --key "TEAM-1,TEAM-2" --status "Done"
acli jira workitem transition --jql "project = TEAM AND status = 'In Review'" --status "Done" --yes
```

### `workitem assign`

| Flag | Short | Description |
|------|-------|-------------|
| `--key` | `-k` | Work item keys |
| `--jql` | — | JQL query |
| `--filter` | — | Filter ID |
| `--from-file` | `-f` | File with keys |
| `--assignee` | `-a` | Assignee: `@me`, `default`, email, or account ID |
| `--remove-assignee` | — | Unassign |
| `--yes` | `-y` | Skip confirmation |
| `--ignore-errors` | — | Continue on errors |

```bash
acli jira workitem assign --key "TEAM-1" --assignee "@me"
acli jira workitem assign --jql "project = TEAM AND assignee is EMPTY" --assignee "dev@example.com" --yes
```

### `workitem clone`

| Flag | Description |
|------|-------------|
| `--key` | Source work item keys |
| `--jql` | JQL query |
| `--filter` | Filter ID |
| `--to-project` | Target project key |
| `--to-site` | Target Atlassian site (cross-site) |
| `--yes` | Skip confirmation |
| `--ignore-errors` | Continue on errors |

```bash
acli jira workitem clone --key "TEAM-1,TEAM-2" --to-project "OTHER"
```

### `workitem delete`

```bash
acli jira workitem delete --key "TEAM-1,TEAM-2"
acli jira workitem delete --jql "project = TEAM AND status = 'Cancelled'" --yes
```

### `workitem archive` / `workitem unarchive`

```bash
acli jira workitem archive --key "TEAM-1,TEAM-2" --yes
acli jira workitem archive --jql "project = TEAM AND status = Done AND updated <= -90d" --yes
acli jira workitem unarchive --key "TEAM-1,TEAM-2"
```

### `workitem comment create`

| Flag | Short | Description |
|------|-------|-------------|
| `--key` | `-k` | Work item keys |
| `--jql` | — | JQL query |
| `--body` | `-b` | Comment text |
| `--body-file` | `-F` | Read body from file |
| `--editor` | — | Open text editor |
| `--edit-last` | `-e` | Edit last comment from same author |

```bash
acli jira workitem comment create --key "TEAM-1" --body "Reviewed and approved"
acli jira workitem comment create --key "TEAM-1" --body-file review.txt
```

### `workitem comment list`

```bash
acli jira workitem comment list --key "TEAM-1" --order "+created" --json
```

### `workitem comment update`

```bash
acli jira workitem comment update --key "TEAM-1" --id 10001 --body "Updated comment"
acli jira workitem comment update --key "TEAM-1" --id 10001 --visibility-role "Administrators"
```

### `workitem comment delete`

```bash
acli jira workitem comment delete --key "TEAM-1" --id 10001
```

### `workitem comment visibility`

```bash
acli jira workitem comment visibility --role --project TEAM
acli jira workitem comment visibility --group
```

### `workitem attachment list`

```bash
acli jira workitem attachment list --key "TEAM-1" --json
```

### `workitem attachment delete`

```bash
acli jira workitem attachment delete --id 12345
```

### `workitem link create`

| Flag | Description |
|------|-------------|
| `--out` | Outward work item ID |
| `--in` | Inward work item ID |
| `--type` | Link type (e.g., "Blocks") |
| `--from-json` / `--from-csv` | Bulk input |

```bash
acli jira workitem link create --out "TEAM-10" --in "TEAM-20" --type "Blocks"
acli jira workitem link create --from-json links.json
```

### `workitem link delete`

```bash
acli jira workitem link delete --id 10001
```

### `workitem link list`

```bash
acli jira workitem link list --key "TEAM-1" --json
```

### `workitem link type`

```bash
acli jira workitem link type --json
```

### `workitem watcher remove`

```bash
acli jira workitem watcher remove --key "TEAM-1" --user <account-id>
```

---

## Cross-Cutting Features

### Output Formats

| Flag | Format | Use Case |
|------|--------|----------|
| *(default)* | Table | Terminal output |
| `--json` | JSON | Scripting, automation |
| `--csv` | CSV | Spreadsheets, reports |
| `--web` | Browser | Opens in Jira UI |

### Bulk Input Methods

| Method | Description |
|--------|-------------|
| `--from-json` | Structured JSON input (use `--generate-json` for format) |
| `--from-csv` | CSV input with standardized columns |
| `--from-file` | Text file with keys/IDs |
| `--jql` | JQL query for dynamic selection |
| `--filter` | Saved Jira filter ID |

### JSON Template Generation

```bash
acli jira workitem create --generate-json
acli jira workitem create-bulk --generate-json
acli jira workitem edit --generate-json
acli jira project create --generate-json
acli jira project update --generate-json
acli jira workitem link create --generate-json
```

### Safety Features

- **Confirmation prompts** on destructive/bulk operations (bypass with `--yes`)
- **`--ignore-errors`** to continue past individual failures in bulk ops
- **Soft delete** for fields (trash/restore) and work items (archive/unarchive)

---

## All Commands Quick Reference

| # | Command | Description |
|---|---------|-------------|
| 1 | `jira auth login` | Authenticate (OAuth or API token) |
| 2 | `jira auth logout` | Logout |
| 3 | `jira auth status` | Show account status |
| 4 | `jira auth switch` | Switch accounts |
| 5 | `jira board search` | Search boards |
| 6 | `jira board list-sprints` | List sprints on board |
| 7 | `jira dashboard search` | Search dashboards |
| 8 | `jira field create` | Create custom field |
| 9 | `jira field delete` | Trash custom field |
| 10 | `jira field cancel-delete` | Restore trashed field |
| 11 | `jira filter list` | List my/favourite filters |
| 12 | `jira filter search` | Search filters |
| 13 | `jira filter add-favourite` | Favourite a filter |
| 14 | `jira filter change-owner` | Change filter owner(s) |
| 15 | `jira project create` | Create project |
| 16 | `jira project list` | List projects |
| 17 | `jira project view` | View project details |
| 18 | `jira project update` | Update project |
| 19 | `jira project delete` | Delete project |
| 20 | `jira project archive` | Archive project |
| 21 | `jira project restore` | Restore project |
| 22 | `jira sprint list-workitems` | List sprint work items |
| 23 | `jira workitem create` | Create work item |
| 24 | `jira workitem create-bulk` | Bulk create (CSV/JSON) |
| 25 | `jira workitem edit` | Edit work item(s) |
| 26 | `jira workitem view` | View work item |
| 27 | `jira workitem search` | Search via JQL/filter |
| 28 | `jira workitem transition` | Change status |
| 29 | `jira workitem assign` | Assign/unassign |
| 30 | `jira workitem clone` | Duplicate work items |
| 31 | `jira workitem delete` | Delete work items |
| 32 | `jira workitem archive` | Archive work items |
| 33 | `jira workitem unarchive` | Unarchive work items |
| 34 | `jira workitem comment create` | Add comment |
| 35 | `jira workitem comment list` | List comments |
| 36 | `jira workitem comment update` | Update comment |
| 37 | `jira workitem comment delete` | Delete comment |
| 38 | `jira workitem comment visibility` | Get visibility options |
| 39 | `jira workitem attachment list` | List attachments |
| 40 | `jira workitem attachment delete` | Delete attachment |
| 41 | `jira workitem link create` | Create links |
| 42 | `jira workitem link delete` | Delete links |
| 43 | `jira workitem link list` | List links |
| 44 | `jira workitem link type` | Get link types |
| 45 | `jira workitem watcher remove` | Remove watcher |

---

*Source: [Official Atlassian CLI Reference](https://developer.atlassian.com/cloud/acli/reference/commands/)*
