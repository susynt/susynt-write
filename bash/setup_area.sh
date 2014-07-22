#!/bin/sh

# Script to setup an area where we compile the packages needed to run NtMaker
#
# Requirements:
# - access to the svn.cern.ch repositories (with kerberos auth)
# - have 'localSetupROOT' defined.
#   This depends on your specifi setup; on gpatlas* these commands are defined with
#   > export ATLAS_LOCAL_ROOT_BASE=/export/home/atlasadmin/ATLASLocalRootBase
#   > source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
#
# davide.gerbaudo@gmail.com, Jun 2014

function get_d3pdreader() {
    # get the D3PDReader that I build
    # (see https://twiki.cern.ch/twiki/bin/viewauth/AtlasProtected/D3PDMakerReader)
    # The official one from atlasoff/PhysicsAnalysis/D3PDTools/D3PDReader has missing branches.
    local FILENAME="D3PDReader_ntupcommon_v_0_1.tgz"
    local ORIGIN=http://test-gerbaudo.web.cern.ch/test-gerbaudo/${FILENAME}
    wget ${ORIGIN}
    tar xzf ${FILENAME}
    rm ${FILENAME}
}

function checkout_susytools_codebase() {
    # checkout SUSYTools and all its dependencies
    svn co -r 600009 svn+ssh://svn.cern.ch/reps/atlasoff/PhysicsAnalysis/SUSYPhys/SUSYTools/trunk SUSYTools
    SUSYTools/python/install.py
}

function checkout_2lep_packages() {
    # checkout the additional packages we need for the 2 lep
    local SVN_WEAK_PROD="svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Analyses/WeakProduction"
    svn co ${SVN_WEAK_PROD}/DGTriggerReweight/tags/DGTriggerReweight-00-00-29 DGTriggerReweight
    svn co ${SVN_WEAK_PROD}/LeptonTruthTools/tags/LeptonTruthTools-00-01-07   LeptonTruthTools
    svn co ${SVN_WEAK_PROD}/Mt2/tags/Mt2-00-00-01                             Mt2
    svn co ${SVN_WEAK_PROD}/TriggerMatch/tags/TriggerMatch-00-00-10           TriggerMatch
}

function checkout_susynt_codebase() {
    # checkout our own packages
    git clone git@github.com:gerbaudo/SusyCommon.git SusyCommon
    cd SusyCommon; git checkout -b ntup-common origin/ntup-common; cd -
    git clone git@github.com:gerbaudo/SusyNtuple.git SusyNtuple
    # for now using SusyNtuple master
}

function compile_packages() {
    localSetupROOT --rootVersion 5.34.18-x86_64-slc6-gcc4.7
    : ${ROOTSYS:?"Need to set ROOTSYS to a valid location; missing ATLAS setup?"}
    # the option below is the one needed for submit.py (see output of localSetupROOT)
    # --rootVer=5.34/18 --cmtConfig=x86_64-slc6-gcc47-opt
    source RootCore/scripts/setup.sh
    rc find_packages
    rc compile
}

#___________________________________________________________
function main() {

    local PROD_DIR="prod"
    echo "Starting                          -- `date`"
    mkdir -p ${PROD_DIR}
    cd       ${PROD_DIR}
    get_d3pdreader
    checkout_susytools_codebase
    checkout_2lep_packages
    checkout_susynt_codebase
    compile_packages
    echo "Done compiling                    -- `date`"
}

main
