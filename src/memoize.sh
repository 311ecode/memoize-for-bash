#!/usr/bin/env bash
# ============================================================================
# MEMOIZE - Adaptive Command Caching with SQLite
# ============================================================================
memoize() {
    # Prerequisites
    if ! command -v sqlite3 &> /dev/null; then
        echo "Error: 'sqlite3' is required but not installed." >&2
        return 1
    fi
   
    # Parse TTL
    local size_key="m"
   
    if [ -n "$MEMOIZE_TTL" ]; then
        size_key="$MEMOIZE_TTL"
        _mem_log "Found env var MEMOIZE_TTL=$size_key"
    fi
   
    # Check for TTL flags
    while [[ "$1" == --* ]]; do
        local flag_key="${1#--}"
        if [[ "$flag_key" =~ ^(xxs|xs|s|m|l|xl|xxl)$ ]]; then
            size_key="$flag_key"
            _mem_log "Found flag override: $1"
            shift
        else
            _mem_log "Unknown flag: $1"
            break
        fi
    done
   
    local ttl_seconds=$(_mem_parse_ttl "$size_key")
    _mem_log "TTL set to: ${size_key} (${ttl_seconds}s)"
   
    # Validate command
    if [ $# -eq 0 ]; then
        echo "Usage: memoize [--ttl] <command> [args...]" >&2
        return 1
    fi
   
    # Setup paths
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local db_name="${MEMOIZE_DB_NAME:-.memoize.db}"
    local db_path="$git_root/$db_name"
    local cache_dir="$git_root/.memoize_cache"
    mkdir -p "$cache_dir"
   
    _mem_log "Using db: $db_path, cache_dir: $cache_dir"
   
    # Initialize database
    _mem_init_db "$db_path"
   
    # Generate hash
    # Use "$*" to join all arguments with the first character of IFS (usually space).
    # This is the standard but brittle way. We must rely on the caller to pass clean arguments.
    local cmd_string="$*"
    local hash=$(echo -n "$cmd_string" | sha256sum | cut -d' ' -f1)
    _mem_log "Full command string: '$cmd_string'"
    _mem_log "Command hash: $hash"
   
    # Extract command family
    local command_family=$(_mem_extract_command_family "$cmd_string")
    _mem_log "Command family: $command_family"
   
    # Check cache (with collision backoff)
    _mem_log "Checking cache for hash: $hash"
    local cached_file=$(_mem_get_cache "$db_path" "$hash" "$cache_dir")
   
    if [ -n "$cached_file" ]; then
        _mem_log "CACHE HIT for '$cmd_string'. Returning stored output from: $cache_dir/$cached_file"
        cat "$cache_dir/$cached_file"
        return 0
    else
        _mem_log "CACHE MISS for '$cmd_string'. Executing command..."
    fi
   
    # Execute command (NO LOCK HELD - other memoize calls can proceed)
    local exec_result=$(_mem_execute_command "$@")
   
    # Parse result using tab delimiter
    local exit_code=$(echo -e "$exec_result" | cut -f1)
    local exec_time=$(echo -e "$exec_result" | cut -f2)
    local output=$(echo -e "$exec_result" | cut -f3-)
    _mem_log "Command executed: exit $exit_code, time ${exec_time}s"
   
    # Cache on success
    if [ "$exit_code" -eq 0 ]; then
        _mem_log "Command successful (${exec_time}s). Updating cache."
       
        # Store output
        local output_file="$hash.out"
        echo "$output" > "$cache_dir/$output_file"
        _mem_log "Output stored to: $cache_dir/$output_file"
       
        # Update cache and stats (with collision backoff)
        if _mem_store_cache "$db_path" "$hash" "$cmd_string" "$command_family" "$ttl_seconds" "$output_file" "$exec_time"; then
            _mem_log "Cache entry stored successfully"
        else
            _mem_log "WARNING: Failed to store cache entry"
        fi
       
        echo "$output"
    else
        _mem_log "Command failed (Exit Code: $exit_code). NOT caching."
        echo "$output"
        return "$exit_code"
    fi
   
    # Periodic cleanup (10% chance)
    if [ $((RANDOM % 10)) -eq 0 ]; then
        _mem_log "Running periodic cleanup in background..."
        (_mem_cleanup_expired "$db_path" "$cache_dir" 2>/dev/null) &
    fi
}
