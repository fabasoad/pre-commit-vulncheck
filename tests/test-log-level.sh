#!/usr/bin/env sh

TESTS_DIR=$(dirname $(realpath "$0"))
ROOT_DIR=$(dirname "${TESTS_DIR}")
SRC_DIR="${ROOT_DIR}/src"

test_log_level_param_precedence() {
  command="${1}"
  log_level_cmd="${2}"
  log_level_env_var="${3}"
  debug_expected="${4}"

  test_name="${FUNCNAME:-${0##*/}}: $@"

  output=$(PRE_COMMIT_VULNCHECK_LOG_LEVEL="${log_level_env_var}" \
    ${SRC_DIR}/main.sh "${command}" \
    "--vulncheck-args=--quiet --hook-args=--log-level=${log_level_cmd}" \
    2>&1 >/dev/null)

  actual=$(echo "${output}" | grep "debug")
  if [ -z "${actual}" ] && [ "${debug_expected}" = "true" ]; then
    echo "[FAIL] ${test_name} - debug logs are expected to be present"
    echo "\n${output}"
    exit 1
  elif [ -n "${actual}" ] && [ "${debug_expected}" = "false" ]; then
    echo "[FAIL] ${test_name} - debug logs are not expected to be present"
    echo "\n${output}"
    exit 1
  fi

  echo "[PASS] ${test_name}"
}

test_log_level_env_var() {
  command="${1}"
  log_level_env_var="${2}"
  debug_expected="${3}"

  test_name="${FUNCNAME:-${0##*/}}: $@"

  output=$(PRE_COMMIT_VULNCHECK_LOG_LEVEL="${log_level_env_var}" \
    ${SRC_DIR}/main.sh "${command}" \
    "--vulncheck-args=--quiet" \
    2>&1 >/dev/null)

  actual=$(echo "${output}" | grep "debug")
  if [ -z "${actual}" ] && [ "${debug_expected}" = "true" ]; then
    echo "[FAIL] ${test_name} - debug logs are expected to be present"
    echo "\n${output}"
    exit 1
  elif [ -n "${actual}" ] && [ "${debug_expected}" = "false" ]; then
    echo "[FAIL] ${test_name} - debug logs are not expected to be present"
    echo "\n${output}"
    exit 1
  fi

  echo "[PASS] ${test_name}"
}

main() {
  echo "Testing $(basename "$0")..."
  test_log_level_param_precedence "vulncheck-scan" "info" "debug" "false"
  test_log_level_param_precedence "vulncheck-scan" "debug" "info" "true"
  test_log_level_env_var "vulncheck-scan" "debug" "true"
  test_log_level_env_var "vulncheck-scan" "info" "false"
  echo "[PASS] Total 4 tests passed\n"
}

main "$@"
