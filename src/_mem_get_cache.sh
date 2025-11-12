#!/usr/bin/env bash
_mem_get_cache() {
    local db_path="$1"
    local hash="$2"
    local cache_dir="$3"
   
    _mem_log "_mem_get_cache: Looking up hash '$hash'"
   
    local attempt=0
    local max_attempts=5
   
    # Retry loop for SQLite BUSY errors during lookup
    while true; do
        # Apply collision backoff before retry
        if ! _mem_collision_backoff "$attempt" "$max_attempts"; then
            _mem_log "Giving up on cache lookup after $max_attempts attempts"
            # IMPORTANT: On final failure, return empty string and failure code
            echo ""
            return 1
        fi
       
        # Query cache
        local output_file
        output_file=$(_mem_sqlite "$db_path" <<EOF 2>&1
SELECT output_file
FROM cache
WHERE hash = '$hash'
  AND timestamp + ttl > CAST(strftime('%s', 'now') AS INTEGER);
EOF
)
       
        local sqlite_exit=$?
        _mem_log "_mem_get_cache: Query output: '$output_file' (exit: $sqlite_exit)"
       
        # Check for database locked error (SQLITE_BUSY = 5)
        if [ $sqlite_exit -eq 5 ] || echo "$output_file" | grep -q "database is locked"; then
            _mem_log "SQLite BUSY on cache lookup (attempt $attempt) - triggering backoff"
            _mem_track_collision ".memoize_collisions"
            ((attempt++))
            continue # Retry lookup loop
        fi
       
        # --- Successful Lookup ---
        if [ -n "$output_file" ]; then
            _mem_log "_mem_get_cache: output_file non-empty: '$output_file'"
            if [ -f "$cache_dir/$output_file" ]; then
                _mem_log "_mem_get_cache: Cache file exists: $cache_dir/$output_file"
                # FIX: The original code's nested retry loop for hit_count caused failures here.
                # We replace it with a single, non-critical attempt.
               
                # Perform hit count update once. Its failure is logged but does NOT block cache return.
                local update_result=$(_mem_sqlite "$db_path" <<EOF 2>&1
UPDATE cache
SET hit_count = hit_count + 1,
    last_accessed = strftime('%s', 'now')
WHERE hash = '$hash';
EOF
)
               
                if [ $? -ne 0 ]; then
                    _mem_log "WARNING: Failed to update hit count (transient lock?): $update_result"
                else
                    _mem_log "_mem_get_cache: Hit count updated successfully"
                fi
               
                echo "$output_file"
                return 0 # Critical: Cache HIT, return success immediately
            else
                _mem_log "_mem_get_cache: Cache file MISSING: $cache_dir/$output_file"
            fi
        else
            _mem_log "_mem_get_cache: No matching cache entry found"
        fi
       
        # Cache MISS or output file missing.
        echo ""
        return 1 # Critical: Cache MISS, return failure
    done # End while true
}
