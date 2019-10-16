//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm" 

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\YogStation\Yogstation.dmm"
		#include "map_files\YogsMeta\YogsMeta.dmm"
		#include "map_files\YogsPubby\YogsPubby.dmm"
		#include "map_files\YogsDelta\YogsDelta.dmm"
		#include "map_files\YogsDonut\YogsDonut.dmm"
		#include "map_files\MinskyStation\MinskyStation.dmm"
		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
