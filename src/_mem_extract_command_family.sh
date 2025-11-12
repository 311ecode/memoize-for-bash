#!/usr/bin/env bash
_mem_extract_command_family() {
    local full_command="$1"
    
    # Extract first token, handle paths
    local first_token=$(echo "$full_command" | awk '{print $1}')
    
    # If it's a path, get basename
    if [[ "$first_token" == */* ]]; then
        first_token=$(basename "$first_token")
    fi
    
    echo "$first_token"
}