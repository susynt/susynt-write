#!/bin/bash

##########################################################
# setup_release
#
# script to compile the packages picked up by the
# setup_area script
#
# daniel.joseph.antrim@cern.ch
# August 2017
#
##########################################################

default_release="AnalysisBase,21.2.2,here"

function print_usage {
    echo "-------------------------------------------"
    echo "setup_release"
    echo ""
    echo "Options:"
    echo " -r|--release          Set the AnalysisBase release"
    echo "                        > default: $default_release" 
    echo " -c|--compile          Perform full compilation"
    echo "                        > default: false"
    echo " -h|--help             Print this help message"
    echo ""
    echo "Example usage:"
    echo " - First time setup and compilation:" 
    echo "    $ source setup_release --compile"
    echo " - Area is compiled, but starting from new shell:"
    echo "    $ source setup_release"
    echo "-------------------------------------------"
}

function setup_release {
    release=$1

    dirname="./source/"
    startdir=${PWD}
    if [[ -d $dirname ]]; then
        cd $dirname
    else
        echo "ERROR setup_release Directory $dirname not found"
        return 1
    fi

    echo "Setting up release: $release"

    export ATLAS_LOCAL_ROOT_BASE="/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"
    source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
    lsetup "asetup $release"

    cd $startdir
}

function compile_all_the_codes {
    builddir="./build/"
    startidr=${PWD}
    if [[ -d $builddir ]]; then
        echo "WARNING Removing old build directory"
        rm -r $builddir
    fi

    mkdir -p $builddir
    cd $builddir
    echo "setup_release   Calling cmake"
    cmake ../source
    echo "setup_release   Calling make"
    make

    cd $startdir
}


function setup_env {
    builddir="./build"
    startdir=${PWD}
    if [[ -d $builddir ]]; then
        cd $builddir
        founddir=0
        for f in *; do
            if [ $f == *"x86_64"* ]; then
                cd $f
                founddir=1
                if [[ -f "setup.sh" ]]; then
                    source setup.sh
                else
                    echo "WARNING setup.sh file not found in ${PWD}"
                fi
            fi
        done
        if [[ $founddir == 0 ]]; then
            echo "WARNING Did not find x86_64-* directory in $builddir"
        fi
    else
        echo "$builddir directory not found, no AnalysisBase_PLATFORM"
    fi
    cd $startdir
}

function main {

    #release="AnalysisBase,21.2.2,here"
    release=$default_release
    compile=0

    while test $# -gt 0
    do
        case $1 in
            -r)
                release=${2}
                shift
                ;;
            --release)
                release=${2}
                shift
                ;;
            -c)
                compile=1
                ;;
            --compile)
                compile=1
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

    echo "setup_release    Start -- `date`"
    startdir=${PWD}

    setup_release $release
    cd $startdir
    if [[ $compile == 1 ]]; then
        compile_all_the_codes
    fi
    cd $startdir
    setup_env
    cd $startdir

    echo "setup_release    Finished -- `date`"
}

main $*
