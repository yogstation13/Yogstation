#!/bin/bash
set -euo pipefail

source dependencies.sh

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION
npm install --global yarn

pip3 install --user PyYaml
pip3 install --user beautifulsoup4


if ! hash php 2>/dev/null 
then
	phpenv global $PHP_VERSION
fi