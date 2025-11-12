#!/usr/bin/env bash
testMemoizeAdvanced() {
  export LC_NUMERIC=C  # 🔢 Consistent numeric formatting

  # Registry of test functions
  local test_functions=(
    "testStatistics"
    "testCacheCleanup"
    "testEnvironmentHandling"
    "testLargeOutput"
    "testConcurrentAccess"
  )

  local ignored_tests=()

  # Execute tests
  bashTestRunner test_functions ignored_tests
  return $?
}