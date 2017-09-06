#!/bin/bash

######################################################################
# setup_area
#
# script to checkout the packages for a given release
# of susyNt and to setup the area to run the software
#
# daniel.joseph.antrim@cern.ch
# August 2017
#
######################################################################

function print_usage {
    echo "------------------------------------------------"
    echo "setup_area"
    echo ""
    echo "Options:"
    echo " --stable             Checkout tag n0234 branches of SusyCommon and SusyNtuple" 
    echo " --master             Checkout master branches of SusyCommon and SusyNtuple"
    echo " --sn                 Set branch/tag to checkout for SusyNtuple"
    echo " --sc                 Set branch/tag to checkout for SusyCommon"
    echo " --skip-patch         Do not perform patch of SUSYTools"
    echo " -h|--help            Print this help message"
    echo ""
    echo "Example usage:"
    echo " - Setup the area for stable use:"
    echo "   $ source setup_area.sh --stable"
    echo " - Checkout 'cmake' and 'r21' branches of SusyNtuple and SusyCommon:"
    echo "   $ source setup_area.sh --sn cmake --sc r21" 
    echo " NB A tag/branch for SusyCommon AND SusyNtuple is required"
    echo "------------------------------------------------"
}

function prepare_directories {

    # make sources directory for dumping the code
    dirname="source/"
    if [[ -d "$dirname" ]]; then
        echo "$dirname directory exists"
    else
        echo "Creating $dirname directory"
    fi
    mkdir -p $dirname

    #cp patchSUSYTools.patch $dirname 
}

function get_externals_git {

    skip_patch=$1

    # setup atlas git
    echo "setup_area    Setting up ATLAS git"
    lsetup git

    startdir=${PWD}
    sourcedir="./source/"
    if [[ -d $sourcedir ]]; then
        cd $sourcedir
    else
        echo "setup_area    ERROR No $sourcedir directory"
        return 1
    fi

    sourcedir=${PWD}

    echo "setup_area    Setting up the AnalysisBase release"
    lsetup "asetup 21.2,AnalysisBase,latest,here"

    echo "setup_area    Setting up sparseified ATLAS SW from susynt fork"
    git atlas init-workdir https://:@gitlab.cern.ch:8443/susynt/athena.git
    athenatag="21.2"

    if [[ -d "./athena/" ]]; then

        cd $startdir
        cp patchSUSYTools.patch $sourcedir/athena/
        cd $sourcedir/athena/

        echo "setup_area    Checking out ATLAS SW release ${athenatag}"
        git checkout origin/${athenatag} 
        git atlas addpkg SUSYTools

        if [[ $skip_patch == 0 ]]; then
            if [[ -f "patchSUSYTools.patch" ]]; then
                echo "Patching SUSYTools"
                git apply patchSUSYTools.patch
            else
                echo "Patch file 'patchSUSYTools.patch' not found, cannot patch SUSYTools!"
            fi
        fi
    else
        echo "setup_area    ERROR Did not get ATLAS SW repository (have you forked it yet?)"
        return 1
    fi

    cd $sourcedir

    rmdir="./athena/Projects/"
    if [[ -d $rmdir ]]; then
        cmd="rm -r $rmdir"
        $cmd
    fi

    cd $startdir

}


function get_susynt {

    sc_tag=$1
    sn_tag=$2

    dirname="./source/"
    startdir=${PWD}
    if [[ -d $dirname ]]; then
        cd $dirname
    else
        echo "ERROR get_susynt $dirname directory not found"
        return 1
    fi

    git clone -b master git@github.com:susynt/SusyNtuple.git SusyNtuple  
    git clone -b master git@github.com:susynt/SusyCommon.git SusyCommon

    cd ./SusyNtuple/
    git checkout $sn_tag
    cd -
    cd ./SusyCommon/
    git checkout $sc_tag
    cd -

    cd ${startdir}
}

function main {

    sn_tag=""
    sc_tag=""
    skip_patch=0

    while test $# -gt 0
    do
        case $1 in
            --stable)
                sn_tag="SusyNtuple-00-06-01" # n0234
                sc_tag="SusyCommon-00-05-00" # n0234
                ;;
            --master)
                sn_tag="master"
                sc_tag="master"
                ;;
            --sn)
                sn_tag=${2}
                shift
                ;;
            --sc)
                sc_tag=${2}
                shift
                ;;
            --skip-patch)
                skip_patch=1
                ;;
            -h)
                print_usage
                return 0
                ;;
            --help)
                print_usage
                return 0
                ;;
            *)
                echo "ERROR Invalid argument: $1"
                return 1
                ;;
        esac
        shift
    done

    if [[ $sn_tag == "" ]]; then
        echo "ERROR SusyNtuple tag is not set"
        return 1
    fi
    if [[ $sc_tag == "" ]]; then
        echo "ERROR SusyCommon tag is not set"
        return 1
    fi

    echo "setup_area    Starting -- `date`"

    echo "setup_area    Checking out SusyNtuple tag :   $sn_tag"
    echo "setup_area    Checking out SusyCommon tag :   $sc_tag"

    prepare_directories
    get_externals_git $skip_patch
    get_susynt $sc_tag $sn_tag

    echo "setup_area    Finished -- `date`"
}

main $*
