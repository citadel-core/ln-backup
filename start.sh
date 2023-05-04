#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2020 Umbrel. https://getumbrel.com
# SPDX-FileCopyrightText: 2023 Citadel and contributors. https://runcitadel.space
#
# SPDX-License-Identifier: GPL-3.0-or-later

./backup.sh &
./monitor.sh &
./decoy.sh &

wait
