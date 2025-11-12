#!/usr/bin/env bash
testLargeOutput() {
    echo "📏 Testing large output handling"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Generate large output
    local large_output=$(head -c 10000 /dev/urandom | base64)
    
    # Test caching large output
    local first_result=$(memoize bash -c "echo '$large_output'")
    local second_result=$(memoize bash -c "echo '$large_output'")
    
    if [[ "$first_result" == "$second_result" ]] && [[ "${#first_result}" -gt 5000 ]]; then
      echo "✅ SUCCESS: Large output caching works"
      
      # Cleanup
      memoize_clear >/dev/null 2>&1
      
      # Restore environment
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    else
      echo "❌ ERROR: Large output caching failed"
      echo "   First length: ${#first_result}"
      echo "   Second length: ${#second_result}"
      return 1
    fi
  }