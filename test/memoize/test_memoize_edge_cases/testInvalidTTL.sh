#!/usr/bin/env bash
testInvalidTTL() {
    echo "🕒 Testing invalid TTL values"
    
    local saved_ttl="${MEMOIZE_TTL:-}"
    
    # Test with invalid TTL
    export MEMOIZE_TTL="invalid_ttl_value"
    
    if memoize bash -c "echo 'invalid_ttl_test'" >/dev/null 2>&1; then
      echo "✅ SUCCESS: Invalid TTL handled gracefully"
      
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
      echo "❌ ERROR: Invalid TTL caused failure"
      return 1
    fi
  }
