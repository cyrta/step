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

# TEST: Check that step banners are printed when using the -b option

BASEDIR=$(dirname "$0")
RUN="$BASEDIR"/../bin/run

expected() {
    cat <<EOF

===== step4.sh: step1
1

===== step4.sh: step2
2

===== step4.sh: step3
3

===== step4.sh: step4
4
EOF
}

diff <($RUN -b $BASEDIR/prog/step4.sh) <(expected) >/dev/null

