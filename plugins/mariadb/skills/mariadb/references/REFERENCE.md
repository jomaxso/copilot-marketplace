# MariaDB CLI — Command Reference

Complete reference for the `mariadb` client, `mariadb-dump`, `mariadb-admin`, and configuration file options. For quick-start workflows, see the main [SKILL.md](../SKILL.md).

---

## Command Structure

```
mariadb [options] [database]
mariadb-dump [options] database [tables]
mariadb-admin [options] command
```

**Binaries:**

| Tool | Purpose | Legacy alias |
|------|---------|-------------|
| `mariadb` | Interactive / scripted SQL client | `mysql` |
| `mariadb-dump` | Logical database backup | `mysqldump` |
| `mariadb-admin` | Server administration tasks | `mysqladmin` |
| `mariadbd` | Server daemon (not a client tool) | `mysqld` |

---

## 1. mariadb Client

### Connection Options

| Flag | Short | Description | Example |
|------|-------|-------------|---------|
| `--host` | `-h` | Server hostname or IP | `-h localhost` |
| `--port` | `-P` | TCP port (default 3306) | `-P 3306` |
| `--user` | `-u` | Login user | `-u root` |
| `--password` | `-p` | Prompt for password | `-p` |
| `--password=<pw>` | — | Inline password (avoid in scripts) | `--password=secret` |
| `--database` | `-D` | Connect to database | `-D mydb` |
| `--socket` | `-S` | Unix socket path (Unix/macOS only) | `-S /var/run/mysqld/mysqld.sock` |
| `--protocol` | — | Connection protocol | `--protocol=TCP` |
| `--ssl` | — | Enable SSL | `--ssl` |
| `--ssl-ca` | — | CA certificate path | `--ssl-ca=/etc/ssl/ca.pem` |

### Execution Options

| Flag | Short | Description |
|------|-------|-------------|
| `--execute` | `-e` | Run SQL and exit | `-e "SELECT 1;"` |
| `--batch` | `-B` | Tab-separated output, no box drawing | useful for scripting |
| `--silent` | — | Suppress informational output | |
| `--skip-column-names` | `-N` | Omit header row from output | |
| `--vertical` | `-E` | Print each row vertically | same as `\G` in the client |
| `--xml` | `-X` | XML output | |
| `--json` | — | JSON output (MariaDB 10.5+) | |
| `--table` | `-t` | Force tabular output even in batch mode | |
| `--pager` | — | Pipe output to pager (e.g., `less`) | `--pager=less` |
| `--no-pager` | — | Disable pager | |

### File Options

| Flag | Description |
|------|-------------|
| `--defaults-file=<path>` | Use specific config file instead of default |
| `--defaults-extra-file=<path>` | Read extra options from file (in addition to defaults) |
| `--no-defaults` | Ignore all option files |

### In-Session Commands

```sql
-- Switch database
USE mydb;

-- Show databases
SHOW DATABASES;

-- Show tables
SHOW TABLES;

-- Describe table
DESCRIBE tablename;
DESC tablename;

-- Show CREATE TABLE
SHOW CREATE TABLE tablename\G

-- Status
STATUS;
\s

-- Help
HELP;
HELP SELECT;

-- Exit
EXIT;
QUIT;
\q
```

---

## 2. mariadb-dump

### Basic Usage

```bash
# Single database
mariadb-dump -u root -p dbname > dump.sql

# All databases
mariadb-dump -u root -p --all-databases > all.sql

# Specific tables
mariadb-dump -u root -p dbname table1 table2 > tables.sql

# Structure only (no data)
mariadb-dump -u root -p --no-data dbname > schema.sql

# Data only (no structure)
mariadb-dump -u root -p --no-create-info dbname > data.sql
```

### Common Flags

| Flag | Description |
|------|-------------|
| `--all-databases` / `-A` | Dump all databases |
| `--no-data` / `-d` | Schema only, no row data |
| `--no-create-info` / `-t` | Data only, no CREATE TABLE |
| `--add-drop-table` | Add `DROP TABLE IF EXISTS` before each table (default) |
| `--single-transaction` | InnoDB consistent snapshot (recommended for live servers) |
| `--lock-tables` | Lock tables during dump (MyISAM) |
| `--routines` / `-R` | Include stored procedures and functions |
| `--triggers` | Include triggers (default) |
| `--events` / `-E` | Include scheduled events |
| `--extended-insert` | Multi-row INSERT statements (faster restore, default) |
| `--compact` | Minimal output (suppress comments and SET statements) |
| `--column-statistics=0` | Suppress COLUMN_STATISTICS queries (compatibility) |
| `--set-gtid-purged=OFF` | Skip GTID-related output (replication setups) |

### Restore

```bash
# Restore to existing database
mariadb -u root -p dbname < dump.sql

# Restore all databases
mariadb -u root -p < all.sql

# Restore with verbose progress (Unix/macOS)
pv dump.sql | mariadb -u root -p dbname
```

---

## 3. mariadb-admin

| Command | Description | Example |
|---------|-------------|---------|
| `ping` | Check if server is alive | `mariadb-admin -u root -p ping` |
| `status` | Server status summary | `mariadb-admin -u root -p status` |
| `extended-status` | All status variables | `mariadb-admin -u root -p extended-status` |
| `variables` | All server variables | `mariadb-admin -u root -p variables` |
| `processlist` | Running queries | `mariadb-admin -u root -p processlist` |
| `kill <id>` | Kill a query process | `mariadb-admin -u root -p kill 42` |
| `reload` | Reload grant tables | `mariadb-admin -u root -p reload` |
| `flush-logs` | Rotate log files | `mariadb-admin -u root -p flush-logs` |
| `flush-tables` | Flush table caches | `mariadb-admin -u root -p flush-tables` |
| `shutdown` | Shut down the server | `mariadb-admin -u root -p shutdown` |
| `create <db>` | Create a database | `mariadb-admin -u root -p create newdb` |
| `drop <db>` | Drop a database | `mariadb-admin -u root -p drop olddb` |
| `password <new>` | Change root password | `mariadb-admin -u root -p password newpw` |

---

## 4. Configuration File (my.cnf / my.ini)

### File Format

```ini
# Comments start with # or ;
[section]
option = value
```

### Section Overview

| Section | Who reads it | Purpose |
|---------|-------------|---------|
| `[mysqld]` / `[mariadbd]` | Server daemon | Server behaviour, networking, storage engine |
| `[client]` | All client tools | Default connection options for any client |
| `[mysql]` / `[mariadb]` | Interactive `mariadb` client | Client-specific defaults |
| `[mysqldump]` / `[mariadb-dump]` | Dump tool | Defaults for backup operations |
| `[mysqladmin]` / `[mariadb-admin]` | Admin tool | Defaults for admin operations |

### Common `[mysqld]` Options

```ini
[mysqld]
# --- Networking ---
bind-address          = 127.0.0.1          # Listen on localhost only (secure default)
port                  = 3306
# skip-networking                          # Disable TCP, socket only (Unix/macOS)

# --- Character set ---
character-set-server  = utf8mb4
collation-server      = utf8mb4_unicode_ci

# --- Storage paths ---
# datadir             = /var/lib/mysql     # Linux default
# datadir             = C:\ProgramData\MariaDB\data  # Windows default
# socket              = /run/mysqld/mysqld.sock       # Unix/macOS only

# --- InnoDB settings ---
innodb_buffer_pool_size   = 1G             # Set to ~70% of available RAM on dedicated servers
innodb_log_file_size      = 256M
innodb_flush_log_at_trx_commit = 1        # 1 = ACID safe; 2 = faster but less durable
innodb_file_per_table     = 1

# --- Connection settings ---
max_connections           = 150
max_allowed_packet        = 64M
wait_timeout              = 600
interactive_timeout       = 600

# --- Query cache (disabled in MariaDB 10.1.7+, remove for older) ---
query_cache_type          = 0
query_cache_size          = 0

# --- Slow query log ---
slow_query_log            = 1
slow_query_log_file       = /var/log/mysql/mariadb-slow.log   # Linux
# slow_query_log_file     = C:\ProgramData\MariaDB\data\mariadb-slow.log  # Windows
long_query_time           = 2             # Log queries taking > 2 seconds

# --- General log (disable in production) ---
# general_log             = 1
# general_log_file        = /var/log/mysql/mariadb-general.log

# --- Binary log (needed for replication / point-in-time recovery) ---
# log_bin                 = /var/log/mysql/mariadb-bin
# expire_logs_days        = 7

# --- Error log ---
# log_error               = /var/log/mysql/error.log            # Linux
# log_error               = C:\ProgramData\MariaDB\data\mariadb.err  # Windows
```

### Common `[client]` Options

```ini
[client]
host                  = localhost
port                  = 3306
default-character-set = utf8mb4

# Stored credentials (restrict file permissions: chmod 600 ~/.my.cnf)
# user                = myuser
# password            = mypassword
# database            = mydb
```

### Platform-Specific Config Paths

```ini
# Linux (place in /etc/mysql/my.cnf or ~/.my.cnf)
[mysqld]
datadir    = /var/lib/mysql
socket     = /run/mysqld/mysqld.sock
pid-file   = /run/mysqld/mysqld.pid
log_error  = /var/log/mysql/error.log

# macOS Homebrew (place in /usr/local/etc/my.cnf or ~/.my.cnf)
[mysqld]
datadir    = /usr/local/var/mysql
socket     = /tmp/mysql.sock
log_error  = /usr/local/var/mysql/error.log

# Windows (place in C:\ProgramData\MariaDB\data\my.ini)
[mysqld]
datadir    = C:/ProgramData/MariaDB/data
log_error  = C:/ProgramData/MariaDB/data/mariadb.err
# No socket option on Windows — TCP only
```

---

## 5. SQL Quick Reference

### Data Definition Language (DDL)

```sql
-- Create database
CREATE DATABASE mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create table
CREATE TABLE orders (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id    INT UNSIGNED NOT NULL,
  total      DECIMAL(10,2) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user (user_id)
) ENGINE=InnoDB;

-- Alter table
ALTER TABLE orders ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'pending';
ALTER TABLE orders ADD INDEX idx_status (status);
ALTER TABLE orders DROP COLUMN status;

-- Drop table
DROP TABLE IF EXISTS temp_table;
```

### Data Manipulation Language (DML)

```sql
-- Insert
INSERT INTO users (email, name) VALUES ('alice@example.com', 'Alice');
INSERT INTO users (email, name) VALUES ('bob@example.com', 'Bob'), ('carol@example.com', 'Carol');

-- Select
SELECT * FROM users WHERE id = 1;
SELECT u.name, COUNT(o.id) AS order_count
  FROM users u LEFT JOIN orders o ON o.user_id = u.id
  GROUP BY u.id ORDER BY order_count DESC;

-- Update
UPDATE users SET name = 'Alice Smith' WHERE id = 1;

-- Delete
DELETE FROM users WHERE id = 1;

-- Truncate (faster than DELETE for all rows)
TRUNCATE TABLE log_entries;
```

### User Administration

```sql
-- Create user
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password';

-- Grant privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON mydb.* TO 'appuser'@'localhost';
GRANT ALL PRIVILEGES ON mydb.* TO 'devuser'@'%';

-- Apply changes
FLUSH PRIVILEGES;

-- Show grants
SHOW GRANTS FOR 'appuser'@'localhost';

-- Revoke
REVOKE DELETE ON mydb.* FROM 'appuser'@'localhost';

-- Drop user
DROP USER IF EXISTS 'appuser'@'localhost';

-- Change password
ALTER USER 'appuser'@'localhost' IDENTIFIED BY 'newpassword';
```

---

## 6. Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Error (SQL error, syntax error, or connection problem) |
| `2` | Could not connect to server |

---

## 7. Useful SHOW Commands

```sql
SHOW DATABASES;
SHOW TABLES;
SHOW FULL TABLES;                      -- includes table type (BASE TABLE / VIEW)
SHOW COLUMNS FROM tablename;
SHOW INDEX FROM tablename;
SHOW CREATE TABLE tablename\G
SHOW CREATE DATABASE dbname;
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;
SHOW STATUS;
SHOW STATUS LIKE 'Innodb%';
SHOW VARIABLES;
SHOW VARIABLES LIKE 'max_%';
SHOW GRANTS FOR CURRENT_USER();
SHOW ENGINES;
SHOW WARNINGS;
SHOW ERRORS;
```
