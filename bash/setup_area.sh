#!/bin/sh

# Script to setup an area where we compile the packages needed to run NtMaker
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
# - source this script
#   > source setup_area.sh
# - this will create a directory `prod` with all the packages, and compile them
# - try running NtMaker
# davide.gerbaudo@gmail.com, Mar 2013

PROD_DIR="prod"

echo "Starting                          -- `date`"

mkdir -p ${PROD_DIR}
cd    ${PROD_DIR}

git clone git@github.com:gerbaudo/SusyNtuple.git SusyNtuple
cd SusyNtuple; git checkout SusyNtuple-00-01-11-01; cd -
git clone git@github.com:gerbaudo/SusyCommon.git SusyCommon
cd SusyCommon; git checkout SusyCommon-00-01-06; cd -

svn co svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Analyses/WeakProduction/MultiLep/tags/MultiLep-01-06-08    MultiLep

sed -i -e '/asetup/s/^/#/' MultiLep/installscripts/install_script.sh # forget about asetup, we just need root
localSetupROOT --rootVersion 5.34.18-x86_64-slc6-gcc4.7
# the option below is the one needed for submit.py (see output of localSetupROOT)
# --rootVer=5.34/18 --cmtConfig=x86_64-slc6-gcc47-opt

source MultiLep/installscripts/install_script.sh

echo "to fix SUSYTools-00-03-21 you need to" # tmp DG
echo "sed -i  '/PACKAGE\_DEP/ s/$/ PhotonEfficiencyCorrection/' SUSYTools/cmt/Makefile.RootCore"

echo "Done compiling                    -- `date`"

