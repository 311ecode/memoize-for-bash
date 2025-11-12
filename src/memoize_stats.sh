#!/usr/bin/env bash
memoize_stats() {
    local command_family="$1"
   
    _mem_log "memoize_stats called with command_family='$command_family'"
   
    # Find database
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local db_name="${MEMOIZE_DB_NAME:-.memoize.db}"
    local db_path="$git_root/$db_name"
   
    _mem_log "git_root: $git_root"
    _mem_log "MEMOIZE_DB_NAME: $MEMOIZE_DB_NAME"
    _mem_log "db_path: $db_path"
   
    if [ ! -f "$db_path" ]; then
        echo "No cache database found at $db_path"
        _mem_log "ERROR: Database file does not exist at $db_path"
        return 1
    fi
   
    _mem_log "Database file exists at $db_path"
    _mem_log "Database file size: $(stat -f%z "$db_path" 2>/dev/null || stat -c%s "$db_path" 2>/dev/null || echo 'unknown') bytes"
   
    if [ -n "$command_family" ]; then
        # Stats for specific command family
        _mem_log "Fetching stats for specific command family: $command_family"
       
        echo "Statistics for '$command_family':"
       
        local stats_output
        stats_output=$(sqlite3 "$db_path" <<EOF 2>&1
.mode column
.headers on
SELECT
    command_family,
    printf('%.2f', max_exec_time) as max_time,
    printf('%.2f', avg_exec_time) as avg_time,
    execution_count as execs
FROM command_stats
WHERE command_family = '$command_family';
EOF
)
       
        local stats_exit=$?
        _mem_log "Stats query exit code: $stats_exit"
        _mem_log "Stats query output: '$stats_output'"
        echo "$stats_output"
       
        echo ""
        echo "Cached entries:"
       
        local cache_output
        cache_output=$(sqlite3 "$db_path" <<EOF 2>&1
.mode column
.headers on
SELECT
    substr(command, 1, 60) as command,
    hit_count as hits,
    datetime(timestamp, 'unixepoch', 'localtime') as cached_at
FROM cache
WHERE command_family = '$command_family'
ORDER BY timestamp DESC
LIMIT 10;
EOF
)
       
        local cache_exit=$?
        _mem_log "Cache query exit code: $cache_exit"
        _mem_log "Cache query output: '$cache_output'"
        echo "$cache_output"
    else
        # Overall stats
        _mem_log "Fetching overall cache statistics"
       
        echo "Overall Cache Statistics:"
        echo ""
       
        _mem_log "Executing: COUNT(*) FROM cache"
        local total_entries
        total_entries=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM cache;" 2>&1)
        local te_exit=$?
        _mem_log "total_entries exit code: $te_exit, result: '$total_entries'"
       
        _mem_log "Executing: COALESCE(SUM(hit_count), 0) FROM cache"
        local total_hits
        total_hits=$(sqlite3 "$db_path" "SELECT COALESCE(SUM(hit_count), 0) FROM cache;" 2>&1)
        local th_exit=$?
        _mem_log "total_hits exit code: $th_exit, result: '$total_hits'"
       
        _mem_log "Executing: COUNT(*) FROM command_stats"
        local total_families
        total_families=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM command_stats;" 2>&1)
        local tf_exit=$?
        _mem_log "total_families exit code: $tf_exit, result: '$total_families'"
       
        echo "Total cached entries: $total_entries"
        echo "Total cache hits: $total_hits"
        echo "Command families: $total_families"
        echo ""
       
        _mem_log "Validating query results are valid numbers"
       
        # Validate results
        if ! [[ "$total_entries" =~ ^[0-9]+$ ]]; then
            _mem_log "ERROR: total_entries is not a valid number: '$total_entries'"
            echo "⚠️ Warning: Could not parse total entries (got: '$total_entries')"
        else
            _mem_log "✓ total_entries is valid: $total_entries"
        fi
       
        if ! [[ "$total_hits" =~ ^[0-9]+$ ]]; then
            _mem_log "ERROR: total_hits is not a valid number: '$total_hits'"
            echo "⚠️ Warning: Could not parse total hits (got: '$total_hits')"
        else
            _mem_log "✓ total_hits is valid: $total_hits"
        fi
       
        if ! [[ "$total_families" =~ ^[0-9]+$ ]]; then
            _mem_log "ERROR: total_families is not a valid number: '$total_families'"
            echo "⚠️ Warning: Could not parse total families (got: '$total_families')"
        else
            _mem_log "✓ total_families is valid: $total_families"
        fi
       
        _mem_log "Query results validation complete"
       
        echo "Top Command Families:"
       
        local top_families_output
        top_families_output=$(sqlite3 "$db_path" <<EOF 2>&1
.mode column
.headers on
SELECT
    command_family,
    execution_count as execs,
    printf('%.2f', max_exec_time) as max_time,
    printf('%.2f', avg_exec_time) as avg_time
FROM command_stats
ORDER BY execution_count DESC
LIMIT 10;
EOF
)
       
        local tf_query_exit=$?
        _mem_log "Top families query exit code: $tf_query_exit"
        _mem_log "Top families query output: '$top_families_output'"
        echo "$top_families_output"
    fi
   
    _mem_log "memoize_stats completed successfully"
    return 0
}
