#!/usr/bin/env sh

download_vulncheck() {
  version="${1}"
  os="$(uname -s)"
  arch="$(uname -m)"
  ext=$([ "${os}" = "Linux" ] && echo "tar.gz" || echo "zip")
  if [ "${os}" = "Darwin" ]; then
    os="macOS"
    arch="${arch}"
  else
    os=$([ "${os}" = "Linux" ] && echo "linux" || echo "windows")
    arch=$([ "${arch}" = "aarch64" ] && echo "arm64" || echo "amd64")
  fi
  filename="vulncheck_${version}_${os}_${arch}"
  url="https://github.com/vulncheck-oss/cli/releases/download/v${version}/${filename}.${ext}"
  output_filename="vulncheck.${ext}"
  curl -qsL "${url}" -o "${CONFIG_CACHE_APP_BIN_DIR}/${output_filename}"
  if [ "${ext}" = "zip" ]; then
    unzip -qq "${CONFIG_CACHE_APP_BIN_DIR}/${output_filename}" -d "${CONFIG_CACHE_APP_BIN_DIR}"
    mv "${CONFIG_CACHE_APP_BIN_DIR}/${filename}/bin/vulncheck" "${CONFIG_CACHE_APP_BIN_DIR}"
    rm -rf "${CONFIG_CACHE_APP_BIN_DIR}/${filename}"
  else
    tar -xzf "${CONFIG_CACHE_APP_BIN_DIR}/${output_filename}" -C "${CONFIG_CACHE_APP_BIN_DIR}" --strip-components 2
  fi
  rm -f "${CONFIG_CACHE_APP_BIN_DIR}/${output_filename}"
}

install() {
  fabasoad_log "debug" "Verifying Vulncheck installation"
  if command -v vulncheck &> /dev/null; then
    vulncheck_path="$(which vulncheck)"
    fabasoad_log "debug" "Vulncheck is found at ${vulncheck_path}. Installation skipped"
  else
    if [ -f "${CONFIG_CACHE_APP_BIN_DIR}" ]; then
      err_msg="${CONFIG_CACHE_APP_BIN_DIR} existing file prevents from creating"
      err_msg="${err_msg} a cache directory with the same name. Please either"
      err_msg="${err_msg} remove this file or install vulncheck globally manually."
      fabasoad_log "error" "${err_msg}"
      exit 1
    fi
    vulncheck_path="${CONFIG_CACHE_APP_BIN_DIR}/vulncheck"
    mkdir -p "${CONFIG_CACHE_APP_BIN_DIR}"
    if [ ! -f "${vulncheck_path}" ]; then
      fabasoad_log "debug" "Vulncheck is not found. Downloading ${PRE_COMMIT_VULNCHECK_VULNCHECK_VERSION} version."
      version="${PRE_COMMIT_VULNCHECK_VULNCHECK_VERSION}"
      if [ "${PRE_COMMIT_VULNCHECK_VULNCHECK_VERSION}" = "latest" ]; then
        version="$(curl -s "https://api.github.com/repos/vulncheck-oss/cli/releases/latest" \
          | grep '"tag_name":' \
          | sed -E 's/.*"([^"]+)".*/\1/' \
          | sed 's/v//')"
        fabasoad_log "debug" "Vulncheck latest version is ${version}"
      fi
      download_vulncheck "${version}"
      fabasoad_log "debug" "Downloading completed"
    else
      fabasoad_log "debug" "Vulncheck is found at ${vulncheck_path}. Installation skipped"
    fi
  fi
  echo "${vulncheck_path}"
}
