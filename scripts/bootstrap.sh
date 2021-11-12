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

# Download dependencies, setup ml and apply patches.

NAME="$(basename "$0")"
HERE="$(dirname "$0")"
ROOT="$(realpath $HERE/..)"
EXAMPLE=""
CLEAN=0
export GIT_SSL_NO_VERIFY=1

function sync_submodules {
    echo "Syncronising submodules" >&2
    git submodule update --init --recursive --depth 10 --jobs 4 --progress
}

function setup_ml_eval_kit {
    echo " * Downloading dependencies" >&2
    local ML_KIT="$ROOT/lib/ml-embedded-evaluation-kit"

    if [[ ! -e "$ML_KIT/.setup_complete" ]]; then 
        # Setup venv
        pushd "$ML_KIT" > /dev/null
        python3 set_up_default_resources.py

        # Download flatbuffers 
        pushd "dependencies/tensorflow/tensorflow/lite/micro/tools/make" > /dev/null
        mkdir downloads
        ./flatbuffers_download.sh $PWD/downloads

        # Download gemmlowp
        cd downloads
        curl -L https://github.com/google/gemmlowp/archive/fda83bdc38b118cc6b56753bd540caa49e570745.zip --output gemmlowp.zip
        unzip gemmlowp.zip
        mv gemmlowp-fda83bdc38b118cc6b56753bd540caa49e570745 gemmlowp
        rm gemmlowp.zip

        # Download ruy
        curl -L https://github.com/google/ruy/archive/4790797d11a81f96baf24f3731fd3ca44c2c5f8b.zip --output ruy.zip
        unzip ruy.zip
        mv ruy-4790797d11a81f96baf24f3731fd3ca44c2c5f8b ruy
        rm ruy.zip

        popd >/dev/null

        # Generate models and labels 
        ML_GEN_SRC="generated/kws/src"
        ML_GEN_INC="generated/kws/include"
        ./resources_downloaded/env/bin/python3 -m pip install jinja2
        mkdir -p $ML_GEN_SRC
        mkdir -p $ML_GEN_INC
        ./resources_downloaded/env/bin/python3 scripts/py/gen_labels_cpp.py \
            --labels_file resources/kws/labels/ds_cnn_labels.txt \
            --source_folder_path $ML_GEN_SRC \
            --header_folder_path $ML_GEN_INC \
            --output_file_name ds_cnn_labels 
        ./resources_downloaded/env/bin/python3 scripts/py/gen_model_cpp.py \
            --tflite_path resources_downloaded/kws/ds_cnn_clustered_int8_vela_H128.tflite \
            --output_dir $ML_GEN_SRC
        popd

        touch $ML_KIT/.setup_complete
    fi
}

function apply_patches {
    local record="$ROOT/patches/.patches-applied"
    touch "$record"
    while read patch; do
        local name="$(basename "$patch")"
        if grep "$name" "$record" >/dev/null; then
            echo " * Skipping $name" >&2
        else
            echo " * Applying $name" >&2
            patch -p1 -fi "$patch"
            echo "$name" >>"$record"
        fi
    done < <(find patches -iname '*.patch' | sort -n)
}

sync_submodules
setup_ml_eval_kit
apply_patches
