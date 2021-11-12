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


case "$1" in
    kws)    ;;
    blinky) ;;
    *)
        echo "Usage: $0 <blinky|kws>" >&2
        exit 1
        ;;
esac

set -x

FVP_BIN=VHT-Corstone-300.x
VSI_PY_PATH=$PWD/lib/VHT/interface/audio/python
OPTIONS="-V $VSI_PY_PATH -C cpu_core.mps3_board.visualisation.disable-visualisation=1 -C cpu_core.mps3_board.smsc_91c111.enabled=1 -C cpu_core.mps3_board.hostbridge.userNetworking=1 -C cpu_core.cpu0.semihosting-enable=1 -C cpu_core.mps3_board.telnetterminal0.start_telnet=0 -C cpu_core.mps3_board.uart0.out_file="-"  -C cpu_core.mps3_board.uart0.unbuffered_output=1 --stat  -C cpu_core.mps3_board.DISABLE_GATING=1"

$FVP_BIN $OPTIONS -a cpu_core.cpu0*="build/bootloader/bl2.axf" --data "build/secure_partition/tfm_s_signed.bin"@0x38000000 --data "build/$1/tfm_ns_signed.bin"@0x28060000

