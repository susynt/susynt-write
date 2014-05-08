susynt-write
============

Example package to write SusyNt nutples

Prerequisites:
- root (`echo ${ROOTSYS}`)
- svn access and kerberos ticket (`klist`)
- localSetupPandaClient

Follow these commands to set up an area to read SusyNtuples.

```
git clone --recursive git@github.com:gerbaudo/susynt-write.git
cd susynt-write
git submodule update --init # only needed if you did not use '--recursive'
bash/setup_area.sh 2>&1 | tee install.log

# todo
# cd subm
# submit.py mc  -t <prod-tag> --met Default -f <a-sample-list.txt> --nickname <my-nickname>
```
