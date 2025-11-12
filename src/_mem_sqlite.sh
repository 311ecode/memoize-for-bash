#!/usr/bin/env bash
_mem_sqlite() {
    local db_path="$1"
    shift
   
    local timeout="${MEMOIZE_SQLITE_TIMEOUT:-5000}"
   
    local sql
    if [ $# -gt 0 ]; then
        sql="$*"
    else
        sql=$(cat)
    fi
   
    local output
    output=$({
        printf 'PRAGMA busy_timeout=%s;\n' "$timeout"
        printf '%s\n' "$sql"
    } | sqlite3 -batch "$db_path" 2>/dev/null)
   
    # Skip the PRAGMA output line (always the first line)
    echo "$output" | tail -n +2
}
