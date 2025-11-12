#!/usr/bin/env bash
testSideEffects() {
    echo "🔄 Testing commands with side effects"
   
    local saved_debug="${DEBUG:-}"
    export DEBUG=1  # Keep DEBUG enabled for detailed logging during test
   
    _mem_log "testSideEffects: Test started"
   
    # Create a temporary file for testing side effects (the target)
    local target_file=$(mktemp)
    # Create a temporary script file (the command)
    local command_file=$(mktemp)
   
    _mem_log "testSideEffects: Created target file at: $target_file"
    _mem_log "testSideEffects: Created command script at: $command_file"
   
    # Define the side effect command inside the script file
    echo "#!/usr/bin/env bash" > "$command_file"
    echo "echo 'side_effect' >> '$target_file'" >> "$command_file"
    chmod +x "$command_file"
   
    # The simple command string passed to memoize (only one argument)
    local side_effect_command="$command_file"
    _mem_log "testSideEffects: Side effect command (hashed): $side_effect_command"
   
    # First execution should run the command
    _mem_log "testSideEffects: FIRST EXECUTION - Running command (should cache result)"
    memoize "$side_effect_command" >/dev/null 2>&1
    local first_exec_status=$?
   
    local first_count=$(wc -l < "$target_file")
    _mem_log "testSideEffects: Line count after first execution: $first_count"
   
    _mem_log "testSideEffects: Inserting 1 second delay to ensure lock clearance."
    sleep 1
   
    # Second execution should use cache, not run command
    _mem_log "testSideEffects: SECOND EXECUTION - Using cached result (should NOT append)"
    memoize "$side_effect_command" >/dev/null 2>&1
    local second_exec_status=$?
   
    local second_count=$(wc -l < "$target_file")
    _mem_log "testSideEffects: Line count after second execution: $second_count"
   
    # Cleanup temp files
    _mem_log "testSideEffects: Cleaning up temp files"
    rm -f "$target_file" "$command_file"
   
    _mem_log "testSideEffects: Results - First count: $first_count, Second count: $second_count"
   
    # Restore original DEBUG
    export DEBUG="$saved_debug"
   
    if [[ "$first_count" -eq 1 ]] && [[ "$second_count" -eq 1 ]]; then
        _mem_log "testSideEffects: ✓ TEST PASSED - Side effects properly cached (not re-executed)"
        echo "✅ SUCCESS: Side effects properly cached (not re-executed)"
       
        # Cleanup cache
        memoize_clear >/dev/null 2>&1
        return 0
    else
        _mem_log "testSideEffects: ✗ TEST FAILED - Command was re-executed on second call"
        echo "❌ ERROR: Side effects not properly handled"
        echo "   First count: $first_count, Second count: $second_count"
        return 1
    fi
}
