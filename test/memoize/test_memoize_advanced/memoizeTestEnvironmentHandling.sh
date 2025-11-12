#!/usr/bin/env bash
memoizeTestEnvironmentHandling() {
    echo "🌍 Testing environment variable handling"
    
    local original_ttl="${MEMOIZE_TTL:-}"
    local original_debug="${DEBUG:-}"
    
    # Test with DEBUG enabled
    export DEBUG="1"
    if memoize bash -c "echo 'debug_test'" 2>&1 | grep -q "memoize"; then
      echo "✅ SUCCESS: DEBUG mode works"
    else
      echo "❌ ERROR: DEBUG mode not functioning"
      return 1
    fi
    
    # Test TTL environment variable
    export MEMOIZE_TTL="s"  # 1 hour
    if memoize bash -c "echo 'env_ttl_test'" >/dev/null 2>&1; then
      echo "✅ SUCCESS: MEMOIZE_TTL environment variable works"
    else
      echo "❌ ERROR: MEMOIZE_TTL environment variable broken"
      return 1
    fi
    
    # Cleanup
    memoize_clear >/dev/null 2>&1
    
    # Restore environment
    if [[ -n "$original_ttl" ]]; then
      export MEMOIZE_TTL="$original_ttl"
    else
      unset MEMOIZE_TTL
    fi
    if [[ -n "$original_debug" ]]; then
      export DEBUG="$original_debug"
    else
      unset DEBUG
    fi
    
    return 0
  }