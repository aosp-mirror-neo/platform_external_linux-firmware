#!/bin/bash
#
# Script to invoke copybara to generate an 'IMPORT:' change for linux-firmware.
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

set -e

die () {
	>&2 echo "$1"
	exit 1
}

fw_name="$1"
if [[ -z "${fw_name}" ]]; then
	die "Usage: $0 [fw_name]"
fi

# Save the name of the current branch so we can get back to it.
copybara_branch="$(git branch --show-current)"
if [[ -z "${copybara_branch}" ]]; then
	die "You must be on a branch before running"
fi

# If something fails go back to the branch we were on.
trap "git checkout '${copybara_branch}'" EXIT

# We're going to tell copybara to "push" to our branch. That fails
# if it's already checked out, so checkout the same location but
# without a branch name
git checkout --detach

# Run copybara
copybara --force migrate copy.bara.sky \
	--git-destination-url="$(dirname "$(readlink -f "$0")")" \
	--git-destination-push="${copybara_branch}" \
	"${fw_name}"

git checkout "${copybara_branch}"

# Get a Change-Id added.
git commit --amend --no-edit
