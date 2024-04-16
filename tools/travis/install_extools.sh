#!/bin/bash

set -euo pipefail

source dependencies.sh

if [ -f "$HOME/.byond/bin/libauxmos.so" ] && grep -Fxq "${AUXMOS_VERSION}" $HOME/.byond/bin/auxmos-version.txt;
then
  echo "Using cached directory."
else
  echo "Installing Auxmos"
  git clone https://github.com/Putnam3145/auxmos
  cd ./auxmos
  rustup target add i686-unknown-linux-gnu
  cargo build --target i686-unknown-linux-gnu --features katmos --release
  chmod 755 ./target/i686-unknown-linux-gnu/release/libauxmos.so
  
  mkdir -p ~/.byond/bin
  cp ./target/i686-unknown-linux-gnu/release/libauxmos.so ~/.byond/bin/libauxmos.so
  echo "$AUXMOS_VERSION" > "$HOME/.byond/bin/auxmos-version.txt"
  ldd ~/.byond/bin/libauxmos.so
  echo "Finished installing Auxmos"
  cd ..
fi
