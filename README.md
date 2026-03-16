# Copilot CLI Marketplace

Personal GitHub Copilot CLI marketplace containing custom plugins, agents, and skills.

## Install this marketplace

```bash
copilot plugin marketplace add jomaxso/copilot-marketplace
```

## Available plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| `atlassian` | Manage Jira Cloud work items via `acli` (create, edit, search, transition, ADF descriptions) | 1.0.0 |

## Install a plugin

```bash
# Install from this marketplace
copilot plugin install atlassian@jomaxso-copilot-marketplace

# Or install directly
copilot plugin install jomaxso/copilot-marketplace:plugins/atlassian
```

## Adding new plugins

1. Create a new directory under `plugins/<name>/`
2. Add a `plugin.json` manifest
3. Add `skills/`, `agents/`, `.mcp.json` etc. as needed
4. Register the plugin in `.github/plugin/marketplace.json`

## Structure

```
copilot-marketplace/
├── .github/plugin/
│   └── marketplace.json      # Marketplace manifest
└── plugins/
    └── atlassian/                # Atlassian/Jira management plugin
        ├── plugin.json
        └── skills/
            └── jira/
                ├── SKILL.md
                ├── references/
                │   └── REFERENCE.md
                └── scripts/
                    ├── install-windows.ps1
                    ├── install-linux.sh
                    └── install-macos.sh
```
