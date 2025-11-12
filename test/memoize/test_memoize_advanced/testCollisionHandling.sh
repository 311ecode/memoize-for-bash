#!/usr/bin/env bash
testCollisionHandling() {
    echo "🌐 Testing collision avoidance under high concurrency"
    
    local saved_debug="${DEBUG:-}"
    local saved_backoff="${MEMOIZE_ENABLE_BACKOFF:-}"
    
    export DEBUG=1
    export MEMOIZE_ENABLE_BACKOFF=1
    
    # Clear collision counter
    rm -f .memoize_collisions
    
    # Create array to store job PIDs
    local -a pids=()
    local num_concurrent=20
    
    echo "  🚀 Launching $num_concurrent concurrent processes..."
    
    # Run many concurrent memoize commands to force collisions
    for i in $(seq 1 $num_concurrent); do
      # Mix of cached and new commands to increase contention
      local cmd="echo 'collision_stress_test_$(($i % 5))'; sleep $((1 + RANDOM % 5))ms"
      memoize bash -c "$cmd" >/dev/null 2>&1 &
      pids+=($!)
    done
    
    echo "  ⏳ Waiting for all processes..."
    
    # Wait for ALL background jobs to complete
    local failed=0
    local succeeded=0
    
    for pid in "${pids[@]}"; do
      if wait "$pid" 2>/dev/null; then
        ((succeeded++))
      else
        ((failed++))
      fi
    done
    
    # Check collision statistics
    local collisions=0
    if [ -f .memoize_collisions ]; then
        collisions=$(cat .memoize_collisions)
    fi
    
    echo ""
    echo "  📊 Results:"
    echo "     ✅ Succeeded: $succeeded/$num_concurrent"
    echo "     ❌ Failed: $failed/$num_concurrent"
    echo "     💥 Collisions detected: $collisions"
    
    # Cleanup
    rm -f .memoize_collisions
    memoize_clear >/dev/null 2>&1
    
    # Restore environment
    unset MEMOIZE_ENABLE_BACKOFF
    if [[ -n "$saved_debug" ]]; then
      export DEBUG="$saved_debug"
    else
      unset DEBUG
    fi
    
    if [ $failed -eq 0 ]; then
      echo "✅ SUCCESS: All concurrent processes completed with collision handling"
      return 0
    else
      echo "❌ ERROR: $failed processes failed despite collision handling"
      return 1
    fi
}
