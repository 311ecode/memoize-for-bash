#!/usr/bin/env bash
memoize_cleanup() {
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local db_name="${MEMOIZE_DB_NAME:-.memoize.db}"
    local db_path="$git_root/$db_name"
    local cache_dir="$git_root/.memoize_cache"
   
    if [ ! -f "$db_path" ]; then
        echo "No cache database found"
        return 1
    fi
   
    echo "Cleaning up expired entries..."
    _mem_cleanup_expired "$db_path" "$cache_dir"
    echo "Cleanup complete"
}
