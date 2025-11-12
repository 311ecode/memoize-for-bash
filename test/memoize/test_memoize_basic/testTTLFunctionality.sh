#!/usr/bin/env bash
testTTLFunctionality() {
    echo "⏰ Testing TTL functionality"
    
    local saved_ttl="${MEMOIZE_TTL:-}"
    
    # Test with short TTL
    export MEMOIZE_TTL="xxs"  # 1 minute TTL
    
    local test_command="echo 'ttl_test_$(date +%s%N)'"
    
    # Execute and cache
    local first_result=$(memoize bash -c "$test_command")
    
    # Verify cache hit
    local second_result=$(memoize bash -c "$test_command")
    
    if [[ "$first_result" == "$second_result" ]]; then
      echo "✅ SUCCESS: TTL caching works"
      
      # Cleanup
      memoize_clear >/dev/null 2>&1
      
      # Restore environment
      if [[ -n "$saved_ttl" ]]; then
        export MEMOIZE_TTL="$saved_ttl"
      else
        unset MEMOIZE_TTL
      fi
      
      return 0
    else
      echo "❌ ERROR: TTL caching failed"
      return 1
    fi
  }