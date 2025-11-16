#!/usr/bin/env bash
testEmptyCommand() {
    echo "📭 Testing empty command handling"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Test with no arguments
    if memoize 2>/dev/null; then
      echo "❌ ERROR: Empty command should fail"
      return 1
    else
      echo "✅ SUCCESS: Empty command properly rejected"
      
      # Restore environment
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    fi
  }
