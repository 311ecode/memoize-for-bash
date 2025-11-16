#!/usr/bin/env bash
_mem_init_db() {
    local db_path="$1"
    local db_dir=$(dirname "$db_path")
    
    # Create directory if needed
    if [ ! -d "$db_dir" ]; then
        _mem_log "Creating cache directory at $db_dir"
        mkdir -p "$db_dir"
    fi
    
    # Enable WAL mode and create schema (redirect stderr for cleaner output)
    _mem_sqlite "$db_path" <<'EOF' >/dev/null
PRAGMA journal_mode=WAL;

CREATE TABLE IF NOT EXISTS cache (
    hash TEXT PRIMARY KEY,
    command TEXT NOT NULL,
    command_family TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    ttl INTEGER NOT NULL,
    output_file TEXT NOT NULL,
    exec_time REAL,
    hit_count INTEGER DEFAULT 0,
    last_accessed INTEGER
);

CREATE INDEX IF NOT EXISTS idx_expiry ON cache(timestamp, ttl);
CREATE INDEX IF NOT EXISTS idx_family ON cache(command_family);

CREATE TABLE IF NOT EXISTS command_stats (
    command_family TEXT PRIMARY KEY,
    max_exec_time REAL NOT NULL,
    avg_exec_time REAL,
    execution_count INTEGER DEFAULT 0,
    last_updated INTEGER
);
EOF
    
    _mem_log "Database initialized at $db_path (WAL mode enabled)"
}
