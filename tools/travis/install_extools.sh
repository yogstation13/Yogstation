#!/bin/bash

set -euo pipefail

echo "Installing Extools dependencies"
dpkg --add-architecture i386
apt-get update
apt-get install -y 		\
	libmariadb-dev:i386	\
	libssl1.1:i386 		\
	libssl-dev:i386		\
	pkg-config:i386 	\
	zlib1g:i386 		\
	zlib1g-dev:i386 	\
	python 			\
	libstdc++6 		\
	libstdc++6:i386 	\
	git 			\
	cmake 			\
	g++ 			\
	g++-multilib
	
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