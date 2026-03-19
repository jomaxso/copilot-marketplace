# Confluence Cloud — curl Command Reference

Complete reference for all Confluence operations via curl. For quick-start workflows, see the main [SKILL.md](../SKILL.md).

---

## Authentication Setup

All commands use HTTP Basic Authentication with an Atlassian API token. Set these environment variables before running any commands.

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `CONFLUENCE_SITE` | Atlassian site hostname | `mysite.atlassian.net` |
| `CONFLUENCE_EMAIL` | Account email address | `user@example.com` |
| `CONFLUENCE_TOKEN` | API token ([create here](https://id.atlassian.com/manage-profile/security/api-tokens)) | `ATATT3x...` |

### Bash / macOS / Linux

```bash
export CONFLUENCE_SITE="mysite.atlassian.net"
export CONFLUENCE_EMAIL="user@example.com"
export CONFLUENCE_TOKEN="your-api-token"
```

### PowerShell

```powershell
$env:CONFLUENCE_SITE = "mysite.atlassian.net"
$env:CONFLUENCE_EMAIL = "user@example.com"
$env:CONFLUENCE_TOKEN = "your-api-token"
```

### Auth Header Pattern

Every curl command uses `-u` for Basic Auth:

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" ...
```

---

## Base URLs

| API Version | Base URL | Use Case |
|-------------|----------|----------|
| **v2** (primary) | `https://$CONFLUENCE_SITE/wiki/api/v2` | Spaces, pages, comments, attachments, labels, blog posts |
| **v1** (search/CQL) | `https://$CONFLUENCE_SITE/wiki/rest/api` | CQL search, attachment upload, label add/remove |

All examples below use `$V2` and `$V1` as shorthand:

```bash
V2="https://$CONFLUENCE_SITE/wiki/api/v2"
V1="https://$CONFLUENCE_SITE/wiki/rest/api"
```

---

## 1. Spaces (`/wiki/api/v2/spaces`)

### List spaces

| Parameter | Type | Description |
|-----------|------|-------------|
| `ids` | string | Comma-separated space IDs to filter by |
| `keys` | string | Comma-separated space keys to filter by |
| `type` | string | Space type: `global`, `personal` |
| `status` | string | Space status: `current`, `archived` |
| `labels` | string | Comma-separated labels to filter by |
| `sort` | string | Sort field: `id`, `-id`, `key`, `-key`, `name`, `-name` |
| `limit` | integer | Max results per page (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# List all global spaces
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces?type=global&limit=50" | jq '.results[] | {id, key, name}'

# List spaces by key
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces?keys=DEV,TEAM" | jq '.results[] | {id, key, name, status}'

# List archived spaces
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces?status=archived&limit=100" | jq '.results[] | {key, name}'
```

### Get space by ID

| Parameter | Type | Description |
|-----------|------|-------------|
| `description-format` | string | Format for description: `plain`, `view` |
| `include-icon` | boolean | Include space icon URL |
| `include-properties` | boolean | Include space properties |
| `include-labels` | boolean | Include space labels |

```bash
# Get space details
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces/12345?include-labels=true" | jq '{id, key, name, description, labels}'
```

### Get pages in space

| Parameter | Type | Description |
|-----------|------|-------------|
| `depth` | string | Page depth: `all` (default), `root` |
| `sort` | string | Sort: `id`, `-id`, `title`, `-title`, `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `status` | string | Page status: `current`, `archived`, `deleted`, `trashed` |
| `title` | string | Filter by exact page title |
| `body-format` | string | Body format: `storage`, `atlas_doc_format`, `view`, `export_view` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# List root-level pages in a space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces/12345/pages?depth=root&sort=title&limit=50" | jq '.results[] | {id, title, status}'

# Find a page by exact title in a space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces/12345/pages?title=Meeting+Notes" | jq '.results[] | {id, title}'
```

---

## 2. Pages (`/wiki/api/v2/pages`)

### List all pages

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Comma-separated page IDs to filter |
| `space-id` | string | Comma-separated space IDs to filter |
| `sort` | string | Sort: `id`, `-id`, `title`, `-title`, `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `status` | string | Page status: `current`, `archived`, `deleted`, `trashed` |
| `title` | string | Filter by exact title |
| `body-format` | string | Body format to return: `storage`, `atlas_doc_format`, `view`, `export_view` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# List pages in a specific space, sorted by most recently modified
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?space-id=12345&sort=-modified-date&limit=25" | jq '.results[] | {id, title, status}'

# Get pages by IDs
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?id=111,222,333&body-format=storage" | jq '.results[] | {id, title}'
```

### Get page by ID

| Parameter | Type | Description |
|-----------|------|-------------|
| `body-format` | string | Body format: `storage`, `atlas_doc_format`, `view`, `export_view` |
| `get-draft` | boolean | Return the draft version if it exists |
| `status` | string | Filter by status: `current`, `archived`, `deleted`, `trashed` |
| `version` | integer | Specific version number to retrieve |
| `include-labels` | boolean | Include page labels |
| `include-properties` | boolean | Include content properties |
| `include-versions` | boolean | Include version history |

```bash
# Get page with storage-format body
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765?body-format=storage" | jq '{id, title, version, body}'

# Get page with labels and version history
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765?include-labels=true&include-versions=true" | jq '{id, title, labels, versions}'

# Get a specific version of a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765?version=3&body-format=storage" | jq '{id, title, version}'
```

### Create page

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `spaceId` | string | ✅ | ID of the space to create the page in |
| `status` | string | — | Page status: `current` (default), `draft` |
| `title` | string | ✅ | Page title |
| `parentId` | string | — | Parent page ID (omit for root-level page) |
| `body.representation` | string | ✅ | Body format: `storage`, `atlas_doc_format`, `wiki` |
| `body.value` | string | ✅ | Page body content |

```bash
# Create a root-level page with storage format
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V2/pages" \
  -H "Content-Type: application/json" \
  -d '{
    "spaceId": "12345",
    "status": "current",
    "title": "My New Page",
    "body": {
      "representation": "storage",
      "value": "<p>Hello, Confluence!</p>"
    }
  }' | jq '{id, title, status}'

# Create a child page under an existing parent
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V2/pages" \
  -H "Content-Type: application/json" \
  -d '{
    "spaceId": "12345",
    "status": "current",
    "title": "Sub-Page Under Parent",
    "parentId": "98765",
    "body": {
      "representation": "storage",
      "value": "<h2>Section 1</h2><p>Content here.</p>"
    }
  }' | jq '{id, title, parentId}'

# Create a draft page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V2/pages" \
  -H "Content-Type: application/json" \
  -d '{
    "spaceId": "12345",
    "status": "draft",
    "title": "Work in Progress",
    "body": {
      "representation": "storage",
      "value": "<p>Draft content...</p>"
    }
  }' | jq '{id, title, status}'
```

### Update page (with version increment)

> **Important:** You MUST increment `version.number` on every update. Fetch the current version first, then add 1. Failing to increment causes a `409 Conflict` error.

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `id` | string | ✅ | Page ID (must match URL) |
| `status` | string | ✅ | Page status: `current`, `draft` |
| `title` | string | ✅ | Page title |
| `body.representation` | string | ✅ | Body format: `storage`, `atlas_doc_format`, `wiki` |
| `body.value` | string | ✅ | Updated body content |
| `version.number` | integer | ✅ | **Must be current version + 1** |
| `version.message` | string | — | Optional version comment |

```bash
# Step 1: Get current version number
VERSION=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765" | jq '.version.number')

# Step 2: Update with incremented version
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT "$V2/pages/98765" \
  -H "Content-Type: application/json" \
  -d "{
    \"id\": \"98765\",
    \"status\": \"current\",
    \"title\": \"Updated Page Title\",
    \"body\": {
      \"representation\": \"storage\",
      \"value\": \"<p>Updated content.</p>\"
    },
    \"version\": {
      \"number\": $((VERSION + 1)),
      \"message\": \"Updated via API\"
    }
  }" | jq '{id, title, version}'
```

### Update page title

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `status` | string | ✅ | Current page status |
| `title` | string | ✅ | New page title |

```bash
# Rename a page (title only, no body change)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT "$V2/pages/98765/title" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "current",
    "title": "Renamed Page Title"
  }' | jq '{id, title}'
```

### Delete page

| Parameter | Type | Description |
|-----------|------|-------------|
| `purge` | boolean | `true` to permanently delete (skip trash) |
| `draft` | boolean | `true` if deleting a draft |

```bash
# Move page to trash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/pages/98765"

# Permanently delete (purge)
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/pages/98765?purge=true"
```

### Get child pages

```bash
# Get direct children of a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765/children" | jq '.results[] | {id, title}'

# Get child pages with body content
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765/children?body-format=storage&limit=50" | jq '.results[] | {id, title}'
```

### Get pages for label

```bash
# Get all pages with a specific label
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/labels/67890/pages" | jq '.results[] | {id, title}'
```

---

## 3. Comments

### List footer comments on page

| Parameter | Type | Description |
|-----------|------|-------------|
| `body-format` | string | Body format: `storage`, `atlas_doc_format`, `view` |
| `sort` | string | Sort: `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# Get footer comments on a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765/footer-comments?body-format=storage" | jq '.results[] | {id, body, version}'
```

### List inline comments on page

| Parameter | Type | Description |
|-----------|------|-------------|
| `body-format` | string | Body format: `storage`, `atlas_doc_format`, `view` |
| `sort` | string | Sort: `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `resolution-status` | string | Filter by status: `open`, `resolved`, `dangling` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# Get open inline comments
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765/inline-comments?resolution-status=open&body-format=storage" \
  | jq '.results[] | {id, body, resolutionStatus}'
```

### List all footer comments

```bash
# Get all footer comments across all content
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/footer-comments?body-format=storage&limit=50" | jq '.results[] | {id, pageId}'
```

### Get specific footer comment

```bash
# Get a single footer comment by ID
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/footer-comments/11111?body-format=storage" | jq '{id, body, version}'
```

### Create footer comment

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `pageId` | string | ✅* | Page to comment on (*either `pageId` or `blogPostId` required) |
| `blogPostId` | string | ✅* | Blog post to comment on |
| `body.representation` | string | ✅ | Body format: `storage`, `atlas_doc_format`, `wiki` |
| `body.value` | string | ✅ | Comment content |
| `parentCommentId` | string | — | Parent comment ID for threaded replies |

```bash
# Add a footer comment to a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V2/footer-comments" \
  -H "Content-Type: application/json" \
  -d '{
    "pageId": "98765",
    "body": {
      "representation": "storage",
      "value": "<p>This is a comment.</p>"
    }
  }' | jq '{id, pageId}'

# Reply to an existing comment
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V2/footer-comments" \
  -H "Content-Type: application/json" \
  -d '{
    "pageId": "98765",
    "parentCommentId": "11111",
    "body": {
      "representation": "storage",
      "value": "<p>Replying to your comment.</p>"
    }
  }' | jq '{id, parentCommentId}'
```

### Update footer comment

> **Important:** You MUST increment `version.number` on every update, just like pages.

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `version.number` | integer | ✅ | Current version + 1 |
| `body.representation` | string | ✅ | Body format |
| `body.value` | string | ✅ | Updated comment content |
| `status` | string | — | Status: `current` |

```bash
# Update a footer comment
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT "$V2/footer-comments/11111" \
  -H "Content-Type: application/json" \
  -d '{
    "version": {
      "number": 2
    },
    "body": {
      "representation": "storage",
      "value": "<p>Updated comment text.</p>"
    },
    "status": "current"
  }' | jq '{id, version}'
```

### Delete footer comment

```bash
# Delete a footer comment
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/footer-comments/11111"
```

---

## 4. Attachments

### List all attachments

| Parameter | Type | Description |
|-----------|------|-------------|
| `sort` | string | Sort: `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `status` | string | Attachment status: `current`, `archived`, `trashed` |
| `mediaType` | string | Filter by MIME type (e.g., `image/png`) |
| `filename` | string | Filter by exact filename |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# List all attachments
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/attachments?limit=50" | jq '.results[] | {id, title, mediaType, fileSize}'
```

### Get attachment by ID

```bash
# Get attachment metadata
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/attachments/att12345" | jq '{id, title, mediaType, fileSize, downloadLink}'
```

### List attachments on page

| Parameter | Type | Description |
|-----------|------|-------------|
| `sort` | string | Sort: `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `status` | string | Attachment status |
| `mediaType` | string | Filter by MIME type |
| `filename` | string | Filter by exact filename |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# List attachments on a specific page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765/attachments?limit=50" | jq '.results[] | {id, title, mediaType, fileSize}'
```

### Upload attachment (multipart, v1 API)

> **Note:** Attachment upload uses the **v1 API** and requires the `X-Atlassian-Token: nocheck` header to bypass XSRF protection.

| Header / Field | Type | Required | Description |
|----------------|------|----------|-------------|
| `X-Atlassian-Token` | header | ✅ | Must be `nocheck` |
| `file` | form field | ✅ | The file to upload (`@path/to/file`) |
| `comment` | form field | — | Comment/description for the attachment |

```bash
# Upload a file to a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT "$V1/content/98765/child/attachment" \
  -H "X-Atlassian-Token: nocheck" \
  -F "file=@/path/to/document.pdf" \
  -F "comment=Uploaded via API" | jq '.results[] | {id: .id, title: .title}'

# Upload and overwrite an existing attachment
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT "$V1/content/98765/child/attachment" \
  -H "X-Atlassian-Token: nocheck" \
  -F "file=@/path/to/updated-document.pdf" | jq '.results[] | {id: .id, title: .title}'
```

### Delete attachment

| Parameter | Type | Description |
|-----------|------|-------------|
| `purge` | boolean | `true` to permanently delete (skip trash) |

```bash
# Move attachment to trash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/attachments/att12345"

# Permanently delete
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/attachments/att12345?purge=true"
```

---

## 5. Labels

### Get labels for page

| Parameter | Type | Description |
|-----------|------|-------------|
| `prefix` | string | Filter by label prefix: `global`, `my`, `team` |
| `sort` | string | Sort: `label-name`, `-label-name`, `created-date`, `-created-date` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# Get all labels on a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765/labels" | jq '.results[] | {id, name, prefix}'
```

### Add label to page (v1 API)

> **Note:** Adding labels uses the **v1 API**. The body is a JSON array of label objects.

```bash
# Add a single label
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V1/content/98765/label" \
  -H "Content-Type: application/json" \
  -d '[{"prefix": "global", "name": "my-label"}]' | jq '.results[] | {name, id}'

# Add multiple labels at once
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V1/content/98765/label" \
  -H "Content-Type: application/json" \
  -d '[
    {"prefix": "global", "name": "documentation"},
    {"prefix": "global", "name": "api-reference"}
  ]' | jq '.results[] | {name, id}'
```

### Remove label from page (v1 API)

> **Note:** Removing labels uses the **v1 API**.

```bash
# Remove a label from a page
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V1/content/98765/label/my-label"
```

### Get labels for space

| Parameter | Type | Description |
|-----------|------|-------------|
| `prefix` | string | Filter by label prefix |
| `sort` | string | Sort: `label-name`, `-label-name`, `created-date`, `-created-date` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# Get all labels in a space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/spaces/12345/labels" | jq '.results[] | {id, name, prefix}'
```

### List all labels

```bash
# Get all labels in the Confluence instance
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/labels?limit=100" | jq '.results[] | {id, name, prefix}'
```

---

## 6. Search (CQL — v1 API)

> **Note:** Search uses the **v1 API** exclusively. CQL (Confluence Query Language) is used for all search operations.

### Search with CQL

| Parameter | Type | Description |
|-----------|------|-------------|
| `cql` | string | CQL query string (required) |
| `cqlcontext` | string | JSON object for CQL context (e.g., space key) |
| `limit` | integer | Max results per page (default 25, max 200) |
| `start` | integer | Offset-based pagination starting index |
| `expand` | string | Comma-separated properties to expand (e.g., `content.body.storage`, `content.version`, `content.ancestors`) |

```bash
# Search for pages containing "architecture"
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  --get "$V1/search" \
  --data-urlencode 'cql=type=page AND text~"architecture"' \
  --data-urlencode 'limit=25' | jq '.results[] | {title: .content.title, id: .content.id, space: .content.space.key}'

# Search in a specific space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  --get "$V1/search" \
  --data-urlencode 'cql=type=page AND space="DEV" AND title~"API"' \
  --data-urlencode 'limit=50' | jq '.results[] | {title: .content.title, id: .content.id}'

# Search with expanded body content
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  --get "$V1/search" \
  --data-urlencode 'cql=type=page AND label="release-notes"' \
  --data-urlencode 'expand=content.body.storage,content.version' \
  --data-urlencode 'limit=10' | jq '.results[] | {title: .content.title, body: .content.body.storage.value}'

# Search for recently modified pages by a user
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  --get "$V1/search" \
  --data-urlencode 'cql=type=page AND contributor=currentUser() AND lastModified > now("-7d")' \
  --data-urlencode 'limit=20' | jq '.results[] | {title: .content.title, id: .content.id}'
```

### Common CQL Patterns

| CQL Expression | Description |
|----------------|-------------|
| `type=page` | Only pages |
| `type=blogpost` | Only blog posts |
| `type=attachment` | Only attachments |
| `space="KEY"` | In a specific space |
| `space.type=personal` | In personal spaces |
| `title="Exact Title"` | Exact title match |
| `title~"partial"` | Title contains text |
| `text~"search term"` | Full-text search across body |
| `label="my-label"` | Has a specific label |
| `label in ("a","b")` | Has any of the listed labels |
| `ancestor=12345` | Descendant of page ID |
| `parent=12345` | Direct child of page ID |
| `creator=currentUser()` | Created by current user |
| `contributor="user-account-id"` | Modified by user |
| `created > now("-7d")` | Created in the last 7 days |
| `lastModified >= "2024-01-01"` | Modified since date |
| `id in (111,222,333)` | Specific content IDs |

**Combining with operators:**

```
type=page AND space="DEV" AND label="api" AND lastModified > now("-30d")
type=page AND (title~"guide" OR title~"tutorial") AND space="DOCS"
type=page AND text~"migration" AND NOT label="archived"
```

---

## 7. Blog Posts (`/wiki/api/v2/blogposts`)

### List blog posts

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Comma-separated blog post IDs to filter |
| `space-id` | string | Comma-separated space IDs to filter |
| `sort` | string | Sort: `id`, `-id`, `title`, `-title`, `created-date`, `-created-date`, `modified-date`, `-modified-date` |
| `status` | string | Blog post status: `current`, `deleted`, `trashed` |
| `title` | string | Filter by exact title |
| `body-format` | string | Body format: `storage`, `atlas_doc_format`, `view`, `export_view` |
| `limit` | integer | Max results (default 25, max 250) |
| `cursor` | string | Cursor for pagination |

```bash
# List recent blog posts in a space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/blogposts?space-id=12345&sort=-created-date&limit=10" | jq '.results[] | {id, title, createdAt}'
```

### Get blog post by ID

| Parameter | Type | Description |
|-----------|------|-------------|
| `body-format` | string | Body format: `storage`, `atlas_doc_format`, `view`, `export_view` |
| `get-draft` | boolean | Return draft version |
| `version` | integer | Specific version number |
| `include-labels` | boolean | Include labels |
| `include-properties` | boolean | Include content properties |
| `include-versions` | boolean | Include version history |
| `status` | string | Filter by status |

```bash
# Get blog post with body content
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/blogposts/55555?body-format=storage&include-labels=true" | jq '{id, title, body, labels}'
```

### Create blog post

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `spaceId` | string | ✅ | Space ID |
| `status` | string | — | Status: `current` (default), `draft` |
| `title` | string | ✅ | Blog post title |
| `body.representation` | string | ✅ | Body format: `storage`, `atlas_doc_format`, `wiki` |
| `body.value` | string | ✅ | Blog post body content |

```bash
# Create a blog post
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X POST "$V2/blogposts" \
  -H "Content-Type: application/json" \
  -d '{
    "spaceId": "12345",
    "status": "current",
    "title": "Sprint 42 Retrospective",
    "body": {
      "representation": "storage",
      "value": "<h2>What went well</h2><p>Shipped on time!</p>"
    }
  }' | jq '{id, title, status}'
```

### Update blog post

> **Important:** You MUST increment `version.number` on every update, same as pages.

| Body Field | Type | Required | Description |
|------------|------|----------|-------------|
| `id` | string | ✅ | Blog post ID (must match URL) |
| `status` | string | ✅ | Blog post status |
| `title` | string | ✅ | Blog post title |
| `body.representation` | string | ✅ | Body format |
| `body.value` | string | ✅ | Updated body content |
| `version.number` | integer | ✅ | **Must be current version + 1** |
| `version.message` | string | — | Optional version comment |

```bash
# Step 1: Get current version number
VERSION=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/blogposts/55555" | jq '.version.number')

# Step 2: Update with incremented version
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X PUT "$V2/blogposts/55555" \
  -H "Content-Type: application/json" \
  -d "{
    \"id\": \"55555\",
    \"status\": \"current\",
    \"title\": \"Sprint 42 Retrospective (Updated)\",
    \"body\": {
      \"representation\": \"storage\",
      \"value\": \"<h2>What went well</h2><p>Shipped on time and under budget!</p>\"
    },
    \"version\": {
      \"number\": $((VERSION + 1)),
      \"message\": \"Added budget note\"
    }
  }" | jq '{id, title, version}'
```

### Delete blog post

| Parameter | Type | Description |
|-----------|------|-------------|
| `purge` | boolean | `true` to permanently delete |

```bash
# Move blog post to trash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/blogposts/55555"

# Permanently delete
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  -X DELETE "$V2/blogposts/55555?purge=true"
```

---

## Cross-Cutting Features

### Pagination (cursor-based)

The v2 API uses **cursor-based pagination**. Each response includes a `_links.next` URL if more results are available.

```bash
# First request
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?limit=25" | jq '.results[] | {id, title}'

# Check for next page
NEXT=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?limit=25" | jq -r '._links.next // empty')

# If NEXT is not empty, fetch next page
if [ -n "$NEXT" ]; then
  curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
    "https://$CONFLUENCE_SITE${NEXT}"
fi
```

**Loop through all pages:**

```bash
URL="$V2/pages?space-id=12345&limit=100"
while [ -n "$URL" ]; do
  RESPONSE=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" "$URL")
  echo "$RESPONSE" | jq '.results[] | {id, title}'
  URL=$(echo "$RESPONSE" | jq -r '._links.next // empty')
  if [ -n "$URL" ]; then
    URL="https://$CONFLUENCE_SITE${URL}"
  fi
done
```

> **Note:** The v1 search API uses **offset-based pagination** with `start` and `limit` parameters instead of cursors.

```bash
# Offset-based pagination for v1 search
START=0
LIMIT=50
while true; do
  RESPONSE=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
    --get "$V1/search" \
    --data-urlencode 'cql=type=page AND space="DEV"' \
    --data-urlencode "limit=$LIMIT" \
    --data-urlencode "start=$START")
  echo "$RESPONSE" | jq '.results[] | {title: .content.title, id: .content.id}'
  TOTAL=$(echo "$RESPONSE" | jq '.totalSize')
  START=$((START + LIMIT))
  if [ "$START" -ge "$TOTAL" ]; then break; fi
done
```

### Output Formats (JSON parsing with jq)

| jq Pattern | Use Case |
|------------|----------|
| `jq '.'` | Pretty-print full JSON response |
| `jq '.results[]'` | Iterate over result array |
| `jq '.results[] \| {id, title}'` | Extract specific fields |
| `jq '.results \| length'` | Count results |
| `jq -r '.results[] \| [.id, .title] \| @csv'` | CSV output |
| `jq -r '.results[] \| [.id, .title] \| @tsv'` | TSV output |
| `jq '.results[] \| select(.status == "current")'` | Filter results |
| `jq '._links.next // empty'` | Get next pagination cursor |

**Common output examples:**

```bash
# Pretty table-like output
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?space-id=12345&limit=50" \
  | jq -r '.results[] | "\(.id)\t\(.title)\t\(.status)"'

# CSV export
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?space-id=12345&limit=250" \
  | jq -r '["id","title","status"], (.results[] | [.id, .title, .status]) | @csv'

# Count pages in a space
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages?space-id=12345&limit=1" | jq '.results | length'
```

### Error Handling (HTTP status codes)

| Status Code | Meaning | Common Cause |
|-------------|---------|--------------|
| 200 | Success | — |
| 201 | Created | Resource created successfully |
| 204 | No Content | Successful delete |
| 400 | Bad Request | Invalid body, missing required field, malformed JSON |
| 401 | Unauthorized | Invalid or missing credentials |
| 403 | Forbidden | Insufficient permissions for the space or page |
| 404 | Not Found | Invalid page/space/comment ID, or resource in trash |
| 409 | Conflict | Version conflict — `version.number` was not incremented |
| 413 | Payload Too Large | Attachment exceeds size limit |
| 429 | Rate Limited | Too many requests — back off and retry |

**Checking for errors in scripts:**

```bash
# Check HTTP status code
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/98765")

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "Error: HTTP $HTTP_CODE"
fi

# Get error message from response
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
  "$V2/pages/invalid-id" | jq '{statusCode: .statusCode, message: .message}'
```

---

## All Endpoints Quick Reference

| # | Method | Endpoint | Description |
|---|--------|----------|-------------|
| 1 | GET | `/wiki/api/v2/spaces` | List spaces |
| 2 | GET | `/wiki/api/v2/spaces/{id}` | Get space by ID |
| 3 | GET | `/wiki/api/v2/spaces/{id}/pages` | Get pages in space |
| 4 | GET | `/wiki/api/v2/pages` | List all pages |
| 5 | GET | `/wiki/api/v2/pages/{id}` | Get page by ID |
| 6 | POST | `/wiki/api/v2/pages` | Create page |
| 7 | PUT | `/wiki/api/v2/pages/{id}` | Update page (version increment required) |
| 8 | PUT | `/wiki/api/v2/pages/{id}/title` | Update page title only |
| 9 | DELETE | `/wiki/api/v2/pages/{id}` | Delete page |
| 10 | GET | `/wiki/api/v2/pages/{id}/children` | Get child pages |
| 11 | GET | `/wiki/api/v2/labels/{id}/pages` | Get pages for label |
| 12 | GET | `/wiki/api/v2/pages/{id}/footer-comments` | Footer comments for page |
| 13 | GET | `/wiki/api/v2/pages/{id}/inline-comments` | Inline comments for page |
| 14 | GET | `/wiki/api/v2/footer-comments` | List all footer comments |
| 15 | GET | `/wiki/api/v2/footer-comments/{id}` | Get specific footer comment |
| 16 | POST | `/wiki/api/v2/footer-comments` | Create footer comment |
| 17 | PUT | `/wiki/api/v2/footer-comments/{id}` | Update footer comment |
| 18 | DELETE | `/wiki/api/v2/footer-comments/{id}` | Delete footer comment |
| 19 | GET | `/wiki/api/v2/attachments` | List all attachments |
| 20 | GET | `/wiki/api/v2/attachments/{id}` | Get attachment by ID |
| 21 | GET | `/wiki/api/v2/pages/{id}/attachments` | Attachments for page |
| 22 | PUT | `/wiki/rest/api/content/{id}/child/attachment` | Upload attachment (v1 API) |
| 23 | DELETE | `/wiki/api/v2/attachments/{id}` | Delete attachment |
| 24 | GET | `/wiki/api/v2/pages/{id}/labels` | Labels for page |
| 25 | POST | `/wiki/rest/api/content/{id}/label` | Add label to page (v1 API) |
| 26 | DELETE | `/wiki/rest/api/content/{id}/label/{label}` | Remove label from page (v1 API) |
| 27 | GET | `/wiki/api/v2/spaces/{id}/labels` | Labels for space |
| 28 | GET | `/wiki/api/v2/labels` | List all labels |
| 29 | GET | `/wiki/rest/api/search?cql=...` | CQL search (v1 API) |
| 30 | GET | `/wiki/api/v2/blogposts` | List blog posts |
| 31 | GET | `/wiki/api/v2/blogposts/{id}` | Get blog post by ID |
| 32 | POST | `/wiki/api/v2/blogposts` | Create blog post |
| 33 | PUT | `/wiki/api/v2/blogposts/{id}` | Update blog post (version increment required) |
| 34 | DELETE | `/wiki/api/v2/blogposts/{id}` | Delete blog post |

---

*Source: [Confluence Cloud REST API v2](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/) · [Confluence Cloud REST API v1](https://developer.atlassian.com/cloud/confluence/rest/v1/intro/) · [CQL Reference](https://developer.atlassian.com/cloud/confluence/advanced-searching-using-cql/)*
