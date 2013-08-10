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

__STEP_PROG="$(basename "$0") (step)"

__step_die() {
    echo "$__STEP_PROG: $@" >&2
    exit 1
}

eval set -- "$__STEP_ARGS"
__STEP_SKIPS=""

while true; do 
    case "$1" in
	--banner|-b)
	    __STEP_BANNER=1
	    shift
	    ;;
	--command|-c)
	    __STEP_COMMAND=1
	    shift
	    ;;
	--verbose|-v)
	    __STEP_BANNER=1
	    __STEP_COMMAND=1
	    shift
	    ;;
	--only|-o)
	    __STEP_ONLY=$2
	    __STEP_REQUESTED=$2
	    shift 2
	    ;;
	--from|-f)
	    __STEP_FROM=$2
	    __STEP_DISABLED=1
	    __STEP_REQUESTED=$2
	    shift 2
	    ;;
	--to|-t)
	    __STEP_TO=$2
	    __STEP_REQUESTED=$2
	    shift 2
	    ;;
	--list|-l)
	    __STEP_LIST=1
	    shift
	    ;;
	--skip|-s)
	    __STEP_SKIPS="$__STEP_SKIPS __STEP_SKIP_$2&"
	    shift 2
	    ;;
	--debug|-d)
	    __STEP_DEBUG=1
	    shift
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    break
	    ;;
    esac
done

step_banner() {
    local prog=$1
    local step=$2

    echo -e "\n===== $prog: $step"
}
STEP_BANNER=step_banner

step_command() {
    echo "+ $@"
}
STEP_COMMAND=step_command

if [ "$__STEP_DEBUG" ] ; then
    set -x
fi

run() {
    local step=""
    if [ "$1" == "-f" ] ; then
	shift
	step="$1"
	local is_function=true
    else
	step="$1"
	shift
    fi
    [ "$step" ] || __step_die "No step specified in run"

    if [ "$__STEP_LIST" ] ; then
        echo $step
        return 0
    fi
    if [ "$__STEP_ONLY" ] && [ "$step" != "$__STEP_ONLY" ] ; then
        return 0
    fi
    if [ "$step" == "$__STEP_FROM" ] ; then
        unset __STEP_DISABLED
    fi
    case "$__STEP_SKIPS" in
	*__STEP_SKIP_${step}*)
            __STEP_SKIPPED=1
	    __STEP_PREVIOUS_DISABLED=$__STEP_DISABLED
	    __STEP_DISABLED=1
	    ;;
    esac

    if [ "$__STEP_DISABLED" ] ; then
	if [ "$__STEP_SKIPPED" ] ; then
	    __STEP_DISABLED=$__STEP_PREVIOUS_DISABLED
	fi
        return 0
    fi
    __STEP_EXECUTED=1
    if [ "$__STEP_BANNER" ] ; then
	$STEP_BANNER $(basename "$0") $step
    fi
    if [ "$__STEP_COMMAND" ] ; then
	if [ "$is_function" ] ; then
	    set -x
	else
	    $STEP_COMMAND "$@"
	fi
    fi

    "$@" 
    local return_code=$?
    set +x

    if [ $return_code -ne 0 ] ; then
	exit $return_code
    fi

    if [ "$step" == "$__STEP_TO" ] ; then
        __STEP_DISABLED=1
    fi
    return $return_code
}

__step_check_exit() {
    if [ "$__STEP_REQUESTED" ] && [ ! "$__STEP_EXECUTED" ] ; then
        __step_die "No such step: $__STEP_REQUESTED"
    fi
}

trap __step_check_exit EXIT
