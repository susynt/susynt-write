#!/bin/bash

#
# Execute it with: source setup_release.sh
#

echo "Setup up ATLAS soft"
export ATLAS_LOCAL_ROOT_BASE="/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh

setupATLAS
rcSetup Base,2.3.14
rc find_packages
rc compile

