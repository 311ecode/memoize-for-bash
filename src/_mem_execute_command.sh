#!/usr/bin/env bash
_mem_execute_command() {
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    local output
    local exit_code
    
    # Execute command
    output=$("$@" 2>&1)
    exit_code=$?
    
    local end_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    # Calculate execution time (handle systems without nanosecond precision)
    local exec_time
    if command -v bc &> /dev/null; then
        exec_time=$(echo "$end_time - $start_time" | bc)
    else
        exec_time=$((end_time - start_time))
    fi
    
    # Return format: exit_code|exec_time|output
    # Use a marker to separate fields safely
    echo -e "$exit_code\t$exec_time\t$output"
}
