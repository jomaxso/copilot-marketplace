# Copilot CLI Marketplace

Personal GitHub Copilot CLI marketplace with custom plugins, agents, and skills.

## Register this marketplace

```bash
copilot plugin marketplace add jomaxso/copilot-marketplace
```

## Available plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [`atlassian`](./plugins/atlassian) | Manage Jira Cloud work items via `acli` — create, edit, search, transition issues with proper ADF formatting | 1.0.0 |

## Install a plugin

```bash
# From marketplace
copilot plugin install atlassian@jomaxso-plugins

# Directly from GitHub
copilot plugin install jomaxso/copilot-marketplace:plugins/atlassian
```

## Add a new plugin

1. Create `plugins/<name>/` with a `plugin.json` manifest
2. Add `skills/`, `agents/`, `.mcp.json` as needed
3. Register the entry in `.github/plugin/marketplace.json`
4. Push — done.

## Repository structure

```
copilot-marketplace/
├── .github/plugin/
│   └── marketplace.json          # Marketplace manifest (required)
└── plugins/
    └── atlassian/                 # Atlassian tools plugin
        ├── plugin.json
        ├── README.md
        └── skills/
            └── jira/              # Jira management skill
                ├── SKILL.md
                ├── references/
                │   └── REFERENCE.md
                └── scripts/
                    ├── install-windows.ps1
                    ├── install-linux.sh
                    └── install-macos.sh
```

