#!/bin/bash

# Copyright 2013 blackchip.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# TEST: Check that --list can be used as a dry run for specific steps

BASEDIR=$(dirname "$0")
RUN="$BASEDIR"/../bin/run

expected() {
    cat <<EOF
step2
step3
EOF
}

diff <($RUN --list --from step2 --to step3 $BASEDIR/prog/step4.sh) \
    <(expected) >/dev/null

