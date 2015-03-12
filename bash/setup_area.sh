#!/bin/sh

# Script to setup an area where we compile the packages needed to run NtMaker
#
# Requirements:
# - access to the svn.cern.ch repositories
# - have 'localSetupRoot' defined.
#   This depends on your specifi setup; on gpatlas* these commands are defined with
#   > export ATLAS_LOCAL_ROOT_BASE =/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
#   > source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
#
# Main steps:
# - source this script
#   > source setup_area.sh
# - this will create a directory `prod` with all the packages, and compile them
# - try running NtMaker
# davide.gerbaudo@gmail.com, Mar 2013


readonly SCRIPT_NAME=$(basename $0)
# see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
readonly PROG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly PROD_DIR="${PROG_DIR}/../" # 'production' dir, where we checkout all of the packages

function require_root {
    : ${ROOTSYS:?"Need to set up root."}
}
function echoerr() { echo "$@" 1>&2; }
function missing_kerberos {
    local missing_kerberos_ticket=$(klist 2>&1 | grep -c "No credentials cache found")
    if [[ "${missing_kerberos_ticket}" -eq "0" ]]
    then
        echo "missing kerberos ticket"
        return 1
    else
        return 0
    fi
}

function checkout_packages {
    cd ${PROD_DIR}

    cp ${PROG_DIR}/sourceme.sh ${PROD_DIR}/
    mkdir -p ${PROD_DIR}/susynt_xaod_timing


    local SVNOFF="svn+ssh://svn.cern.ch/reps/atlasoff/"
    local SVNPHYS="svn+ssh://svn.cern.ch/reps/atlasphys/"
    local SVNWEAK="svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Analyses/WeakProduction/"

    # base 2.0.18
    #svn co ${SVNOFF}/PhysicsAnalysis/SUSYPhys/SUSYTools/tags/SUSYTools-00-05-00-14 SUSYTools
    #svn co ${SVNOFF}/PhysicsAnalysis/TauID/TauAnalysisTools/tags/TauAnalysisTools-00-00-13 TauAnalysisTools

    # base 2.0.27
    svn co ${SVNOFF}/PhysicsAnalysis/SUSYPhys/SUSYTools/tags/SUSYTools-00-05-00-21 SUSYTools
    # svn co ${SVNOFF}/Event/xAOD/xAODCore/tags/xAODCore-00-00-87-01 xAODCore
    # svn co ${SVNOFF}/Event/xAOD/xAODMissingET/tags/xAODMissingET-00-01-13 xAODMissingET
    # svn co ${SVNOFF}/Reconstruction/MET/METInterface/tags/METInterface-00-01-02 METInterface
    # svn co ${SVNOFF}/Reconstruction/MET/METUtilities/tags/METUtilities-00-01-11-01 METUtilities
    # svn co ${SVNOFF}/Reconstruction/Jet/JetCalibTools/tags/JetCalibTools-00-04-20 JetCalibTools
    # svn co ${SVNOFF}/PhysicsAnalysis/ElectronPhotonID/ElectronEfficiencyCorrection/tags/ElectronEfficiencyCorrection-00-01-13 ElectronEfficiencyCorrection
    # svn co ${SVNOFF}/InnerDetector/InDetRecTools/InDetTrackSelectionTool/tags/InDetTrackSelectionTool-00-01-10 InDetTrackSelectionTool
    # svn co ${SVNOFF}/Reconstruction/EventShapes/EventShapeTools/tags/EventShapeTools-00-01-09 EventShapeTools

    # Additional packages needed on top of Base,2.1.27 (will not be needed for a future AnalysisBase/AnalysisSUSY release)
    svn co ${SVNOFF}/Reconstruction/EventShapes/EventShapeTools/tags/EventShapeTools-00-01-09 EventShapeTools
    svn co ${SVNOFF}/Reconstruction/EventShapes/EventShapeInterface/tags/EventShapeInterface-00-00-09 EventShapeInterface
    svn co ${SVNOFF}/PhysicsAnalysis/ElectronPhotonID/ElectronEfficiencyCorrection/tags/ElectronEfficiencyCorrection-00-01-19 ElectronEfficiencyCorrection
    svn co ${SVNOFF}/Reconstruction/Jet/JetCalibTools/tags/JetCalibTools-00-04-29 JetCalibTools
    svn co ${SVNOFF}/Event/xAOD/xAODCore/tags/xAODCore-00-00-87-01 xAODCore

    # SusyNtuple dependencies
    svn co ${SVNWEAK}/Mt2/tags/Mt2-00-00-01                                       Mt2
    svn co ${SVNWEAK}/TriggerMatch/tags/TriggerMatch-00-00-10                     TriggerMatch
    svn co ${SVNWEAK}/DGTriggerReweight/tags/DGTriggerReweight-00-00-29           DGTriggerReweight
    svn co ${SVNWEAK}/LeptonTruthTools/tags/LeptonTruthTools-00-01-07             LeptonTruthTools
    svn co ${SVNOFF}/Reconstruction/Jet/JetAnalysisTools/JVFUncertaintyTool/tags/JVFUncertaintyTool-00-00-04  JVFUncertaintyTool

    git clone git@github.com:gerbaudo/SusyNtuple.git SusyNtuple
    cd SusyNtuple; git checkout -b xaod origin/xaod; cd -
    git clone git@github.com:gerbaudo/SusyCommon.git SusyCommon
    cd SusyCommon; git checkout -b xaod origin/xaod; cd -
    #todo : check that all packages are actually there

}

function compile_packages {
    setupATLAS
    rcSetup Base,2.1.27
    # for grid submissions commands, see
    # see https://twiki.cern.ch/twiki/bin/viewauth/AtlasProtected/AnalysisRelease
    rc find_packages
    rc clean
    rc compile
}

function main {
    echo "Starting                          -- `date`"
    # todo: sanity/env checks (probably better off in python)
    # if missing_kerberos
    # then
    #     echo "cannot continue"
    #     return 1
    # else
    #     echo "checkout and compile"
    # fi
    checkout_packages
    #AT: not working ! use sourceme.sh instead
    #compile_packages
    echo "Done                              -- `date`"
}

main
