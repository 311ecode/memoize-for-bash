#!/usr/bin/env bash
testMemoizeBasic() {
  export LC_NUMERIC=C  # 🔢 Consistent numeric formatting
  
  echo "🔍 Starting basic memoize tests..."
  
  # Test basic command caching
  # Registry of test functions
  local test_functions=(
    "testBasicCaching"
    "testTTLFunctionality" 
    "testCommandFailure"
    "testCommandFamilies"
  )

  local ignored_tests=()

  # Check if bashTestRunner exists
  if ! declare -f bashTestRunner > /dev/null; then
    echo "❌ ERROR: bashTestRunner function not found"
    return 1
  fi

  # Execute tests
  bashTestRunner test_functions ignored_tests
  return $?
}
