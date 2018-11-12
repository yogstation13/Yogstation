//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "yogstation\map_files\generic\CentCom.dmm" //all yogstation maps are in the _maps/yogstation folder

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\Deltastation\DeltaStation2.dmm"
		#include "map_files\MetaStation\MetaStation.dmm"
		#include "map_files\PubbyStation\PubbyStation.dmm"
		#include "map_files\BoxStation\BoxStation.dmm"
		#include "yogstation\map_files\YogStation\Yogstation.dmm"
		#include "yogstation\map_files\YogsMeta\YogsMeta.dmm"
<<<<<<< HEAD
		#include "yogstation\map_files\Yogspubby\Yogspubby.dmm"

=======
		#include "yogstation\map_files\YogsPubby\YogsPubby.dmm"
>>>>>>> a24ccc42732e4bde9883734082f247800eb01f8c
		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
