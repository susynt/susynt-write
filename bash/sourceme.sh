#!/bin/bash

#
# Execute it with: source sourceme.sh
#

export WORKAREA=$PWD

echo "Setup up ATLAS soft"
export ATLAS_LOCAL_ROOT_BASE="/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh

setupATLAS
rcSetup Base,2.1.27
rc find_packages
rc clean
rc compile

