#!/usr/bin/env bash
# @file run_all_memoize_tests.sh
# @brief Master test runner for all memoize test suites
# @description Executes all memoize test suites and provides summary reporting

runAllMemoizeTests() {

  export LC_NUMERIC=C  # 🔢 Consistent numeric formatting

  # Registry of test functions
  local test_functions=(
    "testMemoizeAdvanced"
    "testMemoizeBasic"
    "testMemoizeEdgeCases"
  )

  local ignored_tests=()

  # Execute tests
  bashTestRunner test_functions ignored_tests
}

