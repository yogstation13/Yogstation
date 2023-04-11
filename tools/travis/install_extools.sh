#!/bin/bash

set -euo pipefail

echo "Installing Extools dependencies"
mkdir ../extools
cd ../extools
gh repo clone yogstation13/extools
rm -r build
mkdir build
cd build
cmake ../byond-extools
cmake --build .
chmod 755 libbyond-extools.so

mkdir -p ~/.byond/bin
cp libbyond-extools.so ~/.byond/bin/libbyond-extools.so
ldd ~/.byond/bin/libbyond-extools.so
echo "Finished installing Extools"
