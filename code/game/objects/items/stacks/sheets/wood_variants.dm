/*
Wooden Items as of 15/6/20, from sheet_types.dm there is also the bonfire which is seperate

"wooden sandals", /obj/item/clothing/shoes/sandal
"wood floor tile", /obj/item/stack/tile/wood
"wood table frame", /obj/structure/table_frame/wood
"rifle stock", /obj/item/weaponcrafting/stock
"rolling pin", /obj/item/kitchen/rollingpin
"wooden chair", /obj/structure/chair/wood/
"winged wooden chair", /obj/structure/chair/wood/wings
"wooden barricade", /obj/structure/barricade/wooden
"wooden door", /obj/structure/mineral_door/wood
"coffin", /obj/structure/closet/crate/coffin
"book case", /obj/structure/bookcase
"drying rack", /obj/machinery/smartfridge/drying_rack
"dog bed", /obj/structure/bed/dogbed
"dresser", /obj/structure/dresser
"picture frame", /obj/item/wallframe/picture
"display case chassis", /obj/structure/displaycase_chassis
"wooden buckler", /obj/item/shield/riot/buckler
"apiary", /obj/structure/beebox
"tiki mask", /obj/item/clothing/mask/gas/tiki_mask
"honey frame", /obj/item/honey_frame
"wooden bucket", /obj/item/reagent_containers/glass/bucket/wooden
"rake", /obj/item/cultivator/rake
"ore box", /obj/structure/ore_box
"wooden crate", /obj/structure/closet/crate/wooden
"loom", /obj/structure/loom
"mortar", /obj/item/reagent_containers/glass/mortar
"firebrand", /obj/item/match/firebrand\
"pestle", /obj/item/pestle
"easel", /obj/structure/easel
"pew (middle)", /obj/structure/chair/pew
"pew (left)", /obj/structure/chair/pew/left
"pew (right)", /obj/structure/chair/pew/right
*/
#define WOOD 1
#define ASHCAP 2

/obj/proc/ProcessWoodVarients(/obj/item/stack/sheet/mineral/wood/wood_type)
	return