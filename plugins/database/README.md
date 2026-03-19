# Database Plugin

Manage MariaDB databases directly from the terminal using the native `mariadb` CLI client.

## Install

```bash
copilot plugin install database@jomaxso-plugins
```

## Included skills

| Skill | Description |
|-------|-------------|
| `database` | Connect to MariaDB, run queries, manage databases and users, create and apply configuration files (my.cnf / my.ini) |

## Prerequisites

- **MariaDB client tools** — install scripts in `skills/database/scripts/`:
  - Windows: `.\install-windows.ps1`
  - Linux: `chmod +x install-linux.sh && ./install-linux.sh`
  - macOS: `chmod +x install-macos.sh && ./install-macos.sh`
- A running MariaDB server (local or remote) with valid credentials

## Usage

After installing the plugin, the `database` skill is available automatically. Verify with:

```
/skills list
```

Then ask Copilot to help with MariaDB — connecting to servers, creating databases, running SQL queries, managing users, generating config files, and more.
