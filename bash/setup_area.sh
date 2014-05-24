#!/bin/sh

# Script to setup the area for submission of the SusyNt jobs.
#
# Based on Steve's instructions.
# Requirements:
# - access to the svn.cern.ch repositories
# - have 'localSetuPandaClient' defined.
#   This depends on your specifi setup; on gpatlas* these commands are defined with
#   > export ATLAS_LOCAL_ROOT_BASE=/export/home/atlasadmin/ATLASLocalRootBase
#   > source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
# - voms proxy
#
# Main steps:
# - source this script with a tag, for example
#   > source setup_area.sh
# - this will create two directories :
#   - 'prod_n0135' (with all the packages)
#   - 'subm_n0135' (to submit the jobs)
# - check that everything compiled (if not, fix it and 'create_tarball.sh'), then submit the jobs:
#   > ./submit.py mc  -t n0135 --met Default -f <a-sample-list.txt> --nickname <my-nickname>
#
# davide.gerbaudo@gmail.com, Mar 2013

PROD_DIR="prod"
SUBM_DIR="subm"

echo "Starting                          -- `date`"

mkdir -p ${PROD_DIR}
cd    ${PROD_DIR}

git clone git@github.com:gerbaudo/SusyNtuple.git SusyNtuple
git clone git@github.com:gerbaudo/SusyCommon.git SusyCommon

svn co svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Analyses/WeakProduction/MultiLep/tags/MultiLep-01-06-08    MultiLep

sed -i -e '/asetup/s/^/#/' MultiLep/installscripts/install_script.sh # forget about asetup, we just need root
localSetupROOT --rootVersion 5.34.18-x86_64-slc6-gcc4.7
# the option below is the one needed for submit.py (see output of localSetupROOT)
# --rootVer=5.34/18 --cmtConfig=x86_64-slc6-gcc47-opt

source MultiLep/installscripts/install_script.sh

echo "Done compiling                    -- `date`"

cd ..

# this part should be revised.  (DG 2014-05-07)

# Is there any reason why the 'grid' stuff cannot go in a small
# separate repo? In this way we can just always get the head (also,
# this part does not contain code to be compiled, just submission
# scripts and lists)

# -- git clone git@github.com:gerbaudo/SusyCommon.git ${SUBM_DIR}
# -- mv     ${SUBM_DIR}/SusyCommon/grid/* ${SUBM_DIR}/
# -- rm -rf ${SUBM_DIR}/SusyCommon
# -- cd    ${SUBM_DIR}
# -- 
# -- localSetupPandaClient
# -- ./create_tarball.sh

echo "Done, ready to submit jobs        -- `date`"

