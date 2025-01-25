#!/usr/bin/env sh
set -u

vulncheck_common() {
  # Removing trailing space (sed command) is needed here in case there were no
  # --vulncheck-args passed, so that ${1} in this case is "scan . "
  vulncheck_args="$(echo "${1}" | sed 's/ *$//')"

  vulncheck_path=$(install)
  vulncheck_version=$(${vulncheck_path} version | head -n 1 | cut -d ' ' -f 3)
  fabasoad_log "info" "Vulncheck path: ${vulncheck_path}"
  fabasoad_log "info" "Vulncheck version: ${vulncheck_version}"
  fabasoad_log "info" "Vulncheck arguments: ${vulncheck_args}"

  fabasoad_log "debug" "Run Vulncheck scanning:"
  set +e
  ${vulncheck_path} ${vulncheck_args}
  vulncheck_exit_code=$?
  set -e
  fabasoad_log "debug" "Vulncheck scanning completed"
  msg="Vulncheck exit code: ${vulncheck_exit_code}"
  if [ "${vulncheck_exit_code}" = "0" ]; then
    fabasoad_log "info" "${msg}"
  else
    fabasoad_log "error" "${msg}"
  fi

  uninstall
  exit ${vulncheck_exit_code}
}
