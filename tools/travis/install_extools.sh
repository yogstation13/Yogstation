#!/bin/bash

set -euo pipefail

echo "Installing Auxmos"
git clone https://github.com/Putnam3145/auxmos
cd ../auxmos
rustup target add i686-unknown-linux-gnu
cargo build --target i686-unknown-linux-gnu --features katmos --release
chmod 755 target/i686-unknown-linux-gnu/release/libauxmos.so


mkdir -p ~/.byond/bin
cp target/i686-unknown-linux-gnu/release/libauxmos.so ~/.byond/bin/libauxmos.so
ldd ~/.byond/bin/libauxmos.so
echo "Finished installing Auxmos"
