#!/usr/bin/env bash

PRE_COMMIT_VULNCHECK_SRC_DIR=$(dirname $(realpath "$0"))

# Import all scripts
_import_all() {
  current_file=$(realpath "$0")
  exec_files=$(find "${PRE_COMMIT_VULNCHECK_SRC_DIR}" -type f \( -perm -u=x -o -perm -g=x -o -perm -o=x \))
  for file in $exec_files; do
    if [ "${file}" != "${current_file}" ]; then
      . "${file}"
    fi
  done
}

main() {
  _import_all

  cmd_vulncheck_scan="vulncheck-scan"

  cmd_actual="${1}"
  shift

  declare -A all_args_map
  parse_all_args all_args_map "$(echo "$@" | sed 's/^ *//' | sed 's/ *$//')"
  declare -A hook_args_map
  parse_hook_args hook_args_map "${all_args_map["hook-args"]}"

  # Apply configs
  set +u
  apply_logging_config \
    "${hook_args_map["${CONFIG_LOG_LEVEL_ARG_NAME}"]}" \
    "${hook_args_map["${CONFIG_LOG_COLOR_ARG_NAME}"]}"
  apply_cache_config "${hook_args_map["${CONFIG_CLEAN_CACHE_ARG_NAME}"]}"
  apply_vulncheck_config "${hook_args_map["${CONFIG_VULNCHECK_VERSION_ARG_NAME}"]}"

  if [ "${#hook_args_map[@]}" -ne 0 ]; then
    fabasoad_log "info" "Pre-commit hook arguments: $(map_to_str hook_args_map)"
  fi
  set -u

  case "${cmd_actual}" in
    "${cmd_vulncheck_scan}")
      vulncheck_scan "${all_args_map["vulncheck-args"]}"
      ;;
    *)
      validate_enum "hook" "${cmd_actual}" "${cmd_vulncheck_scan}"
      ;;
  esac
}

main "$@"
