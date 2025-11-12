#!/usr/bin/env bash
# Binary exponential backoff with random jitter for collision handling
# Similar to Ethernet CSMA/CD but for SQLite database access

_mem_collision_backoff() {
    local attempt="$1"
    local max_attempts="${2:-5}"
    
    # If backoff disabled, return immediately
    if [ -z "$MEMOIZE_ENABLE_BACKOFF" ]; then
        return 0
    fi
    
    # Don't backoff on first attempt
    if [ "$attempt" -lt 1 ]; then
        return 0
    fi
    
    # Max attempts check - give up after max retries
    if [ "$attempt" -ge "$max_attempts" ]; then
        _mem_log "WARNING: Max collision backoff attempts ($max_attempts) reached"
        return 1
    fi
    
    # Calculate backoff: 2^attempt milliseconds, capped at 1024ms
    local base_delay=$((2 ** attempt))
    if [ $base_delay -gt 1024 ]; then
        base_delay=1024
    fi
    
    # Add random jitter: 0 to base_delay milliseconds
    # This prevents thundering herd and synchronized retries
    local jitter=$((RANDOM % (base_delay + 1)))
    local total_delay=$((base_delay + jitter))
    
    _mem_log "Collision detected (attempt $attempt): backoff ${total_delay}ms (base: ${base_delay}ms + jitter: ${jitter}ms)"
    
    # Convert milliseconds to seconds for sleep
    # Use bc if available, else fallback
    local sleep_seconds
    if command -v bc &> /dev/null; then
        sleep_seconds=$(echo "scale=3; $total_delay / 1000" | bc)
    else
        # Fallback: round to nearest decisecond
        sleep_seconds="0.$(printf "%03d" $((total_delay / 10)))"
    fi
    
    sleep "$sleep_seconds"
    return 0
}

_mem_track_collision() {
    local collision_file="${1:-.memoize_collisions}"
    
    if [ -f "$collision_file" ]; then
        local count=$(cat "$collision_file")
        echo $((count + 1)) > "$collision_file"
    else
        echo "1" > "$collision_file"
    fi
}
