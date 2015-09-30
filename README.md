susynt-write
============

Example package to write SusyNt nutples

Prerequisites:
- cvmfs (`echo ${ATLAS_LOCAL_ROOT_BASE}`) and setupATLAS
- svn access and kerberos ticket (`klist`)
- localSetupPandaClient

Follow these commands to set up an area to read SusyNtuples.

```
git clone git@github.com:gerbaudo/susynt-write.git --branch xaod
cd susynt-write
source bash/setup_release.sh
./bash/setup_area.sh [--dev] 2>&1 | tee install.log
rc find_packages
rc compile 2>&1 | tee compile.log
```

The commands above will checkout and compile all the packages that are
necessary to run `NtMaker`. You you can test `NtMaker` as:
```
cd SusyCommon/run
NtMaker -f <xaod_file.root>
```
(see `test_and_log.sh` for recent example input files):

For the submission of your jobs to the grid, see
[susynt-submit](https://github.com/gerbaudo/susynt-submit).

The commands above are needed only on the first setup.
On the following sessions:
```
cd susynt-write
source bash/setup_release.sh
```

Note1: the submission of the jobs must be performed from a
different directory from the one where the packages are compiled.

Note2: if you want to submit a production, you should use the
`--stable` option of `setup_area.sh`.