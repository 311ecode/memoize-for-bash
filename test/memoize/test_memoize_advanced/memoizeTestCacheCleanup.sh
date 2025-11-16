#!/usr/bin/env bash
memoizeTestCacheCleanup() {
    echo "🧹 Testing cache cleanup operations"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Populate cache
    memoize bash -c "echo 'cleanup_test'" >/dev/null 2>&1
    memoize bash -c "ls -la" >/dev/null 2>&1
    
    # Test specific family cleanup
    if memoize_clear "bash" >/dev/null 2>&1; then
      echo "✅ SUCCESS: Specific family cleanup works"
    else
      echo "❌ ERROR: Specific family cleanup failed"
      return 1
    fi
    
    # Test full cleanup
    if memoize_clear >/dev/null 2>&1; then
      echo "✅ SUCCESS: Full cache cleanup works"
      
      # Restore environment
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    else
      echo "❌ ERROR: Full cache cleanup failed"
      return 1
    fi
  }
