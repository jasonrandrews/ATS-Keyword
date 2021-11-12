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

set -e

HERE="$(dirname "$0")"
ROOT="$(realpath $HERE/..)"

# create binary files of secure and non secure build outputs
echo "Extracting binaries from axf files."
fromelf --bin --output="$ROOT/build/kws/tfm_ns_unsigned.bin" "$ROOT/build/kws/tfm_ns.axf" --bincombined

# sign with parameters extracted of tfm cmake build

echo "Signing update for non-secure binary."
python3 $ROOT/lib/tf-m/bl2/ext/mcuboot/scripts/wrapper/wrapper.py \
        -v 1.4.0 \
        --layout $(readlink -f "$ROOT/bsp/signing_layout_ns_update.c") \
        -k $ROOT/lib/tf-m/bl2/ext/mcuboot/root-RSA-2048_1.pem  \
        --public-key-format full \
        --align 1 \
        --pad \
        --pad-header \
        -H 0x400 \
        -s auto \
        "$ROOT/build/kws/tfm_ns_unsigned.bin" \
        "$ROOT/build/kws/tfm_ns_signed_update.bin"

openssl dgst -sha256 -binary -out $ROOT/build/kws/update-digest.bin $ROOT/build/kws/tfm_ns_signed_update.bin
openssl pkeyutl -sign -pkeyopt digest:sha256 -pkeyopt rsa_padding_mode:pss -pkeyopt rsa_mgf1_md:sha256 -inkey $ROOT/lib/tf-m/bl2/ext/mcuboot/root-RSA-2048_1.pem -in $ROOT/build/kws/update-digest.bin -out $ROOT/build/kws/update-signature.bin
openssl base64 -A -in $ROOT/build/kws/update-signature.bin -out $ROOT/build/kws/update-signature.txt
echo "Use this base 64 encoded signature in OTA job:"
cat $ROOT/build/kws/update-signature.txt
echo ""
