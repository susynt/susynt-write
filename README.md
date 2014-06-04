susynt-write
============

Example package to write SusyNt nutples

Prerequisites:
- root (`echo ${ROOTSYS}`)
- svn access and kerberos ticket (`klist`)
- localSetupPandaClient

Follow these commands to set up an area to read SusyNtuples.

```
git clone git@github.com:gerbaudo/susynt-write.git
cd susynt-write
bash/setup_area.sh 2>&1 | tee install.log
```

These commands will checkout and compile all the packages
that are necessary to run `NtMaker`. For the submission of
your jobs to the grid, see
[susynt-submit](https://github.com/gerbaudo/susynt-submit).

Note: the submission of the jobs must be performed from a
different directory from the one where the packages are compiled.
