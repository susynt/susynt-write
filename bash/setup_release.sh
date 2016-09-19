#!/bin/bash

#
# Execute it with: source setup_release.sh
#

echo "Setup up ATLAS soft"
export ATLAS_LOCAL_ROOT_BASE="/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh

release="Base,2.4.18"

setupATLAS
lsetup "rcsetup -u"
echo ""
echo "Setting up Analysis ${release} and compiling"
lsetup "rcsetup ${release}"
rc find_packages
rc clean
rc compile

# you might want to do
# rcsetup --listPackages SUSY,2.3.38b > packages_susy_2_3_38b.txt
# to have a list to compare to your local packages
