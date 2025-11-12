#!/usr/bin/env bash
memoizeTestStatistics() {
    echo "📊 Testing statistics functionality"
    _mem_log "memoizeTestStatistics: Starting test"
    
    local saved_debug="${DEBUG:-}"
    _mem_log "memoizeTestStatistics: saved_debug='$saved_debug'"
    unset DEBUG
    
    _mem_log "memoizeTestStatistics: DEBUG unset, proceeding with test"
    
    # Clear any existing cache
    _mem_log "memoizeTestStatistics: Clearing existing cache"
    if memoize_clear >/dev/null 2>&1; then
        _mem_log "memoizeTestStatistics: Cache cleared successfully"
    else
        _mem_log "memoizeTestStatistics: WARNING - memoize_clear failed or returned non-zero"
    fi
    
    # Run multiple commands to generate stats
    local test_commands=(
      "echo 'stat_test_1'"
      "echo 'stat_test_2'" 
      "ls -la"
      "pwd"
    )
    
    _mem_log "memoizeTestStatistics: About to execute ${#test_commands[@]} test commands"
    
    for i in "${!test_commands[@]}"; do
        local cmd="${test_commands[$i]}"
        _mem_log "memoizeTestStatistics: Executing command [$((i+1))/${#test_commands[@]}]: $cmd"
        
        if memoize bash -c "$cmd" >/dev/null 2>&1; then
            _mem_log "memoizeTestStatistics: Command [$((i+1))] executed and cached successfully"
        else
            local exit_code=$?
            _mem_log "memoizeTestStatistics: ERROR - Command [$((i+1))] failed with exit code $exit_code"
        fi
    done
    
    _mem_log "memoizeTestStatistics: All test commands executed"
    
    # Check database state before stats call
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local db_path="$git_root/$MEMOIZE_DB_NAME"
    
    _mem_log "memoizeTestStatistics: git_root='$git_root'"
    _mem_log "memoizeTestStatistics: MEMOIZE_DB_NAME='$MEMOIZE_DB_NAME'"
    _mem_log "memoizeTestStatistics: db_path='$db_path'"
    
    if [ -f "$db_path" ]; then
        _mem_log "memoizeTestStatistics: Database file exists"
        local db_size=$(stat -f%z "$db_path" 2>/dev/null || stat -c%s "$db_path" 2>/dev/null || echo 'unknown')
        _mem_log "memoizeTestStatistics: Database file size: $db_size bytes"
    else
        _mem_log "memoizeTestStatistics: ERROR - Database file does not exist at $db_path"
    fi
    
    # Debug query - check what's in the database
    _mem_log "memoizeTestStatistics: Querying cache table row count"
    local cache_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM cache;" 2>&1)
    _mem_log "memoizeTestStatistics: cache table rows: '$cache_count'"
    
    _mem_log "memoizeTestStatistics: Querying command_stats table row count"
    local stats_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM command_stats;" 2>&1)
    _mem_log "memoizeTestStatistics: command_stats table rows: '$stats_count'"
    
    _mem_log "memoizeTestStatistics: About to call memoize_stats"
    
    # Check if stats are generated
    if memoize_stats >/dev/null 2>&1; then
        _mem_log "memoizeTestStatistics: memoize_stats() executed successfully"
        echo "✅ SUCCESS: Statistics functionality works"
        
        # Cleanup
        _mem_log "memoizeTestStatistics: Cleaning up cache"
        memoize_clear >/dev/null 2>&1
        
        # Restore environment
        if [[ -n "$saved_debug" ]]; then
            export DEBUG="$saved_debug"
            _mem_log "memoizeTestStatistics: DEBUG restored to '$DEBUG'"
        fi
        
        _mem_log "memoizeTestStatistics: Test PASSED"
        return 0
    else
        local exit_code=$?
        _mem_log "memoizeTestStatistics: ERROR - memoize_stats() failed with exit code $exit_code"
        echo "❌ ERROR: Statistics functionality broken"
        
        # Cleanup
        memoize_clear >/dev/null 2>&1
        
        # Restore environment
        if [[ -n "$saved_debug" ]]; then
            export DEBUG="$saved_debug"
        fi
        
        _mem_log "memoizeTestStatistics: Test FAILED"
        return 1
    fi
}
