#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2020 Umbrel. https://getumbrel.com
# SPDX-FileCopyrightText: 2023 Citadel and contributors. https://runcitadel.space
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

MAX_BACKUP_INTERVAL_IN_HOURS="12"

check_dependencies () {
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "This script requires \"${cmd}\" to be installed"
      exit 1
    fi
  done
}

check_dependencies shuf

while true; do
    minutes_in_seconds="60"
    hours_in_seconds="$((60 * ${minutes_in_seconds}))"
    max_interval="$((${MAX_BACKUP_INTERVAL_IN_HOURS} * ${hours_in_seconds}))"
    delay="$(shuf -i 0-${max_interval} -n 1)"
    echo "Sleeping for ${delay} seconds..."
    sleep $delay
    echo "Triggering decoy backup..."
    ./backup.sh
done