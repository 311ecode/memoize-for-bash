#!/usr/bin/env bash
testMissingDependency() {
    echo "🚫 Testing missing sqlite3 dependency"
    
    local saved_path="$PATH"
    _mem_log "testMissingDependency: Original PATH saved"
    
    # Find where sqlite3 actually is
    local sqlite3_location=$(command -v sqlite3 2>/dev/null)
    _mem_log "testMissingDependency: sqlite3 found at: $sqlite3_location"
    
    if [ -z "$sqlite3_location" ]; then
        _mem_log "testMissingDependency: sqlite3 not available, skipping test"
        echo "⊘ SKIPPED: sqlite3 not available on system"
        return 0
    fi
    
    # Extract the directory
    local sqlite3_dir=$(dirname "$sqlite3_location")
    _mem_log "testMissingDependency: sqlite3 directory: $sqlite3_dir"
    
    # Set PATH to completely exclude that directory and all common binary paths
    _mem_log "testMissingDependency: Restricting PATH to exclude $sqlite3_dir"
    export PATH="/nonexistent:/dev/null"
    
    # Verify sqlite3 is now hidden
    if command -v sqlite3 &> /dev/null; then
        _mem_log "testMissingDependency: ERROR - sqlite3 still found"
        export PATH="$saved_path"
        echo "❌ ERROR: sqlite3 was not removed from PATH"
        return 1
    else
        _mem_log "testMissingDependency: ✓ sqlite3 successfully hidden"
    fi
    
    # Test should fail gracefully
    _mem_log "testMissingDependency: Attempting memoize without sqlite3"
    
    local output
    local exit_code
    output=$(memoize echo "test" 2>&1)
    exit_code=$?
    
    _mem_log "testMissingDependency: memoize exit code: $exit_code"
    _mem_log "testMissingDependency: memoize output: '$output'"
    
    # Restore PATH
    export PATH="$saved_path"
    _mem_log "testMissingDependency: PATH restored"
    
    # Check result
    if [ $exit_code -ne 0 ]; then
        _mem_log "testMissingDependency: ✓ Command failed as expected"
        echo "✅ SUCCESS: Properly handles missing sqlite3"
        return 0
    else
        _mem_log "testMissingDependency: ERROR - Command succeeded when it should fail"
        echo "❌ ERROR: Should have failed without sqlite3"
        return 1
    fi
}
