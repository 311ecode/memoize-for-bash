#!/usr/bin/env bash
_mem_store_cache() {
    local db_path="$1"
    local hash="$2"
    local command="$3"
    local command_family="$4"
    local ttl="$5"
    local output_file="$6"
    local exec_time="$7"
   
    _mem_log "_mem_store_cache: Storing for hash '$hash', family '$command_family', ttl $ttl, file '$output_file', time ${exec_time}s"
   
    # Escape single quotes for SQL
    command=$(echo "$command" | sed "s/'/''/g")
   
    local attempt=0
    local max_attempts=5
   
    # Retry loop for SQLite BUSY errors
    while true; do
        # Apply collision backoff before retry
        if ! _mem_collision_backoff "$attempt" "$max_attempts"; then
            _mem_log "ERROR: Giving up on cache store after $max_attempts attempts"
            return 1
        fi
       
        # Attempt to store cache
        local store_output
        store_output=$(_mem_sqlite "$db_path" <<EOF 2>&1
BEGIN TRANSACTION;
-- Insert or replace cache entry
INSERT OR REPLACE INTO cache (
    hash, command, command_family, timestamp, ttl, output_file, exec_time, hit_count, last_accessed
) VALUES (
    '$hash',
    '$command',
    '$command_family',
    strftime('%s', 'now'),
    $ttl,
    '$output_file',
    $exec_time,
    0,
    strftime('%s', 'now')
);
-- Update command family stats
INSERT INTO command_stats (command_family, max_exec_time, avg_exec_time, execution_count, last_updated)
VALUES ('$command_family', $exec_time, $exec_time, 1, strftime('%s', 'now'))
ON CONFLICT(command_family) DO UPDATE SET
    max_exec_time = CASE
        WHEN $exec_time > max_exec_time THEN $exec_time
        ELSE max_exec_time
    END,
    avg_exec_time = (avg_exec_time * execution_count + $exec_time) / (execution_count + 1),
    execution_count = execution_count + 1,
    last_updated = strftime('%s', 'now');
COMMIT;
EOF
)
       
        local sqlite_exit=$?
        _mem_log "_mem_store_cache: Store output: '$store_output' (exit: $sqlite_exit)"
       
        # Check for database locked error
        if [ $sqlite_exit -eq 5 ] || echo "$store_output" | grep -q "database is locked"; then
            _mem_log "SQLite BUSY on cache store (attempt $attempt)"
            _mem_track_collision ".memoize_collisions"
            ((attempt++))
            continue
        fi
       
        # Success!
        if [ $sqlite_exit -eq 0 ]; then
            _mem_log "Cached result for '$command_family' (exec time: ${exec_time}s) [attempt: $attempt]"
            return 0
        fi
       
        # Other error - log and give up
        _mem_log "ERROR: SQLite error during store: $store_output"
        return 1
    done
}
