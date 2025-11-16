#!/usr/bin/env bash
testMemoizeEdgeCases() {
  export LC_NUMERIC=C  # 🔢 Consistent numeric formatting

  # Registry of test functions
  local test_functions=(
    "testSpecialCharacters"
    "testMissingDependency"
    "testInvalidTTL"
    "testLongCommands"
    "testSideEffects"
    "testEmptyCommand"
  )

  local ignored_tests=()

  # Execute tests
  bashTestRunner test_functions ignored_tests
  return $?
}
