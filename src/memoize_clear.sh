#!/usr/bin/env bash
memoize_clear() {
    local command_family="$1"
   
    # Find database
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local db_name="${MEMOIZE_DB_NAME:-.memoize.db}"
    local db_path="$git_root/$db_name"
    local cache_dir="$git_root/.memoize_cache"
   
    if [ ! -f "$db_path" ]; then
        echo "No cache database found at $db_path"
        return 1
    fi
   
    if [ -n "$command_family" ]; then
        # Clear specific command family
        local files=$(_mem_sqlite "$db_path" "SELECT output_file FROM cache WHERE command_family = '$command_family';")
       
        if [ -n "$files" ]; then
            echo "$files" | while read -r file; do
                if [ -n "$file" ]; then
                    rm -f "$cache_dir/$file"
                fi
            done
        fi
       
        local count=$(_mem_sqlite "$db_path" <<EOF
DELETE FROM cache WHERE command_family = '$command_family';
SELECT changes();
EOF
)
        count=$(echo "$count" | tail -n1)
        echo "Cleared $count entries for '$command_family'"
    else
        # Clear entire cache
        rm -f "$cache_dir"/*.out 2>/dev/null
        _mem_sqlite "$db_path" "DELETE FROM cache;" >/dev/null
        echo "Cleared entire cache"
    fi
}
