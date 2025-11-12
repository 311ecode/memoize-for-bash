#!/usr/bin/env bash
testLongCommands() {
    echo "📜 Testing very long command strings"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Generate a very long command
    local long_arg=$(printf '%*s' 1000 | tr ' ' 'x')
    local test_command="echo '$long_arg'"
    
    local first_result=$(memoize bash -c "$test_command")
    local second_result=$(memoize bash -c "$test_command")
    
    if [[ "$first_result" == "$second_result" ]] && [[ "${#first_result}" -gt 900 ]]; then
      echo "✅ SUCCESS: Long command strings handled correctly"
      
      # Cleanup
      memoize_clear >/dev/null 2>&1
      
      # Restore environment
      if [[ -n "$saved_debug" ]]; then
        export DEBUG="$saved_debug"
      fi
      
      return 0
    else
      echo "❌ ERROR: Long command handling failed"
      echo "   Result length: ${#first_result}"
      return 1
    fi
  }