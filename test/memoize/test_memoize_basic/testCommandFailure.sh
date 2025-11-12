#!/usr/bin/env bash
testCommandFailure() {
    echo "🚫 Testing command failure handling"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Test with failing command
    local failing_command="false"  # Always returns non-zero
    
    local result
    if result=$(memoize bash -c "$failing_command" 2>/dev/null); then
      echo "❌ ERROR: Should have failed but didn't"
      return 1
    else
      echo "✅ SUCCESS: Command failure properly handled"
      
      # Restore environment
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    fi
  }