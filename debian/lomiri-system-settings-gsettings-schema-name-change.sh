#!/bin/bash -euf

# Copyright (C) 2021 UBports Foundation.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authored by: Ratchanan Srirattanamet <ratchanan@ubports.com>

set -o pipefail

DCONF_SOURCE_DIR="/com/ubuntu/touch/system-settings/"
DCONF_TARGET_DIR="/com/lomiri/lomiri-system-settings/"

# session-migration says we should be idempotent. We simply check if the target
# is not empty as to not overwrite things that is set manually.
target_content=$(dconf dump $DCONF_TARGET_DIR)
if [ -n "$target_content" ]; then
    echo "${DCONF_TARGET_DIR} is not empty. Perhaps the migration has already" \
         "happened, and/or the user has set additional settings."
    exit 0
fi

# Now, simply pipe the output of "dconf dump" to "dconf load". Won't wipe the
# old data, in case the migration goes wrong.

dconf dump $DCONF_SOURCE_DIR | dconf load $DCONF_TARGET_DIR

echo "Setting for lomiri-system-settings migrated successfully."
