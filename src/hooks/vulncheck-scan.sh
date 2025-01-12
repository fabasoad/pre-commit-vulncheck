#!/usr/bin/env sh
set -u

vulncheck_scan() {
  vulncheck_common "scan . $@"
}
