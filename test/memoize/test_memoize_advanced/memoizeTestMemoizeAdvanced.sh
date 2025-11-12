#!/usr/bin/env bash
memoizeTestMemoizeAdvanced() {
  export LC_NUMERIC=C  # 🔢 Consistent numeric formatting

  # Registry of test functions
  local test_functions=(
    "memoizeTestStatistics"
    "memoizeTestCacheCleanup"
    "memoizeTestEnvironmentHandling"
    "memoizeTestLargeOutput"
    "memoizeTestConcurrentAccess"
  )

  local ignored_tests=()

  # Execute tests
  bashTestRunner test_functions ignored_tests
  return $?
}