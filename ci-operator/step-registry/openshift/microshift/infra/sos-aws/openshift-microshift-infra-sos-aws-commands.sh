#!/bin/bash
set -xeuo pipefail

# shellcheck disable=SC1091
source "${SHARED_DIR}/ci-functions.sh"
ci_script_prologue
trap_subprocesses_on_term

ssh "${INSTANCE_PREFIX}" <<'EOF'
  set -x
  if ! hash sos ; then
    sudo touch /tmp/sosreport-command-does-not-exist
    exit 0
  fi

  plugin_list="container,network"
  if ! sudo sos report --list-plugins | grep 'microshift.*inactive' ; then
    plugin_list+=",microshift"
  fi

  if sudo sos report --batch --all-logs --tmp-dir /tmp -p ${plugin_list} -o logs ; then
    sudo chmod +r /tmp/sosreport-*
  else
    sudo touch /tmp/sosreport-command-failed
  fi
EOF
scp "${INSTANCE_PREFIX}":/tmp/sosreport-* "${ARTIFACT_DIR}" || true
