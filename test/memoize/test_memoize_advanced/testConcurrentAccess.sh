#!/usr/bin/env bash
testConcurrentAccess() {
    echo "⚡ Testing concurrent access handling with collision avoidance"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Enable collision detection in memoize
    export MEMOIZE_ENABLE_BACKOFF=1
    
    # Create array to store job PIDs
    local -a pids=()
    
    # Run multiple memoize commands in background
    # Higher concurrency to increase collision probability
    for i in {1..10}; do
      memoize bash -c "echo 'concurrent_test_$i'; sleep 0.05" &
      pids+=($!)
    done
    
    # Wait for ALL background jobs to complete
    local failed=0
    for pid in "${pids[@]}"; do
      if ! wait "$pid" 2>/dev/null; then
        ((failed++))
      fi
    done
    
    # Check results
    if [ $failed -eq 0 ]; then
      echo "✅ SUCCESS: $((${#pids[@]})) concurrent processes handled without crashes"
      
      # Cleanup
      memoize_clear >/dev/null 2>&1
      
      # Restore environment
      unset MEMOIZE_ENABLE_BACKOFF
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    else
      echo "❌ ERROR: $failed background job(s) failed"
      return 1
    fi
}
