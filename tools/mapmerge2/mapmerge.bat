@echo off
set MAPROOT=../../_maps/
set TGM=1
python -m pip install bidict
python mapmerge.py
pause
