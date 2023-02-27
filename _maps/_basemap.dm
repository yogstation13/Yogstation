//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\mining\Lavaland.dmm"
		#include "map_files\mining\Icemoon.dmm"
		#include "map_files\mining\IcemoonUnderground.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\YogStation\Yogstation.dmm"
		#include "map_files\YogsMeta\YogsMeta.dmm"
		#include "map_files\GaxStation\GaxStation.dmm"
		#include "map_files\AsteroidStation\AsteroidStation.dmm"
		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
