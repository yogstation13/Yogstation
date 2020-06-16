#!/bin/bash
set -euo pipefail

tools/deploy.sh travis_test
mkdir travis_test/config

#test config
cp tools/travis/travis_config.txt travis_test/config/config.txt

cd travis_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
strace DreamDaemon yogstation.dmb -close -trusted -verbose -params "test-run&log-directory=travis" 2> strace.log
curl --upload-file strace.log https://transfer.sh/strace.log
cd ..
cat travis_test/data/logs/travis/clean_run.lk
