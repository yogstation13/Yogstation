#!/bin/bash
set -e
shopt -s nullglob
cd "$(dirname "$0")"
for f in *.merge; do
	echo Installing merge driver: ${f%.merge}
	git config --replace-all merge.${f%.merge}.driver "tools/hooks/$f %P %O %A %B %L"
done

echo "Installing tgui hooks"
../../tgui/bin/tgui --install-git-hooks

echo "Installing Python dependencies"
./python.sh -m pip install -r ../mapmerge2/requirements.txt
echo "Done"
