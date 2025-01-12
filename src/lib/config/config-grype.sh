#!/usr/bin/env sh

apply_vulncheck_config() {
  vulncheck_version="${1:-${PRE_COMMIT_VULNCHECK_VULNCHECK_VERSION:-${CONFIG_VULNCHECK_VERSION_DEFAULT_VAL}}}"
  if [ "${vulncheck_version}" != "latest" ]; then
    validate_semver "${CONFIG_VULNCHECK_VERSION_ARG_NAME}" "${vulncheck_version}"
  fi
  export PRE_COMMIT_VULNCHECK_VULNCHECK_VERSION="${vulncheck_version}"
}
