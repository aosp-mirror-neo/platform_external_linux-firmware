#!/bin/bash
#
# Script to cherry-pick 'IMPORT:' CLs. Needed since the Android cherry-picker
# can't handle binary files.
#
# Copyright (C) 2024 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prerequisites:
#
# * Be running in AOSP external/linux-firmware
# * git remote add goog sso://googleplex-android/platform/external/linux-firmware
# * "repo start" a branch for the IMPORT CLs to be picked.

set -e

# We'll use these as temp files. Could use `mktemp` but not worth it...
aosp_changes=_aosp.txt
goog_changes=_goog.txt

rm -f "${aosp_changes}"
rm -f "${goog_changes}"

echo "Fetching..."
git fetch aosp main
git fetch goog main

git log --reverse --format=%B --grep='^IMPORT:' aosp/main | grep '^Change-Id:' > "${aosp_changes}" || true
git log --reverse --format=%B --grep='^IMPORT:' goog/main | grep '^Change-Id:' > "${goog_changes}" || true

new_change_ids="$(diff "${aosp_changes}" "${goog_changes}" | grep '^>' | awk '{print $3}')"

echo
echo "Picking..."

for change_id in ${new_change_ids}; do
  hash="$(git log --format=%H --grep="^Change-Id: ${change_id}" goog/main)"
  echo "Picking $(git log --oneline -1 ${hash})"

  git cherry-pick "${hash}" > /dev/null
  commit_message="$(git show -s --format=%B HEAD |
    sed "s|Change-Id: ${change_id}|(cherry picked from https://googleplex-android-review.googlesource.com/q/commit:${hash})\nMerged-In: ${change_id}\nChange-Id: ${change_id}|"
  )"
  echo "${commit_message}" | git commit -n --amend -F - > /dev/null
done

rm -f "${aosp_changes}"
rm -f "${goog_changes}"
