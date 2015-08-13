#!/bin/sh

# Script to setup an area where we compile the packages needed to run NtMaker
#
# Requirements:
# - access to the svn.cern.ch repositories
# - have 'setupATLAS' defined
# - have access to github
#
# davide.gerbaudo@gmail.com, Mar 2013


readonly SCRIPT_NAME=$(basename $0)
# see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
readonly PROG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly PROD_DIR="${PROG_DIR}/../" # 'production' dir, where we checkout all of the packages

function print_usage {
    echo "Usage:"
    echo "setup_area.sh [--stable] [--help]"
    echo " --stable: checkout the latest stable packages, for production"
    echo "           (by default checkout the development branch)"
    echo " --help:   print this message"
}

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

function prepare_directories {
    cd ${PROD_DIR}
    mkdir -p ${PROD_DIR}/susynt_xaod_timing
}

function checkout_packages_external {
    local SVNOFF="svn+ssh://svn.cern.ch/reps/atlasoff/"
    local SVNPHYS="svn+ssh://svn.cern.ch/reps/atlasphys/"
    local SVNWEAK="svn+ssh://svn.cern.ch/reps/atlasphys/Physics/SUSY/Analyses/WeakProduction/"

    cd ${PROD_DIR}

    # base 2.3.18
    svn co ${SVNOFF}/PhysicsAnalysis/SUSYPhys/SUSYTools/tags/SUSYTools-00-06-17-03 SUSYTools
    # Additional packages needed on top of Base,2.3.21 & SUSYTools-00-06-17-03
    svn co ${SVNOFF}/Reconstruction/MET/METUtilities/tags/METUtilities-00-01-45 METUtilities
    svn co ${SVNOFF}/Event/xAOD/xAODMissingET/tags/xAODMissingET-00-01-25 xAODMissingET
    svn co ${SVNOFF}/Reconstruction/MET/METInterface/tags/METInterface-00-01-12 METInterface

    # TrigEgammaMatchingTool (note: this tool should not be used in standalone rootcore, we simply
    # check it out for completeness w.r.t. the SUSYTools package lists
    #svn co ${SVNOFF}/Trigger/TrigAnalysis/TrigEgammaMatchingTool/tags/TrigEgammaMatchingTool-00-00-05 TrigEgammaMatchingTool

    # SusyNtuple dependencies
    svn co ${SVNWEAK}/Mt2/tags/Mt2-00-00-01                                       Mt2
    svn co ${SVNWEAK}/TriggerMatch/tags/TriggerMatch-00-00-10                     TriggerMatch
    svn co ${SVNWEAK}/DGTriggerReweight/tags/DGTriggerReweight-00-00-29           DGTriggerReweight
    svn co ${SVNWEAK}/LeptonTruthTools/tags/LeptonTruthTools-00-01-07             LeptonTruthTools
    svn co ${SVNOFF}/Reconstruction/Jet/JetAnalysisTools/JVFUncertaintyTool/tags/JVFUncertaintyTool-00-00-04  JVFUncertaintyTool

    #todo : check that all packages are actually there
}

function checkout_packages_uci {
    local dev_or_stable="$1" # whether we should checkout the dev branch or the latest production tags
    cd ${PROD_DIR}
    git clone git@github.com:gerbaudo/SusyNtuple.git SusyNtuple
    cd SusyNtuple
    if [ "${dev_or_stable}" = "--stable" ]
    then
        git checkout SusyNtuple-00-02-09  # tag n0211
    else
        git checkout -b mc15 origin/mc15
    fi
    cd -
    git clone git@github.com:gerbaudo/SusyCommon.git SusyCommon
    cd SusyCommon
    if [ "${dev_or_stable}" = "--stable" ]
    then
        git checkout SusyCommon-00-02-09-01 # tag n0211
    else
        git checkout -b mc15 origin/mc15
    fi
    cd -
}

function main {
    if [ $# -ge 2 ]; then
        print_usage
        return
    elif [ $# -eq 1 ] && [ "$1" == "--help" ]; then
        print_usage
        return
    fi
    echo "Starting                          -- `date`"
    # todo: sanity/env checks (probably better off in python)
    # if missing_kerberos
    # then
    #     echo "cannot continue"
    #     return 1
    # else
    #     echo "checkout and compile"
    # fi
    prepare_directories
    checkout_packages_external
    checkout_packages_uci $*
    echo "Done                              -- `date`"
    echo "You can now go ahead and compile with:"
    echo "rc find_packages"
    echo "rc compile 2>&1 | tee compile.log"

    echo ""
    tput setaf 2
    echo 'Note: you must point the bTag SF tool in SUSYTools to to the CDIFiles
located in SusyCommon/data/. To do this add Ln587 below and edit the "ScaleFactorFileName"
property line (Ln588 below) in SUSYTools/Root/SUSYToolsInit.cxx:

 586       ATH_CHECK( btagTool->setProperty("JetAuthor",      jetdef ) );
 587       std::string tmparea=getenv("ROOTCOREBIN");
 588       ATH_CHECK( btagTool->setProperty("ScaleFactorFileName", tmparea + "/data/SusyCommon/CDIFiles/13TeV/2015-PreRecomm-13TeV-MC12-CDI_July15-v1.root") );
 589       ATH_CHECK( btagTool->setProperty("SystematicsStrategy","Envelope") ); '
    tput setaf 1
    echo "Do this before running bash/setup_release.sh (otherwise SUSYTools will not compile)"
    tput sgr0
    
}

main $*
