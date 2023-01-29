#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2020 Umbrel. https://getumbrel.com
# SPDX-FileCopyrightText: 2023 Citadel and contributors. https://runcitadel.space
#
# SPDX-License-Identifier: GPL-3.0-or-later

check_dependencies () {
  for cmd in "$@"; do
    if ! command -v $cmd >/dev/null 2>&1; then
      echo "This script requires \"${cmd}\" to be installed"
      exit 1
    fi
  done
}

check_dependencies fswatch readlink dirname

monitor_file () {
  local file_path="${1}"
  echo "Monitoring $file_path"
  echo

  if [[ ! -e "${file_path}" ]]; then
    echo "$file_path doesn't exist, waiting for it to be created..."
    echo
    until [[ -e "${file_path}" ]]; do
      sleep 1
    done
    echo "$file_path created! Triggering backup..."
    "./backup.sh"
  fi

  fswatch -0 --event Updated $file_path | xargs -0 -n 1 -I {} "./backup.sh"
}

monitor_file "/lnd/data/chain/bitcoin/mainnet/channel.backup"
