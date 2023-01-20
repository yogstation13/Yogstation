## MAPS

Yogstation currently comes equipped with the following maps.

* [BoxStation (default)](https://wiki.yogstation.net/wiki/BoxStation)
* [DeltaStation](https://wiki.yogstation.net/wiki/DeltaStation)
* [EclipseStation](https://wiki.yogstation.net/wiki/Maps)
* [MetaStation](https://wiki.yogstation.net/wiki/MetaStation)
* [OmegaStation](https://wiki.yogstation.net/wiki/OmegaStation)

All maps have their own code file that is in the base of the _maps directory. Maps are loaded dynamically when the game starts. Follow this guideline when adding your own map, to your fork, for easy compatibility.

The map that will be loaded for the upcoming round is determined by reading data/next_map.json, which is a copy of the json files found in the _maps tree. If this file does not exist, the default map from config/maps.txt will be loaded. Failing that, BoxStation will be loaded. If you want to set a specific map to load next round you can use the Change Map verb in game before restarting the server or copy a json from _maps to data/next_map.json before starting the server. Also, for debugging purposes, ticking a corresponding map's code file in Dream Maker will force that map to load every round.

If you are hosting a server, and want randomly picked maps to be played each round, you can enable map rotation in [config.txt](config/config.txt) and then set the maps to be picked in the [maps.txt](config/maps.txt) file.

Anytime you want to make changes to a map it's imperative you use the [Map Merging tools](https://tgstation13.org/wiki/Map_Merger)

## EDITING MAPS

### [Click here for a Quick-Start Guide To Mapping.](https://hackmd.io/@tgstation/SyVma0dS5)

<b>It is absolutely inadvisable to <i>ever</i> use the mapping utility offered by Dream Maker</b>. It is clunky and dated software that will steal your time, patience, and creative desires.

Instead, Yogstation map maintainers will always recommend using one of two modern and actively maintained programs.
* [StrongDMM](https://github.com/SpaiR/StrongDMM) (Windows/Linux/MacOS)
* [FastDMM2](https://github.com/monster860/FastDMM2) (Web-based Utility)

Both of the above programs have native TGM support, which is mandatory for all maps being submitted to this repository. Anytime you want to make changes to a map, it is imperative you use the [Map Merging tools](https://tgstation13.org/wiki/Map_Merger). When you clone your repository onto your machine for mapping, it's always a great idea to run `tools/hooks/Install.bat` at the very start of your mapping endeavors, as this will install Git hooks that help you automatically resolve any merge conflicts that come up while mapping.

## AWAY MISSIONS

Yogstation supports loading away missions however they are disabled by default.

Map files for away missions are located in the _maps/RandomZLevels directory. Each away mission includes it's own code definitions located in /code/modules/awaymissions/mission_code. These files must be included and compiled with the server beforehand otherwise the server will crash upon trying to load away missions that lack their code.

To enable an away mission open `config/awaymissionconfig.txt` and uncomment one of the .dmm lines by removing the #. If more than one away mission is uncommented then the away mission loader will randomly select one the enabled ones to load.
