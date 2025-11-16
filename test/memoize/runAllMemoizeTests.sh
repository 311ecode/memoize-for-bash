#!/usr/bin/env bash
runAllMemoizeTests() {

  export LC_NUMERIC=C  # 🔢 Consistent numeric formatting

  # Registry of test functions
  local test_functions=(
    "memoizeTestMemoizeAdvanced"
    "testMemoizeBasic"
    "testMemoizeEdgeCases"
  )

  local ignored_tests=()

  # Execute tests
  bashTestRunner test_functions ignored_tests
}
