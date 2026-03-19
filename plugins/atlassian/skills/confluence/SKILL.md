---
name: confluence
description: >
  Use when managing Confluence Cloud content from the command line using curl and the REST API.
  Covers creating, reading, updating, and deleting pages, managing comments, attachments,
  labels, and searching with CQL. Includes authentication setup and space management.
license: MIT
---

# Confluence Management with curl (REST API v2)

## Overview

This skill teaches you how to manage Confluence Cloud content — **pages, comments, attachments, labels, and spaces** — directly from the terminal using `curl` against the Confluence REST API.

> **Mandatory workflow before every task:** Check authentication → list spaces → ask user to select a space → then execute the task in the selected space.

**Use this skill when:**
- Creating, reading, updating, or deleting Confluence pages
- Searching for content with CQL (Confluence Query Language)
- Adding or managing comments on pages
- Uploading or listing attachments
- Adding or removing labels
- Listing or inspecting spaces
- Bulk-reading page content or metadata via the REST API

**Prerequisites:**
- `curl` installed (available by default on macOS, Linux, and Windows 10+)
- `jq` installed for JSON parsing (recommended)
- An Atlassian Cloud account with appropriate Confluence permissions
- An Atlassian API token ([create one here](https://id.atlassian.com/manage-profile/security/api-tokens))
- Three environment variables set:

```bash
# Unix (bash/zsh) — add to ~/.bashrc or ~/.zshrc
export CONFLUENCE_SITE="mysite.atlassian.net"
export CONFLUENCE_EMAIL="user@example.com"
export CONFLUENCE_TOKEN="your-api-token"
```

```powershell
# Windows (PowerShell) — add to $PROFILE
$env:CONFLUENCE_SITE = "mysite.atlassian.net"
$env:CONFLUENCE_EMAIL = "user@example.com"
$env:CONFLUENCE_TOKEN = "your-api-token"
```

## Mandatory Startup Workflow — ALWAYS EXECUTE BEFORE EVERY TASK

Every Confluence task **must** follow this exact three-step sequence. Do not skip any step.

### Step 1 — Check Authentication

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?limit=1" | jq '.results | length'
```

```powershell
$headers = @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$env:CONFLUENCE_EMAIL`:$env:CONFLUENCE_TOKEN"))
    "Content-Type" = "application/json"
    Accept = "application/json"
}
(Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/api/v2/spaces?limit=1" -Headers $headers).results.Count
```

If the response returns `0` or an error, the credentials are invalid. Prompt the user to:
1. Verify `CONFLUENCE_SITE`, `CONFLUENCE_EMAIL`, and `CONFLUENCE_TOKEN` are set correctly
2. Confirm the API token is valid at https://id.atlassian.com/manage-profile/security/api-tokens
3. Ensure the account has Confluence access on the target site

### Step 2 — List Available Spaces and Ask the User to Select One

After confirming authentication, **always** run:

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?limit=25" \
  | jq -r '.results[] | "\(.key) — \(.name)"'
```

```powershell
$spaces = Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/api/v2/spaces?limit=25" -Headers $headers
$spaces.results | ForEach-Object { "$($_.key) — $($_.name)" }
```

Present the list clearly to the user and **ask them which space they want to work with** before proceeding. Example prompt:

> The following Confluence spaces are available:
> - `DEV` — Development
> - `TEAM` — Team Wiki
> - `KB` — Knowledge Base
>
> Which space should I use for this task?

**Do NOT proceed to Step 3 until the user has explicitly confirmed or selected a space.**

If the user has a clear default context (e.g., previously confirmed `DEV` in this session), you may suggest it as the default but still ask for confirmation.

### Step 3 — Execute the Task with the Selected Space Key

Only after the user selects a space, proceed with the actual task. Replace `SPACEKEY` in all commands and CQL with the confirmed space key:

```bash
# Example: use the user-selected space key in all subsequent commands
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/search?cql=type%3Dpage%20AND%20space%3DSPACEKEY"
```

### Red Line — NEVER Skip This Workflow

- ❌ Do not guess or hard-code a space key without listing and confirming
- ❌ Do not run any CQL or create/edit commands before the user selects a space
- ❌ Do not skip the spaces listing even if you think you already know the space

---

## Body Formatting — ALWAYS Use Storage Format, NEVER Markdown

Confluence Cloud **does not accept Markdown** for page bodies. All page content must be written in **Storage Format** — an XHTML-based format. Passing plain Markdown will result in raw symbols (`##`, `**`, `-`) appearing literally on the page.

### Storage Format reference

| Storage Format | Purpose | Markdown equivalent |
|----------------|---------|---------------------|
| `<p>text</p>` | Paragraph | plain text |
| `<h1>text</h1>` through `<h6>` | Headings | `# Heading` |
| `<strong>text</strong>` | Bold | `**text**` |
| `<em>text</em>` | Italic | `*text*` |
| `<ul><li>item</li></ul>` | Bullet list | `- item` |
| `<ol><li>item</li></ol>` | Numbered list | `1. item` |
| `<a href=\"url\">text</a>` | Link | `[text](url)` |
| `<ac:structured-macro ac:name=\"code\">...</ac:structured-macro>` | Code block | `` ```code``` `` |
| `<hr />` | Horizontal rule | `---` |
| `<table><tr><th>Header</th></tr><tr><td>Cell</td></tr></table>` | Table | Markdown table |

### Full Storage Format template (bash)

```bash
cat > /tmp/page-body.json << 'EOF'
{
  "spaceId": "SPACE_ID",
  "status": "current",
  "title": "My New Page",
  "body": {
    "representation": "storage",
    "value": "<h2>Overview</h2><p>This is the introduction paragraph.</p><h2>Details</h2><ul><li>First item</li><li>Second item</li><li>Third item</li></ul><p>For more info see <a href=\"https://example.com\">the docs</a>.</p>"
  }
}
EOF
```

### Full Storage Format template (PowerShell)

```powershell
$body = @{
    spaceId = "SPACE_ID"
    status  = "current"
    title   = "My New Page"
    body    = @{
        representation = "storage"
        value          = "<h2>Overview</h2><p>This is the introduction paragraph.</p><h2>Details</h2><ul><li>First item</li><li>Second item</li><li>Third item</li></ul><p>For more info see <a href=`"https://example.com`">the docs</a>.</p>"
    }
} | ConvertTo-Json -Depth 5

$body | Out-File -FilePath "$env:TEMP\page-body.json" -Encoding UTF8
```

### Red Lines — Body Formatting

- ❌ `"value": "## Heading\n**Bold** text"` — Markdown not rendered, shows as raw symbols
- ❌ `"value": "Plain text with\nnewlines"` — No formatting at all
- ✅ Always use Storage Format XHTML: `"value": "<h2>Heading</h2><p><strong>Bold</strong> text</p>"`

---

## Quick Reference

| Action | Method | Endpoint | Key Details |
|--------|--------|----------|-------------|
| **Create page** | POST | `/wiki/api/v2/pages` | Body: spaceId, title, body (storage format) |
| **Get page** | GET | `/wiki/api/v2/pages/{id}?body-format=storage` | Returns page content and version |
| **Update page** | PUT | `/wiki/api/v2/pages/{id}` | MUST include incremented version.number |
| **Delete page** | DELETE | `/wiki/api/v2/pages/{id}` | Moves to trash by default |
| **List pages in space** | GET | `/wiki/api/v2/spaces/{id}/pages` | Paginated, use `limit` and `cursor` |
| **Search (CQL)** | GET | `/wiki/rest/api/search?cql=...` | Uses v1 API, URL-encode the CQL |
| **Get comments** | GET | `/wiki/api/v2/pages/{id}/footer-comments` | Footer comments on a page |
| **Create comment** | POST | `/wiki/api/v2/footer-comments` | Body: pageId, body (storage format) |
| **Upload attachment** | PUT | `/wiki/rest/api/content/{id}/child/attachment` | multipart/form-data, v1 API |
| **List attachments** | GET | `/wiki/api/v2/pages/{id}/attachments` | Returns file metadata |
| **Add label** | POST | `/wiki/rest/api/content/{id}/label` | Body: `[{"prefix":"global","name":"label"}]`, v1 API |
| **Remove label** | DELETE | `/wiki/rest/api/content/{id}/label/{label}` | v1 API |
| **List spaces** | GET | `/wiki/api/v2/spaces` | Paginated |
| **Get space** | GET | `/wiki/api/v2/spaces/{id}` | Returns space metadata |

## Core Workflows

### 1. Create a Page

You need the **space ID** (not the space key) to create a page via the v2 API. First, look it up:

```bash
# Get the space ID from the space key
SPACE_ID=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?keys=SPACEKEY" \
  | jq -r '.results[0].id')
```

Then create the page:

```bash
cat > /tmp/create-page.json << EOF
{
  "spaceId": "$SPACE_ID",
  "status": "current",
  "title": "My New Page",
  "body": {
    "representation": "storage",
    "value": "<h2>Overview</h2><p>Page content goes here.</p>"
  }
}
EOF

curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -X POST \
  --data @/tmp/create-page.json \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages" | jq '{id: .id, title: .title, status: .status}'
```

**Create a child page (nested under a parent):**

```bash
cat > /tmp/create-child.json << EOF
{
  "spaceId": "$SPACE_ID",
  "status": "current",
  "title": "Child Page",
  "parentId": "PARENT_PAGE_ID",
  "body": {
    "representation": "storage",
    "value": "<p>This page is nested under a parent.</p>"
  }
}
EOF

curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -X POST \
  --data @/tmp/create-child.json \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages" | jq '{id: .id, title: .title}'
```

**PowerShell equivalent:**

```powershell
$createBody = @{
    spaceId = $spaceId
    status  = "current"
    title   = "My New Page"
    body    = @{
        representation = "storage"
        value          = "<h2>Overview</h2><p>Page content goes here.</p>"
    }
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/api/v2/pages" `
  -Method Post -Headers $headers -Body $createBody
```

### 2. Search Pages (CQL)

CQL search uses the **v1 REST API** endpoint. Always URL-encode the CQL query.

```bash
# Search pages in a space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/search?cql=type%3Dpage%20AND%20space%3DSPACEKEY" \
  | jq '.results[] | {title: .content.title, id: .content.id}'

# Search by title
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/search?cql=type%3Dpage%20AND%20title~%22search%20term%22" \
  | jq '.results[] | {title: .content.title, id: .content.id}'

# Full text search
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/search?cql=siteSearch~%22search%20text%22%20AND%20type%3Dpage&limit=10" \
  | jq '.results[] | {title: .content.title, id: .content.id, excerpt: .excerpt}'
```

**PowerShell equivalent:**

```powershell
$cql = [System.Uri]::EscapeDataString("type=page AND space=SPACEKEY AND title~`"search term`"")
$results = Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/rest/api/search?cql=$cql" -Headers $headers
$results.results | ForEach-Object { [PSCustomObject]@{ Title = $_.content.title; Id = $_.content.id } }
```

### 3. View / Read a Page

```bash
# Get page by ID (including body content in storage format)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}?body-format=storage" \
  | jq '{id: .id, title: .title, version: .version.number, body: .body.storage.value}'

# Get page metadata only (no body)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}" \
  | jq '{id: .id, title: .title, status: .status, version: .version.number}'
```

**Tip:** To find a page ID, search by title first (see Section 2), then use the returned ID for subsequent operations.

### 4. Update a Page (Version Increment — CRITICAL)

> ⚠️ **Every page update MUST include an incremented version number.** If you omit or reuse the current version, the API will reject the request with a `409 Conflict`. This is the most common mistake when updating Confluence pages.

**Step 1 — Get the current version:**

```bash
VERSION=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}?body-format=storage" \
  | jq '.version.number')

echo "Current version: $VERSION"
```

**Step 2 — Increment and PUT:**

```bash
NEXT_VERSION=$((VERSION + 1))

cat > /tmp/update-page.json << EOF
{
  "id": "{id}",
  "status": "current",
  "title": "Updated Page Title",
  "body": {
    "representation": "storage",
    "value": "<h2>Updated Content</h2><p>This content has been updated via the API.</p>"
  },
  "version": {
    "number": $NEXT_VERSION,
    "message": "Updated via API"
  }
}
EOF

curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT \
  --data @/tmp/update-page.json \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}" | jq '{id: .id, title: .title, version: .version.number}'
```

**PowerShell equivalent:**

```powershell
# Step 1: Get current version
$page = Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/api/v2/pages/$pageId`?body-format=storage" -Headers $headers
$nextVersion = $page.version.number + 1

# Step 2: Update
$updateBody = @{
    id      = $pageId
    status  = "current"
    title   = "Updated Page Title"
    body    = @{
        representation = "storage"
        value          = "<h2>Updated Content</h2><p>Updated via API.</p>"
    }
    version = @{
        number  = $nextVersion
        message = "Updated via API"
    }
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/api/v2/pages/$pageId" `
  -Method Put -Headers $headers -Body $updateBody
```

### 5. Delete a Page

```bash
# Delete a page (moves to trash)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}"

# Purge a page permanently (skip trash)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}?purge=true"
```

**Always confirm with the user before deleting.** Deletion may be irreversible if purged.

### 6. List Pages in a Space

```bash
# List pages in a space (by space ID)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces/$SPACE_ID/pages?limit=25" \
  | jq '.results[] | {id: .id, title: .title, status: .status}'

# Paginate through all pages (follow the cursor)
CURSOR=""
while true; do
  RESPONSE=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
    -H "Accept: application/json" \
    "https://$CONFLUENCE_SITE/wiki/api/v2/spaces/$SPACE_ID/pages?limit=25&cursor=$CURSOR")
  echo "$RESPONSE" | jq '.results[] | {id: .id, title: .title}'
  CURSOR=$(echo "$RESPONSE" | jq -r '._links.next // empty' | grep -oP 'cursor=\K[^&]+')
  [ -z "$CURSOR" ] && break
done
```

**PowerShell equivalent:**

```powershell
$pages = Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/api/v2/spaces/$spaceId/pages?limit=25" -Headers $headers
$pages.results | ForEach-Object { [PSCustomObject]@{ Id = $_.id; Title = $_.title; Status = $_.status } }
```

### 7. Manage Comments

**List footer comments on a page:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}/footer-comments?body-format=storage" \
  | jq '.results[] | {id: .id, body: .body.storage.value}'
```

**Create a comment:**

```bash
cat > /tmp/comment.json << 'EOF'
{
  "pageId": "PAGE_ID",
  "body": {
    "representation": "storage",
    "value": "<p>This is a comment added via the API.</p>"
  }
}
EOF

curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -X POST \
  --data @/tmp/comment.json \
  "https://$CONFLUENCE_SITE/wiki/api/v2/footer-comments" | jq '{id: .id}'
```

**Delete a comment:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE \
  "https://$CONFLUENCE_SITE/wiki/api/v2/footer-comments/{comment-id}"
```

### 8. Manage Attachments

Attachment operations use the **v1 REST API** with `multipart/form-data`.

**Upload an attachment:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT \
  -H "X-Atlassian-Token: nocheck" \
  -F "file=@/path/to/file.pdf" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/child/attachment" \
  | jq '.results[] | {id: .id, title: .title, mediaType: .metadata.mediaType}'
```

**List attachments on a page:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/pages/{id}/attachments" \
  | jq '.results[] | {id: .id, title: .title, fileSize: .fileSize}'
```

**Download an attachment:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -o "downloaded-file.pdf" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/content/{attachment-id}/download"
```

**PowerShell upload equivalent:**

```powershell
$filePath = "C:\path\to\file.pdf"
$uri = "https://$env:CONFLUENCE_SITE/wiki/rest/api/content/$pageId/child/attachment"

$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileName = [System.IO.Path]::GetFileName($filePath)
$boundary = [System.Guid]::NewGuid().ToString()

$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
    "Content-Type: application/octet-stream",
    "",
    [System.Text.Encoding]::UTF8.GetString($fileBytes),
    "--$boundary--"
) -join "`r`n"

$uploadHeaders = @{
    Authorization        = $headers.Authorization
    "X-Atlassian-Token"  = "nocheck"
    "Content-Type"       = "multipart/form-data; boundary=$boundary"
}

Invoke-RestMethod -Uri $uri -Method Put -Headers $uploadHeaders -Body $bodyLines
```

### 9. Manage Labels

Labels use the **v1 REST API**.

**Add a label to a page:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  --data '[{"prefix": "global", "name": "my-label"}]' \
  "https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/label" \
  | jq '.results[] | {name: .name}'
```

**Add multiple labels:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  --data '[{"prefix":"global","name":"label-one"},{"prefix":"global","name":"label-two"}]' \
  "https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/label"
```

**List labels on a page:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/label" \
  | jq '.results[] | .name'
```

**Remove a label:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE \
  "https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/label/my-label"
```

### 10. Space Management

**List all spaces:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?limit=25" \
  | jq '.results[] | {id: .id, key: .key, name: .name, type: .type}'
```

**Get a specific space by key:**

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?keys=SPACEKEY" \
  | jq '.results[0] | {id: .id, key: .key, name: .name, description: .description}'
```

**Filter spaces by type:**

```bash
# Global spaces only
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?type=global&limit=25" \
  | jq '.results[] | {key: .key, name: .name}'

# Personal spaces only
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/api/v2/spaces?type=personal&limit=25" \
  | jq '.results[] | {key: .key, name: .name}'
```

---

## Common CQL Patterns

CQL (Confluence Query Language) is used with the v1 search endpoint. Always URL-encode the query when passing it in the URL.

```bash
# Pages in a space
cql=type=page AND space=SPACEKEY

# Search by title
cql=type=page AND title~"search term"

# Pages created by me
cql=type=page AND creator=currentUser()

# Recently modified
cql=type=page AND lastModified >= "2025-01-01"

# Modified in the last 7 days
cql=type=page AND lastModified >= now("-7d")

# Pages with a label
cql=type=page AND label="my-label"

# Blog posts in a space
cql=type=blogpost AND space=SPACEKEY

# Full text search
cql=siteSearch ~ "search text" AND type=page

# Pages by a specific author in a space
cql=type=page AND space=SPACEKEY AND creator="user@example.com"

# Combined: labeled pages modified recently in a space
cql=type=page AND space=SPACEKEY AND label="important" AND lastModified >= now("-7d")

# Pages without a specific label
cql=type=page AND space=SPACEKEY AND label != "archived"

# Ancestor (all pages under a parent)
cql=type=page AND ancestor=PAGE_ID
```

**Encoding CQL for curl:**

```bash
# Option 1: Use --data-urlencode (GET with query param)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  -G "https://$CONFLUENCE_SITE/wiki/rest/api/search" \
  --data-urlencode "cql=type=page AND space=SPACEKEY AND title~\"search term\"" \
  --data-urlencode "limit=25" \
  | jq '.results[] | {title: .content.title, id: .content.id}'

# Option 2: Manual URL encoding
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -H "Accept: application/json" \
  "https://$CONFLUENCE_SITE/wiki/rest/api/search?cql=type%3Dpage%20AND%20space%3DSPACEKEY"
```

**PowerShell CQL encoding:**

```powershell
$cql = [System.Uri]::EscapeDataString('type=page AND space=SPACEKEY AND title~"search term"')
$result = Invoke-RestMethod -Uri "https://$env:CONFLUENCE_SITE/wiki/rest/api/search?cql=$cql&limit=25" -Headers $headers
$result.results | ForEach-Object { [PSCustomObject]@{ Title = $_.content.title; Id = $_.content.id } }
```

---

## Output Handling

All Confluence REST API responses are JSON. Use `jq` (bash) or PowerShell's built-in JSON handling to parse responses.

**Common `jq` patterns:**

```bash
# Pretty-print full response
| jq .

# Extract specific fields
| jq '{id: .id, title: .title, version: .version.number}'

# List results from a search
| jq '.results[] | {title: .content.title, id: .content.id}'

# Get just the page body
| jq -r '.body.storage.value'

# Count results
| jq '.results | length'

# Get just IDs as a plain list
| jq -r '.results[].id'
```

**PowerShell equivalent patterns:**

```powershell
# Full response
$response | ConvertTo-Json -Depth 10

# Select specific fields
$response | Select-Object id, title, @{N='version'; E={$_.version.number}}

# Iterate search results
$response.results | ForEach-Object { [PSCustomObject]@{ Title = $_.content.title; Id = $_.content.id } }

# Count results
$response.results.Count
```

---

## Common Mistakes — STOP and Re-read

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Using Markdown in page body | Confluence does not render Markdown — raw symbols show up literally | Always use Storage Format XHTML: `<h2>Heading</h2><p>text</p>` |
| Omitting version number on update | API returns `409 Conflict` — updates require an incremented version | GET current version, add 1, include in PUT body |
| Reusing the same version number | API rejects the request with a conflict error | Always increment: `NEXT_VERSION=$((VERSION + 1))` |
| Skipping auth + space selection | Hard-coded keys may be wrong; user must confirm | Always run Steps 1–3 of the Mandatory Startup Workflow |
| Using space key instead of space ID for page creation | v2 API `POST /pages` requires `spaceId` (numeric), not space key | Look up spaceId first via `GET /spaces?keys=KEY` |
| Not URL-encoding CQL | Special characters break the query; API returns errors | Use `--data-urlencode` or `[System.Uri]::EscapeDataString()` |
| Using v2 API for search | Search/CQL is only on the v1 API | Use `https://$CONFLUENCE_SITE/wiki/rest/api/search?cql=...` |
| Using v2 API for labels | Label management is only on the v1 API | Use `https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/label` |
| Using v2 API for attachment upload | Upload is only on the v1 API | Use `https://$CONFLUENCE_SITE/wiki/rest/api/content/{id}/child/attachment` |
| Missing `X-Atlassian-Token: nocheck` on attachment upload | API rejects the upload with a XSRF error | Always include `-H "X-Atlassian-Token: nocheck"` |
| Forgetting `-H "Content-Type: application/json"` on POST/PUT | API may reject the body or misinterpret it | Always set Content-Type for JSON payloads |
| Guessing page IDs | Page IDs are numeric and opaque | Search by title first, then use the returned ID |

## Red Flags — If You Catch Yourself Doing This, STOP

- ❌ Using Markdown syntax in the `body.value` field (renders as raw text in Confluence)
- ❌ Skipping authentication check
- ❌ Skipping `GET /spaces` and the space selection question
- ❌ Hard-coding a space key without asking the user to confirm
- ❌ Updating a page without first GETting the current version number
- ❌ Using the same version number as the current page (must increment by 1)
- ❌ Using the v2 API for CQL search, labels, or attachment uploads
- ❌ Forgetting to URL-encode CQL queries
- ❌ Forgetting `X-Atlassian-Token: nocheck` on attachment uploads
- ❌ Using a space key where a space ID is required (e.g., page creation)
- ❌ Thinking "They're probably already authenticated"
- ❌ Thinking "I know the space key, no need to list and confirm"
- ❌ Writing page content in Markdown and hoping Confluence will convert it

**→ All of these mean: Stop, re-read this skill, use correct syntax.**

---

## Getting Help

- [Confluence Cloud REST API v2 documentation](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/)
- [Confluence Cloud REST API v1 documentation](https://developer.atlassian.com/cloud/confluence/rest/v1/intro/)
- [CQL syntax reference](https://developer.atlassian.com/cloud/confluence/advanced-searching-using-cql/)
- [Storage Format reference](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html)
- [API token management](https://id.atlassian.com/manage-profile/security/api-tokens)
