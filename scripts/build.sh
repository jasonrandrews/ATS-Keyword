#!/bin/bash

#  Copyright (c) 2021 Arm Limited. All rights reserved.
#  SPDX-License-Identifier: Apache-2.0
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# Build an example.

NAME="$(basename "$0")"
HERE="$(dirname "$0")"
ROOT="$(realpath $HERE/..)"
EXAMPLE=""
CLEAN=0

set -e 

function build_with_cbuild {
    CBUILD="$(which cbuild.sh)"
    if [[ ! -f "$CBUILD" ]]; then
        echo "${NAME}: cbuild.sh is not in PATH" >&2
        exit 1
    fi

    CBUILD_ARGS="--jobs=$(grep processor /proc/cpuinfo | wc -l)"

    mkdir -p build

    # Force clean build when example has changed.
    case "$EXAMPLE" in
        kws)
            if [[ -e build/blinky ]]; then
                echo "Example has changed, clean build forced" >&2
                CLEAN=1
            fi
            ;;
        blinky)
            if [[ -e build/kws ]]; then
                echo "Example has changed, clean build forced" >&2
                CLEAN=1
            fi
            ;;
        *)                                          ;;
    esac


    if [[ $CLEAN -ne 0 ]]; then
        echo "Clean building $EXAMPLE" >&2
        rm -rf build/$EXAMPLE
    else
        echo "Building $EXAMPLE" >&2
    fi

    (
        set -e
        "$CBUILD" $CBUILD_ARGS "$ROOT/tfm.bootloader.cprj"
        "$CBUILD" $CBUILD_ARGS "$ROOT/tfm.secure.cprj"
        "$CBUILD" $CBUILD_ARGS "$ROOT/tfm.${EXAMPLE}_ns.cprj"
        "$ROOT/scripts/sign_binaries.sh" $EXAMPLE
        [[ "$EXAMPLE" = "kws" ]] && "$ROOT/scripts/sign_update_binaries.sh" || :
    )
}

function show_usage {
    cat <<EOF
Usage: $0 [options] example

Download dependencies, apply patches and build an example.

Options:
    -h,--help   Show this help
    -c,--clean  Clean build

Examples:
    blinky
    kws
EOF
}

if [[ $# -eq 0 ]]; then
    show_usage >&2
    exit 1
fi

for arg in $@; do
    case $arg in
        -h|--help)  show_usage ; exit 0     ;;
        -c|--clean) CLEAN=1                 ;;
        kws)        EXAMPLE="kws"           ;;
        blinky)     EXAMPLE="blinky"        ;;
        *)          show_usage >&2 ; exit 1 ;;
    esac
done

build_with_cbuild
