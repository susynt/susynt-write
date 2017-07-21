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
    local SVN3GEN="svn+ssh://svn.cern.ch/reps/atlasphys-susy/Physics/SUSY/Analyses/StopSbottom"

    cd ${PROD_DIR}
    # SUSYTools for ABR 2.4.32
    svn co ${SVNOFF}/PhysicsAnalysis/SUSYPhys/SUSYTools/tags/SUSYTools-00-08-65 SUSYTools

}

function checkout_packages_uci {
    local dev_or_stable="$1" # whether we should checkout the dev branch or the latest production tags
    if [ "${dev_or_stable}" = "--stable" ]
    then
        echo "---------------------------------------------"
        tput setaf 2
        echo " You are checking out the tags for the n0234"
        echo " production of SusyNt."
        tput sgr0
        echo "---------------------------------------------"
    else
        echo "---------------------------------------------"
        echo " You are checking out the master branches of "
        echo " SusyNtuple and SusyCommon."
        tput setaf 1
        echo " If you mean to write SusyNt's from the   "
        echo " n0234 production, please call this script"
        echo " with the '--stable' cmd line option."
        tput sgr0
        echo "---------------------------------------------"
    fi
    
    cd ${PROD_DIR}
    #git clone git@github.com:susynt/SusyNtuple.git SusyNtuple
    #cd SusyNtuple
    if [ "${dev_or_stable}" = "--stable" ]
    then
        git clone -b master git@github.com:susynt/SusyNtuple.git SusyNtuple
        cd SusyNtuple
        git checkout SusyNtuple-00-06-00  # tag n0234
        cd -
    else
        git clone -b master git@github.com:susynt/SusyNtuple.git SusyNtuple
    fi
    if [ "${dev_or_stable}" = "--stable" ]
    then
        git clone -b master git@github.com:susynt/SusyCommon.git SusyCommon
        cd SusyCommon
        git checkout SusyCommon-00-05-00 # tag n0234
        cd -
    else
        git clone -b master git@github.com:susynt/SusyCommon.git SusyCommon
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

    cd ${PROD_DIR}
    echo "Patching SUSYTools to include:"
    echo "  - photon decorators"
    echo "  - to not enforce OR for bad jet definition"
    echo "  - add boolean to getCorrectedMu whether to include DataScaleFactor"
    patch -p0 < patchSUSYTools.patch 
    echo "Done                              -- `date`"
    echo "You can now go ahead and set-up the analysis release"
    echo "and compile all packages by running:"
    echo "source bash/setup_release.sh 2>&1 | tee compile.log"
}

main $*
