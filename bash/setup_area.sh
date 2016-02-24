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
    svn co ${SVNOFF}/PhysicsAnalysis/SUSYPhys/SUSYTools/tags/SUSYTools-00-07-41 SUSYTools
    # dependencies on top of the release (from SUSYTools/doc/packages.txt)
    svn co ${SVNOFF}/PhysicsAnalysis/ElectronPhotonID/ElectronEfficiencyCorrection/tags/ElectronEfficiencyCorrection-00-01-42 ElectronEfficiencyCorrection
    svn co ${SVNOFF}/PhysicsAnalysis/ElectronPhotonID/PhotonEfficiencyCorrection/tags/PhotonEfficiencyCorrection-00-01-14 PhotonEfficiencyCorrection
    
}

function checkout_packages_uci {
    local dev_or_stable="$1" # whether we should checkout the dev branch or the latest production tags
    cd ${PROD_DIR}
    git clone git@github.com:susynt/SusyNtuple.git SusyNtuple
    cd SusyNtuple
    if [ "${dev_or_stable}" = "--stable" ]
    then
        git checkout SusyNtuple-00-04-02  # tag n0220
    else
        git checkout -b master origin/master
    fi
    cd -
    git clone git@github.com:susynt/SusyCommon.git SusyCommon
    cd SusyCommon
    if [ "${dev_or_stable}" = "--stable" ]
    then
        git checkout SusyCommon-00-02-15 # tag n0220
    else
        git checkout -b master origin/master
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

    # patch SUSYTools to add photon cleaning decorators
    echo "Patching SUSYTools to include photon cleaning and ambiguity decorators"
    patch -p0 < patchPhotonDecoratorsSUSYTools.patch

    echo "Done                              -- `date`"
    echo "You can now go ahead and set-up the analysis release"
    echo "and compile all packages by running:"
    echo "source bash/setup_release.sh 2>&1 | tee compile.log"
}

main $*
