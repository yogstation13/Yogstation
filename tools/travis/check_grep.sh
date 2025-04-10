#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;	then
    echo "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!"
    st=1
fi;
if grep -REl 'list\(.*[^ ]=' --include='*.dmm' _maps; then
    echo "ERROR: Associative list missing leading and trailing space. Update your mapping tool!"
    st=1
fi;
if grep -P '^/[\w/]\S+\(.*(var/|, ?var/.*).*\) code/**/*.dm'; then
    echo "ERROR: changed files contains proc argument starting with 'var'"
    st=1
fi;
if grep -P '^\ttag = \"icon' _maps/**/*.dmm;	then
    echo "ERROR: tag vars from icon state generation detected in maps, please remove them."
    st=1
fi;
if grep -P 'step_[xy]' _maps/**/*.dmm;	then
    echo "ERROR: step_x/step_y variables detected in maps, please remove them."
    st=1
fi;
if grep -P '\td[1-2] =' _maps/**/*.dmm;	then
    echo "ERROR: d1/d2 cable variables detected in maps, please remove them."
    st=1
fi;
if grep -P '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    echo "ERROR: base /turf path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep -P '^/*var/' code/**/*.dm; then
    echo "ERROR: Unmanaged global var use detected in code, please use the helpers."
    st=1
fi;
if grep -i 'centcomm' code/**/*.dm; then
    echo "ERROR: Misspelling(s) of CENTCOM detected in code, please remove the extra M(s)."
    st=1
fi;
if grep -i 'centcomm' _maps/**/*.dmm; then
    echo "ERROR: Misspelling(s) of CENTCOM detected in maps, please remove the extra M(s)."
    st=1
fi;
if grep 'NanoTrasen' code/**/*.dm; then
    echo "ERROR: Misspelling(s) of Nanotrasen detected in code, please uncapitalize the T."
    st=1
fi;
if grep 'NanoTrasen' _maps/**/*.dmm; then
    echo "ERROR: Misspelling(s) of Nanotrasen detected in maps, please uncapitalize the T."
    st=1
fi;
if grep -i 'balloon_alert\(.*?, ?"[A-Z]'; then
	echo
	echo "ERROR: Balloon alerts should not start with capital letters. This includes text like 'AI'. If this is a false positive, wrap the text in UNLINT()."
	st=1
fi;
if grep '\.proc/' code/**/*.dm | grep -v 'code/__byond_version_compat.dm'; then
	echo "ERROR: Direct reference to .proc, use PROC_REF instead"
	st=1
fi;
if ls _maps/*.json | grep -P "[A-Z]"; then
    echo "ERROR: Uppercase in a map json detected, these must be all lowercase."
	st=1
fi;
if grep -P '^/(obj|mob|turf|area|atom)/.+/Initialize\((?!mapload).*\)' code/**/*.dm; then
	echo "ERROR: Initialize override without 'mapload' argument."
	st=1
fi;
if grep -P '^\s*(\w+)\s*=\s*(\1)\b\s*$' code/**/*.dm; then
	echo "ERROR: Variable is assigned to itself"
	st=1
fi;
if grep -P "href[\s='\"\\\\]*\?" code/**/*.dm; then
    echo -e "ERROR: BYOND requires internal href links to begin with \"byond://\"."
    st=1
fi;
for json in _maps/*.json
do
    filename="_maps/$(jq -r '.map_path' $json)/$(jq -r '.map_file' $json)"
    if [ ! -f $filename ]
    then
        echo "found invalid file reference to $filename in _maps/$json"
        st=1
    fi
done

exit $st
