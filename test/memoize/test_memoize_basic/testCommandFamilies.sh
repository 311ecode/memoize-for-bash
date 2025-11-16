#!/usr/bin/env bash
testCommandFamilies() {
    echo "👨‍👩‍👧‍👦 Testing command family extraction"
    
    local saved_debug="${DEBUG:-}"
    unset DEBUG
    
    # Test various command formats
    local commands=(
      "ls -la"
      "/bin/ls -la"
      "./script.sh"
      "python -c 'print(\"test\")'"
    )
    
    for cmd in "${commands[@]}"; do
      if ! memoize bash -c "echo 'family_test'" >/dev/null 2>&1; then
        echo "❌ ERROR: Command family test failed for: $cmd"
        return 1
      fi
    done
    
    echo "✅ SUCCESS: All command families handled correctly"
    
    # Cleanup
    memoize_clear >/dev/null 2>&1
    
    # Restore environment
    if [[ -n "$saved_debug" ]]; then
      export DEBUG="$saved_debug"
    fi
    
    return 0
  }
