#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2020 Umbrel. https://getumbrel.com
# SPDX-FileCopyrightText: 2023 Citadel and contributors. https://runcitadel.space
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

BACKUP_ROOT="/tmp/$RANDOM"
BACKUP_FOLDER_NAME="backup"
BACKUP_FOLDER_PATH="${BACKUP_ROOT}/${BACKUP_FOLDER_NAME}"
BACKUP_FILE="${BACKUP_ROOT}/backup.tar.gz.pgp"
BACKUP_STATUS_FILE="/statuses/statuses/backup-status.json"

check_dependencies () {
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "This script requires \"${cmd}\" to be installed"
      exit 1
    fi
  done
}

check_dependencies tar gpg shuf curl

echo "Creating backup..."

if [[ ! -f "/lnd/data/chain/bitcoin/mainnet/channel.backup" ]]; then
    echo "No channel.backup file found, skipping backup..."
    exit 1
fi

mkdir -p "${BACKUP_FOLDER_PATH}"

cp --archive "lnd/data/chain/bitcoin/mainnet/channel.backup" "${BACKUP_FOLDER_PATH}/channel.backup"

echo "Adding random padding..."

# Up to 10KB of random binary data
# This prevents the server from being able to tell if the backup has increased
# decreased or stayed the sme size. Combined with random interval decoy backups
# this makes a (already very difficult) timing analysis attack to correlate backup
# activity with channel state changes practically impossible.
padding="$(shuf -i 0-10240 -n 1)"
dd if=/dev/urandom bs="${padding}" count=1 > "${BACKUP_FOLDER_PATH}/.padding"

echo "Creating encrypted tarball..."

tar \
  --create \
  --gzip \
  --verbose \
  --directory "${BACKUP_FOLDER_PATH}/.." \
  "${BACKUP_FOLDER_NAME}" \
  | gpg \
  --batch \
  --symmetric \
  --cipher-algo AES256 \
  --passphrase "${BACKUP_ENCRYPTION_KEY}" \
  --output "${BACKUP_FILE}"

upload_file() {
  local file_to_send="${1}"
  local backup_id="${2}"
  local upload_data=$(jq --null-input \
  --arg name "$backup_id" \
  --arg data "$(base64 $file_to_send)" \
  '{"name": $name, "data": $data}')
  curl -X POST \
    "https://account.runcitadel.space/api/upload" \
    -d "${upload_data}" \
    -H "Content-Type: application/json" \
    --socks5 "${TOR_PROXY_IP}:${TOR_PROXY_PORT}" \
    > /dev/null
}

upload_file "${BACKUP_FILE}" "${BACKUP_ID}"
