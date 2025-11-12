#!/usr/bin/env bash
testSpecialCharacters() {
    echo "🔤 Testing special characters in commands"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    local test_commands=(
      "echo 'test with spaces'"
      "echo 'test\"with\"quotes'"
      "echo 'test-with-dashes'"
      "echo 'test_with_underscores'"
      "echo 'test@#$%^&*()'"
    )
    
    for cmd in "${test_commands[@]}"; do
      local first_result=$(memoize bash -c "$cmd")
      local second_result=$(memoize bash -c "$cmd")
      
      if [[ "$first_result" != "$second_result" ]]; then
        echo "❌ ERROR: Special character handling failed for: $cmd"
        echo "   First: '$first_result'"
        echo "   Second: '$second_result'"
        return 1
      fi
    done
    
    echo "✅ SUCCESS: All special characters handled correctly"
    
    # Cleanup
    memoize_clear >/dev/null 2>&1
    
    # Restore environment
    if [[ -n "$saved_debug" ]]; then
      export DEBUG="$saved_debug"
    fi
    
    return 0
  }