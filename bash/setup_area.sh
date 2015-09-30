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

    # base 2.3.28
    svn co ${SVNOFF}/PhysicsAnalysis/SUSYPhys/SUSYTools/tags/SUSYTools-00-06-24-01 SUSYTools
    svn co ${SVNOFF}/PhysicsAnalysis/AnalysisCommon/AssociationUtils/tags/AssociationUtils-01-01-04 AssociationUtils
    svn co ${SVNOFF}/Event/xAOD/xAODMuon/tags/xAODMuon-00-16-02 xAODMuon
    # get the IsolationSelectionTool from the corresponding AnalysisSusy (it has the newer WP)
    svn co ${SVNOFF}/PhysicsAnalysis/AnalysisCommon/IsolationSelection-00-01-00 IsolationSelection
    # check out this tag of TauAnalysisTools so things work
    svn co ${SVNOFF}/PhysicsAnalysis/TauID/TauAnalysisTools/tags/TauAnalysisTools-00-00-50 TauAnalysisTools

    # SusyNtuple dependencies
    svn co ${SVNWEAK}/Mt2/tags/Mt2-00-00-01                                       Mt2
}

function checkout_packages_uci {
    local dev_or_stable="$1"
    local GIT=""
    local tag_common=""
    local tag_ntuple=""
    if [[ "${dev_or_stable}" = "dev" ]]
    then
        GIT="git@github.com:" # read+write
        tag_common="mc15"
        tag_ntuple="master"
    elif [[ "${dev_or_stable}" = "stable" ]]
    then
        GIT="https://github.com/" # read-only
        tag_common="SusyCommon-00-02-10" # tag n0213
        tag_ntuple="SusyNtuple-00-03-01" # tag n0213-02
    else
        echo "unknown dev_or_stable '${dev_or_stable}'"
    fi
    cd ${PROD_DIR}
    git clone ${GIT}susynt/SusyNtuple.git SusyNtuple
    git clone ${GIT}susynt/SusyCommon.git SusyCommon

    cd ${PROD_DIR}/SusyNtuple && git checkout ${tag_ntuple}
    cd ${PROD_DIR}/SusyCommon && git checkout ${tag_common}
    cd ${PROD_DIR}
}
#-----------------------------------------------------------
function main {
    # parse as in
    # http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
    local dev_or_stable="stable"
    local help=""
    while [[ $# > 0 ]]
    do
        key="$1"
        case $key in
            --dev)
                dev_or_stable="dev"
                ;;
            -h|--help)
                help=true
                ;;
            *)
                # unknown option
                ;;
        esac
        shift # past argument or value
    done


    if [[ ${help} ]]
    then
        print_usage
    else
        echo "Starting                          -- `date`"
        prepare_directories
        checkout_packages_external
        checkout_packages_uci ${dev_or_stable}
        echo "Done                              -- `date`"
        echo "You can now go ahead and compile with:"
        echo "rc find_packages"
        echo "rc compile 2>&1 | tee compile.log"

    fi
}
#-----------------------------------------------------------
main $*
