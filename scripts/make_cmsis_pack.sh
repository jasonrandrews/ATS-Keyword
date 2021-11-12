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

# This creates a cmsis pack based on a bootstrapped repo. Requires 7z.

cd $(dirname "$0")

REPO_DIR=$(pwd)
REPO_DIR=${REPO_DIR%/*} # get parent path
REPO_DIR=${REPO_DIR##*/} # get the dir name

rm -rf ./ARM.DevSummitDemo.1.0.0.pack

7z a -tzip ARM.DevSummitDemo.1.0.0.pack ../../${REPO_DIR} \
-xr'!.*' \
-xr'!*.xml' \
-xr'!*.html' \
-xr'!*.htm' \
-xr'!*.js' \
-xr'!*.pbtxt' \
-xr'!*.swift' \
-xr'!*.go' \
-xr'!*.java' \
-xr'!*.php' \
-xr'!*.pb' \
-x"!${REPO_DIR}/RTE" \
-x"!${REPO_DIR}/build" \
-x"!${REPO_DIR}/ci" \
-x"!${REPO_DIR}/lib/amazon_freertos/doc" \
-x"!${REPO_DIR}/lib/amazon_freertos/projects" \
-x"!${REPO_DIR}/lib/amazon_freertos/tests" \
-x"!${REPO_DIR}/lib/amazon_freertos/tools" \
-x"!${REPO_DIR}/lib/amazon_freertos/vendors" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/3rdparty/CMock" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/3rdparty/unity" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/ble" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/lwip" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/lwip_osal" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/tinycrypt" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/tracealyzer_recorder" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/win_pcap" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/coreMQTT-Agent/test" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/coreMQTT/test" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/coreHTTP/test" \
-x"!${REPO_DIR}/lib/amazon_freertos/libraries/abstractions/pkcs11/corePKCS11/test" \
-x"!${REPO_DIR}/lib/mcuboot/boot/cypress" \
-x"!${REPO_DIR}/lib/mcuboot/ext/mbedtls/tests" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/resources_downloaded" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DAP" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Documentation" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/ComputeLibrary" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/DSP_Lib_TestSuite" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/Projects" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/Toolchain" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/Platforms" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/Scripts" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/Examples" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/Testing" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DSP/PythonWrapper" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DoxyGen" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Pack" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/NN/NN_Lib_Tests" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/NN/Tests" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/NN/Scripts" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/NN/Examples" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/CoreValidation/Source" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/CoreValidation/Tests" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/RTOS2/Source" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/RTOS2/Template" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/RTOS2/RTX" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Utilities" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Core_A/Source" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Core/Template" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/RTOS" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/DAP" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Driver/DriverTemplates" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/CMSIS/Driver/VIO" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/compiler" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/java" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/go" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/python" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/stream_executor" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/tools" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/ios" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/experimental" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/tutorials" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/java" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/profiling" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/g3doc" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/testdata" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/swift" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/tools" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/examples" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/python" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/testing" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/micro/tools/make/downloads/flatbuffers/tests" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/micro/tools/make/downloads/flatbuffers/samples" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/micro/tools/make/downloads/gemmlowp/test" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/micro/examples" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/core/kernels/fuzzing" \
-x"!${REPO_DIR}/lib/VHT/DoxyGen" \
-x"!${REPO_DIR}/lib/tfm_test/test" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/arm/mps2" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/arm/musca_b1" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/arm/musca_s1" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/cypress" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/cypress" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/lairdconnectivity" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/nordic_nrf" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/nuvoton" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/nxp" \
-x"!${REPO_DIR}/lib/tf-m/platform/ext/target/stm" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/tensorflow/tensorflow/lite/objc" \
-x"!${REPO_DIR}/lib/mbedcrypto/tests" \
-x"!${REPO_DIR}/lib/ml-embedded-evaluation-kit/dependencies/cmsis/ARM.CMSIS.pdsc"

7z a -tzip ARM.DevSummitDemo.1.0.0.pack ./ARM.DevSummitDemo.pack.desc
7z rn ARM.DevSummitDemo.1.0.0.pack ARM.DevSummitDemo.pack.desc ARM.DevSummitDemo.pdsc
