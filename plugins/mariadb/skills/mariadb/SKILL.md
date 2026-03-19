---
name: mariadb
description: >
  Use when managing MariaDB databases from the command line using the mariadb CLI client.
  Covers connecting to servers, creating and managing databases, running SQL queries,
  administering users and permissions, backing up and restoring data, and generating
  or applying MariaDB configuration files (my.cnf on Unix/macOS, my.ini on Windows)
  with AI assistance. Handles platform differences between Unix/macOS and Windows.
license: MIT
---

# MariaDB CLI Management

## Overview

The `mariadb` CLI client is the standard command-line tool for interacting with MariaDB (and MySQL-compatible) servers. This skill teaches you how to manage databases, run queries, administer users, and maintain your server configuration — all from the terminal.

> **Mandatory workflow before every task:** Determine the target server and credentials → establish a connection → then execute the task.

**Use this skill when:**
- Connecting to a local or remote MariaDB server
- Creating, listing, or dropping databases and tables
- Running SQL queries (SELECT, INSERT, UPDATE, DELETE)
- Managing users and permissions (GRANT, REVOKE, CREATE USER)
- Backing up databases with `mariadb-dump` / `mysqldump`
- Restoring databases from SQL dump files
- Generating or editing the MariaDB configuration file (`my.cnf` / `my.ini`) with AI
- Troubleshooting server status, slow queries, or performance

**Prerequisites:**
- MariaDB client tools installed:
  - **Windows:** `.\install-windows.ps1`
  - **Linux:** `chmod +x install-linux.sh && ./install-linux.sh`
  - **macOS:** `chmod +x install-macos.sh && ./install-macos.sh`
- A running MariaDB server (local or remote)
- Valid credentials (user + password or `~/.my.cnf` / `%APPDATA%\MariaDB\my.ini` with stored credentials)

---

## Platform Differences — Unix vs. Windows

Many MariaDB operations differ between Unix/macOS and Windows. Always respect the platform context.

| Aspect | Unix / macOS | Windows |
|--------|-------------|---------|
| **Config file** | `/etc/mysql/my.cnf`, `~/.my.cnf` | `C:\ProgramData\MariaDB\data\my.ini`, `%APPDATA%\MariaDB\my.ini` |
| **Socket connection** | `--socket=/var/run/mysqld/mysqld.sock` | TCP only: `--host=127.0.0.1 --port=3306` |
| **Service management** | `sudo systemctl start mariadb` | `net start mariadb` (or Services GUI) |
| **Shell quoting** | Single quotes `'value'` in SQL strings | Use double-quoted heredoc or temp file in PowerShell |
| **Path separator** | `/` | `\` or `/` (both work in MariaDB client) |
| **Temp file location** | `/tmp/` | `%TEMP%\` |
| **CLI binary** | `mariadb` (or `mysql`) | `mariadb.exe` (or `mysql.exe`) |
| **Dump binary** | `mariadb-dump` (or `mysqldump`) | `mariadb-dump.exe` (or `mysqldump.exe`) |
| **Admin binary** | `mariadb-admin` (or `mysqladmin`) | `mariadb-admin.exe` (or `mysqladmin.exe`) |

---

## Mandatory Startup Workflow — ALWAYS EXECUTE BEFORE EVERY TASK

Every MariaDB task **must** follow this connection verification sequence.

### Step 1 — Confirm Server and Credentials

Ask the user (or infer from context) for:
- **Host** — `localhost` / `127.0.0.1` or a remote IP/hostname
- **Port** — default `3306`
- **User** — e.g., `root`, `appuser`
- **Password** — or confirm it is stored in the credentials file
- **Database** (optional) — if a specific database is already known

### Step 2 — Test the Connection

```bash
# Unix/macOS — connect and immediately exit
mariadb -h localhost -u root -p --execute "SELECT VERSION();"

# Windows (PowerShell)
mariadb.exe -h 127.0.0.1 -u root -p --execute "SELECT VERSION();"
```

If the connection fails, diagnose before continuing:

```bash
# Check server status (Unix/macOS)
sudo systemctl status mariadb

# Check server status (Windows)
net start | findstr -i maria

# Check port reachability
# Unix/macOS
nc -zv localhost 3306

# Windows
Test-NetConnection -ComputerName 127.0.0.1 -Port 3306
```

### Step 3 — Execute the Task

Only after confirming a successful connection, proceed with the actual task.

---

## Configuration File (my.cnf / my.ini) — AI-Assisted Generation

The MariaDB configuration file controls server behaviour, connection defaults, character sets, buffer sizes, and more. AI can generate a tailored config based on your workload description.

### File locations

| Platform | Global config | User config |
|----------|--------------|-------------|
| **Linux** | `/etc/mysql/my.cnf` or `/etc/my.cnf` | `~/.my.cnf` |
| **macOS** | `/usr/local/etc/my.cnf` (Homebrew) or `/etc/my.cnf` | `~/.my.cnf` |
| **Windows** | `C:\ProgramData\MariaDB\data\my.ini` or `C:\Program Files\MariaDB\MariaDB Server <ver>\my.ini` | `%APPDATA%\MariaDB\my.ini` |

> On Windows, MariaDB looks for `my.ini` (not `my.cnf`). The file format is identical — only the name and path differ.

### How to generate a config with AI

1. Tell Copilot your workload type (e.g., "small web app", "reporting server", "development only").
2. Copilot generates an INI-formatted config, writes it to a temp file, and shows it to you.
3. Review, adjust, then apply.

**Example prompt:**
> Generate a `my.cnf` for a Linux development server with 4 GB RAM, UTF-8 charset, and slow query logging enabled.

Copilot will produce a file like:

```ini
# my.cnf — MariaDB development server
# Generated by GitHub Copilot — review before applying

[mysqld]
# --- Character set ---
character-set-server  = utf8mb4
collation-server      = utf8mb4_unicode_ci

# --- Networking ---
bind-address          = 127.0.0.1
port                  = 3306

# --- InnoDB tuning ---
innodb_buffer_pool_size   = 1G
innodb_log_file_size      = 256M
innodb_flush_log_at_trx_commit = 2

# --- Query cache (disabled in MariaDB 10.1.7+) ---
query_cache_type      = 0
query_cache_size      = 0

# --- Slow query log ---
slow_query_log        = 1
slow_query_log_file   = /var/log/mysql/mariadb-slow.log
long_query_time       = 2

# --- General log (dev only — disable in prod!) ---
general_log           = 1
general_log_file      = /var/log/mysql/mariadb-general.log

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
```

### Apply the config (Unix/macOS)

```bash
# Write config (shown as example — always review first)
sudo tee /etc/mysql/my.cnf << 'EOF'
[mysqld]
character-set-server = utf8mb4
collation-server     = utf8mb4_unicode_ci
bind-address         = 127.0.0.1
innodb_buffer_pool_size = 1G
slow_query_log       = 1
slow_query_log_file  = /var/log/mysql/mariadb-slow.log
long_query_time      = 2

[client]
default-character-set = utf8mb4
EOF

# Validate config syntax
mariadbd --defaults-file=/etc/mysql/my.cnf --validate-config

# Restart to apply
sudo systemctl restart mariadb
```

### Apply the config (Windows PowerShell)

```powershell
# Write config to temp file first, then review
$config = @'
[mysqld]
character-set-server = utf8mb4
collation-server     = utf8mb4_unicode_ci
bind-address         = 127.0.0.1
innodb_buffer_pool_size = 512M
slow_query_log       = 1
slow_query_log_file  = C:\ProgramData\MariaDB\data\mariadb-slow.log
long_query_time      = 2

[client]
default-character-set = utf8mb4
'@

# Write to temp file for review
$tmpFile = "$env:TEMP\my_proposed.ini"
$config | Out-File -FilePath $tmpFile -Encoding UTF8
Write-Host "Proposed config written to: $tmpFile"

# After review, copy to the MariaDB data directory
Copy-Item $tmpFile "C:\ProgramData\MariaDB\data\my.ini" -Force

# Restart MariaDB service (find by display name to handle different service names)
$svc = Get-Service | Where-Object { $_.DisplayName -like "*MariaDB*" } | Select-Object -First 1
if ($svc) {
    Restart-Service -Name $svc.Name -Force
    Write-Host "Restarted service: $($svc.DisplayName)" -ForegroundColor Green
} else {
    Write-Warning "MariaDB service not found. Start it manually or check the service name."
}
```

### Store credentials securely (avoid typing passwords)

```ini
# ~/.my.cnf  (Unix/macOS) — chmod 600 ~/.my.cnf
# %APPDATA%\MariaDB\my.ini  (Windows)

[client]
host     = localhost
user     = myuser
password = mypassword
```

```bash
# Unix: set strict permissions
chmod 600 ~/.my.cnf

# Now connect without -p prompt:
mariadb mydb
```

---

## Core Workflows

### 1. Connect to a MariaDB Server

```bash
# Interactive session (prompts for password)
mariadb -h localhost -u root -p

# Connect and select a database
mariadb -h localhost -u root -p mydb

# Non-interactive: run a single SQL statement
mariadb -h localhost -u root -p --execute "SHOW DATABASES;"

# Read SQL from a file
mariadb -h localhost -u root -p mydb < script.sql

# Connect via socket (Unix/macOS only)
mariadb --socket=/var/run/mysqld/mysqld.sock -u root

# Windows — always use TCP
mariadb.exe -h 127.0.0.1 --port 3306 -u root -p
```

### 2. Database Management

```bash
# List all databases
mariadb -u root -p --execute "SHOW DATABASES;"

# Create a database (with character set)
mariadb -u root -p --execute "CREATE DATABASE IF NOT EXISTS myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Drop a database
mariadb -u root -p --execute "DROP DATABASE IF EXISTS old_db;"

# Select active database
mariadb -u root -p --execute "USE myapp; SHOW TABLES;"

# Show database size (MB)
mariadb -u root -p --execute \
  "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length)/1024/1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"
```

### 3. Table Management

```bash
# List tables in a database
mariadb -u root -p mydb --execute "SHOW TABLES;"

# Describe table structure
mariadb -u root -p mydb --execute "DESCRIBE users;"

# Show CREATE TABLE statement
mariadb -u root -p mydb --execute "SHOW CREATE TABLE users\G"

# Create a table
mariadb -u root -p mydb --execute "
CREATE TABLE IF NOT EXISTS users (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  email      VARCHAR(255) NOT NULL UNIQUE,
  name       VARCHAR(100) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

# Drop a table
mariadb -u root -p mydb --execute "DROP TABLE IF EXISTS temp_table;"
```

### 4. Data Queries

```bash
# Select with output to terminal
mariadb -u root -p mydb --execute "SELECT id, email, name FROM users LIMIT 10;"

# Export query result as CSV (Unix/macOS)
mariadb -u root -p mydb --batch --execute \
  "SELECT id, email, name FROM users;" | sed 's/\t/,/g' > users.csv

# Export query result as CSV (Windows PowerShell)
mariadb.exe -u root -p mydb --batch --execute "SELECT id, email, name FROM users;" |
  ForEach-Object { $_ -replace "`t", "," } | Out-File -FilePath users.csv -Encoding UTF8

# Run a SQL file
mariadb -u root -p mydb < queries.sql

# Pipe SQL from stdin (Unix/macOS)
echo "SELECT COUNT(*) FROM users;" | mariadb -u root -p mydb

# Pipe SQL from stdin (Windows PowerShell)
"SELECT COUNT(*) FROM users;" | mariadb.exe -u root -p mydb
```

### 5. User and Permission Management

```bash
# List all users
mariadb -u root -p --execute "SELECT User, Host FROM mysql.user;"

# Create a user
mariadb -u root -p --execute "CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED BY 'securepassword';"

# Grant privileges
mariadb -u root -p --execute "GRANT SELECT, INSERT, UPDATE, DELETE ON myapp.* TO 'appuser'@'localhost';"

# Grant all privileges on a database
mariadb -u root -p --execute "GRANT ALL PRIVILEGES ON myapp.* TO 'appuser'@'localhost';"

# Apply privilege changes immediately
mariadb -u root -p --execute "FLUSH PRIVILEGES;"

# Show grants for a user
mariadb -u root -p --execute "SHOW GRANTS FOR 'appuser'@'localhost';"

# Revoke a privilege
mariadb -u root -p --execute "REVOKE DELETE ON myapp.* FROM 'appuser'@'localhost';"

# Drop a user
mariadb -u root -p --execute "DROP USER IF EXISTS 'appuser'@'localhost';"

# Change a password
mariadb -u root -p --execute "ALTER USER 'appuser'@'localhost' IDENTIFIED BY 'newpassword';"
```

### 6. Backup and Restore

```bash
# Full database backup (Unix/macOS)
mariadb-dump -u root -p mydb > /tmp/mydb_$(date +%Y%m%d).sql

# Full database backup (Windows PowerShell)
$date = Get-Date -Format "yyyyMMdd"
mariadb-dump.exe -u root -p mydb > "$env:TEMP\mydb_$date.sql"

# Backup all databases
mariadb-dump -u root -p --all-databases > /tmp/all_databases.sql

# Backup specific tables
mariadb-dump -u root -p mydb users orders > /tmp/users_orders.sql

# Compressed backup (Unix/macOS)
mariadb-dump -u root -p mydb | gzip > /tmp/mydb_$(date +%Y%m%d).sql.gz

# Restore a database
mariadb -u root -p mydb < /tmp/mydb_20240101.sql

# Restore on Windows
mariadb.exe -u root -p mydb < "$env:TEMP\mydb_20240101.sql"

# Restore compressed backup (Unix/macOS)
gunzip -c /tmp/mydb_20240101.sql.gz | mariadb -u root -p mydb
```

### 7. Server Administration

```bash
# Check server status (Unix/macOS)
sudo systemctl status mariadb

# Start / stop / restart (Unix/macOS)
sudo systemctl start mariadb
sudo systemctl stop mariadb
sudo systemctl restart mariadb

# Enable auto-start on boot (Unix/macOS)
sudo systemctl enable mariadb

# Start / stop (Windows)
net start mariadb
net stop mariadb

# Check server version
mariadb -u root -p --execute "SELECT VERSION();"

# Show current status variables
mariadb -u root -p --execute "SHOW STATUS LIKE 'Threads%';"

# Show server variables (config values)
mariadb -u root -p --execute "SHOW VARIABLES LIKE 'innodb%';"

# Show running processes
mariadb -u root -p --execute "SHOW PROCESSLIST;"

# Check slow queries log
mariadb -u root -p --execute "SHOW VARIABLES LIKE 'slow_query%';"
```

---

## Output Formats

| Flag | Effect |
|------|--------|
| *(default)* | Tabular output (human-readable) |
| `--batch` | Tab-separated, no table borders (good for scripting) |
| `--csv` | Not a native flag — pipe `--batch` output through `sed`/`awk` (Unix) or `ForEach-Object` (Windows) |
| `--xml` | XML output |
| `--json` | JSON output (MariaDB 10.5+) |
| `--vertical` / `\G` | One row per column (readable for wide rows) |
| `--silent` | Suppress column headers |
| `--skip-column-names` | Omit header row in output |

---

## Common Mistakes — STOP and Re-read

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Using `mysql` command on a system where only `mariadb` is installed | `mysql` may not be in PATH | Use `mariadb` (or check `which mysql` first) |
| Connecting without `-p` when password is set | Silently fails or connects as wrong user | Always include `-p` or store credentials in `.my.cnf` |
| Editing `/etc/mysql/my.cnf` directly without backup | Broken config = server won't start | Always `cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bak` first |
| Using Windows path separators in SQL | May cause syntax errors | Use `/` or escape `\\` in strings |
| Running `DROP DATABASE` without confirmation | Irreversible data loss | Always confirm with the user before running destructive commands |
| Using `GRANT ALL ON *.*` without understanding scope | Gives root-level access | Scope grants to specific databases: `GRANT ALL ON myapp.*` |
| Forgetting `FLUSH PRIVILEGES` after manual `mysql.user` edits | Changes don't take effect | Run `FLUSH PRIVILEGES;` or use `ALTER USER` / `CREATE USER` instead |
| Using socket path on Windows | Sockets don't exist on Windows | Use `--host=127.0.0.1 --port=3306` on Windows |

---

## Red Flags — If You Catch Yourself Doing This, STOP

- ❌ Running `DROP DATABASE` or `DROP TABLE` without asking the user to confirm
- ❌ Storing plain-text passwords in scripts committed to Git
- ❌ Editing the live config file without making a backup first
- ❌ Using `GRANT ALL ON *.*` for application users
- ❌ Assuming socket connection works on Windows
- ❌ Using Markdown syntax inside SQL strings (use proper INI or SQL syntax)
- ❌ Forgetting platform differences (Unix vs. Windows) for file paths and service commands

**→ All of these mean: Stop, re-read this skill, use the correct approach.**

---

## Getting Help

```bash
# Client help
mariadb --help

# MariaDB dump help
mariadb-dump --help

# Admin tool help
mariadb-admin --help

# In-session help
mariadb> help;
mariadb> help SELECT;
```

For the full command reference with all flags and options, see [references/REFERENCE.md](references/REFERENCE.md).
