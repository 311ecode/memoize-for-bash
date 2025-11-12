#!/usr/bin/env bash
_mem_cleanup_expired() {
    local db_path="$1"
    local cache_dir="$2"
   
    # Get expired output files
    local expired_files=$(_mem_sqlite "$db_path" <<EOF
SELECT output_file FROM cache
WHERE timestamp + ttl < CAST(strftime('%s', 'now') AS INTEGER);
EOF
)
   
    # Delete files
    if [ -n "$expired_files" ]; then
        echo "$expired_files" | while read -r file; do
            if [ -n "$file" ] && [ -f "$cache_dir/$file" ]; then
                rm -f "$cache_dir/$file"
                _mem_log "Deleted expired output file: $file"
            fi
        done
    fi
   
    # Delete from database
    local deleted_count=$(_mem_sqlite "$db_path" <<EOF
DELETE FROM cache WHERE timestamp + ttl < CAST(strftime('%s', 'now') AS INTEGER);
SELECT changes();
EOF
)
   
    deleted_count=$(echo "$deleted_count" | tail -n1)
   
    if [ "$deleted_count" -gt 0 ]; then
        _mem_log "Cleaned up $deleted_count expired cache entries"
    fi
}
