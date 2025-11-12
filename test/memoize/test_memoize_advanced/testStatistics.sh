#!/usr/bin/env bash
testStatistics() {
    echo "📊 Testing statistics functionality"
    _mem_log "testStatistics: Starting test"
    
    local saved_debug="${DEBUG:-}"
    _mem_log "testStatistics: saved_debug='$saved_debug'"
    unset DEBUG
    
    _mem_log "testStatistics: DEBUG unset, proceeding with test"
    
    # Clear any existing cache
    _mem_log "testStatistics: Clearing existing cache"
    if memoize_clear >/dev/null 2>&1; then
        _mem_log "testStatistics: Cache cleared successfully"
    else
        _mem_log "testStatistics: WARNING - memoize_clear failed or returned non-zero"
    fi
    
    # Run multiple commands to generate stats
    local test_commands=(
      "echo 'stat_test_1'"
      "echo 'stat_test_2'" 
      "ls -la"
      "pwd"
    )
    
    _mem_log "testStatistics: About to execute ${#test_commands[@]} test commands"
    
    for i in "${!test_commands[@]}"; do
        local cmd="${test_commands[$i]}"
        _mem_log "testStatistics: Executing command [$((i+1))/${#test_commands[@]}]: $cmd"
        
        if memoize bash -c "$cmd" >/dev/null 2>&1; then
            _mem_log "testStatistics: Command [$((i+1))] executed and cached successfully"
        else
            local exit_code=$?
            _mem_log "testStatistics: ERROR - Command [$((i+1))] failed with exit code $exit_code"
        fi
    done
    
    _mem_log "testStatistics: All test commands executed"
    
    # Check database state before stats call
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local db_path="$git_root/$MEMOIZE_DB_NAME"
    
    _mem_log "testStatistics: git_root='$git_root'"
    _mem_log "testStatistics: MEMOIZE_DB_NAME='$MEMOIZE_DB_NAME'"
    _mem_log "testStatistics: db_path='$db_path'"
    
    if [ -f "$db_path" ]; then
        _mem_log "testStatistics: Database file exists"
        local db_size=$(stat -f%z "$db_path" 2>/dev/null || stat -c%s "$db_path" 2>/dev/null || echo 'unknown')
        _mem_log "testStatistics: Database file size: $db_size bytes"
    else
        _mem_log "testStatistics: ERROR - Database file does not exist at $db_path"
    fi
    
    # Debug query - check what's in the database
    _mem_log "testStatistics: Querying cache table row count"
    local cache_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM cache;" 2>&1)
    _mem_log "testStatistics: cache table rows: '$cache_count'"
    
    _mem_log "testStatistics: Querying command_stats table row count"
    local stats_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM command_stats;" 2>&1)
    _mem_log "testStatistics: command_stats table rows: '$stats_count'"
    
    _mem_log "testStatistics: About to call memoize_stats"
    
    # Check if stats are generated
    if memoize_stats >/dev/null 2>&1; then
        _mem_log "testStatistics: memoize_stats() executed successfully"
        echo "✅ SUCCESS: Statistics functionality works"
        
        # Cleanup
        _mem_log "testStatistics: Cleaning up cache"
        memoize_clear >/dev/null 2>&1
        
        # Restore environment
        if [[ -n "$saved_debug" ]]; then
            export DEBUG="$saved_debug"
            _mem_log "testStatistics: DEBUG restored to '$DEBUG'"
        fi
        
        _mem_log "testStatistics: Test PASSED"
        return 0
    else
        local exit_code=$?
        _mem_log "testStatistics: ERROR - memoize_stats() failed with exit code $exit_code"
        echo "❌ ERROR: Statistics functionality broken"
        
        # Cleanup
        memoize_clear >/dev/null 2>&1
        
        # Restore environment
        if [[ -n "$saved_debug" ]]; then
            export DEBUG="$saved_debug"
        fi
        
        _mem_log "testStatistics: Test FAILED"
        return 1
    fi
}
