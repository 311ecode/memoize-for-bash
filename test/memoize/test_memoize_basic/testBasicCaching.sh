#!/usr/bin/env bash
testBasicCaching() {
    echo "🧪 Testing basic command caching"
    
    # Save original environment
    local saved_ttl="${MEMOIZE_TTL:-}"
    local saved_debug="${DEBUG:-}"
    
    # Setup clean test environment
    unset MEMOIZE_TTL
    unset DEBUG
    
    # Create a unique test command
    local test_command="echo 'basic_test_$(date +%s%N)'"
    
    # First execution should cache
    local first_result=$(memoize bash -c "$test_command")
    local second_result=$(memoize bash -c "$test_command")
    
    # Verify caching worked
    if [[ "$first_result" == "$second_result" ]]; then
      echo "✅ SUCCESS: Basic caching works - results match"
      
      # Cleanup
      memoize_clear >/dev/null 2>&1
      
      # Restore environment
      if [[ -n "$saved_ttl" ]]; then
        export MEMOIZE_TTL="$saved_ttl"
      fi
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    else
      echo "❌ ERROR: Caching failed - results differ"
      echo "   First: '$first_result'"
      echo "   Second: '$second_result'"
      return 1
    fi
  }
