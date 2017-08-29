susynt-write
============

# Contents

* [Introduction](#introduction)
* [Requirements](#requirements)
* [Actions](#actions)
  * [First Time Setup](#first-time-setup)
  * [Subsequent Area Setup](#subsequent-area-setup)
  * [Subsequent Compilation](#subsequent-compilation)
  * [Compiling after Changes to CMakeLists](#compiling-after-changes-to-cmakelists)


## Introduction
This package contains several scripts that can be used to setup an area to run the necessary software to process DAOD files to produce susyNt files. It checks out **SusyNtuple**, **SusyCommon**, and **SUSYTools**, as well as any other packages required (typically those specified in *SUSYTools/doc/packages.txt*).

## Requirements
The assumption is that the checked out software will be run on a machine with access to **cvmfs**. We need **cvmfs** in order to check out a specific **AnalysisBase** release to gain access to all of the core xAOD and ASG tools. You need:

1) access to **cvmfs** (be on a machine with cvmfs)
2) kerberos tickets (run: ```kinit -f ${USER}@CERN.CH```)

## Actions

### First Time Setup
Here are the steps to setup an area from scratch.

```
git clone -b <tag> git@github.com:susynt/susynt-write.git
cd susynt-write/
source bash/setup_area.sh --stable
source bash/setup_release.sh --compile
```

The script *bash/setup_area.sh* call in the above code snippet will checkout the "stable" release given by the tag ```<tag>```.  This means that it will checkout the associated tags of **SusyNtuple** and **SusyCommon** (i.e. those tags of these packages that were used to build susyNt tag ```<tag>```). You can use the ```-h``` or ```--help``` option to see the full list of options:

```
source bash/setup_area.sh --help
```

You will see that you can give the ```--sc``` or ```--sn``` option to specify specific tags of **SusyCommon** or **SusyNtuple**, respectively.

The script *bash/setup_release.sh* sets up the associated **AnalysisBase** release. When given the ```--compile``` flag it will also run the full compilation of the packages checked out by the *bash/setup_area.sh* script (the packages which should now live under the *susynt-write/source/* directory). You can use the ```-h``` or ```--help``` option to see the full list of options:

```
source bash/setup_release.sh --help
```

After running *bash/setup_release.sh* with the ```--compile``` flag you will see the *susynt-write/build/* directory which contains the typical ```CMake```-like build directory structure. In order to allow all of the executables be in the user's path, the *bash/setup_release.sh* script sources the *setup.sh* script located in *susynt-write/build/x86_64-\*/* directory.

### Subsequent Area Setup
If you are returning to your *susynt-write* directory from a new shell and you have previously compiled all of the software, you need to still setup the environment so that all of the executables, librarires, etc... can be found. You can do this simpy by calling the *bash/setup_release.sh* script with no arguments:

```
source bash/setup_release.sh
```

This sources the *setup.sh* script located in *susynt-write/build/x86_64-\*/* directory. 

### Subsequent Compilation
You can either call:

```
source bash/setup_release.sh --compile
```

every time you wish to compile. But this runs the *cmake* command to initiate the ```CMake``` configuration steps. This also removes the previous *build/* directory and starts a new one.

The simpler and faster way (and therefore recommended way) is to move to the *build/* directory and simply call ```make```:

```
cd build/
make
```

### Compiling after Changes to CMakeLists

If you change any of the ```CMakeLists.txt``` files in any of the packages in *susynt/source/* directory, you need to re-run the ```CMake``` configuration. You can do this simply by running:

```
source bash/setup_release.sh --compile
```

or, if you do not want to completely remove the previous *build/* directory (and are sure that your changes are OK for this) you can simply do:

```
cd build/
cmake ../source
make
```
