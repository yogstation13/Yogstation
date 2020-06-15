/*
Wooden Items as of 15/6/20, from sheet_types.dm there is also the bonfire which is seperate in towercap.dm
ITEMS
"wooden sandals", /obj/item/clothing/shoes/sandal
"wood floor tile", /obj/item/stack/tile/wood
"rifle stock", /obj/item/weaponcrafting/stock
"rolling pin", /obj/item/kitchen/rollingpin
"picture frame", /obj/item/wallframe/picture
"wooden buckler", /obj/item/shield/riot/buckler
"tiki mask", /obj/item/clothing/mask/gas/tiki_mask
"honey frame", /obj/item/honey_frame
"wooden bucket", /obj/item/reagent_containers/glass/bucket/wooden
"rake", /obj/item/cultivator/rake
"mortar", /obj/item/reagent_containers/glass/mortar
"firebrand", /obj/item/match/firebrand
"pestle", /obj/item/pestle

STRUCTURES
"apiary", /obj/structure/beebox
"loom", /obj/structure/loom
"wood table frame", /obj/structure/table_frame/wood
"wooden chair", /obj/structure/chair/wood/
"winged wooden chair", /obj/structure/chair/wood/wings
"wooden barricade", /obj/structure/barricade/wooden
"wooden door", /obj/structure/mineral_door/wood
"coffin", /obj/structure/closet/crate/coffin
"book case", /obj/structure/bookcase
"drying rack", /obj/machinery/smartfridge/drying_rack
"dog bed", /obj/structure/bed/dogbed
"dresser", /obj/structure/dresser
"easel", /obj/structure/easel
"ore box", /obj/structure/ore_box
"wooden crate", /obj/structure/closet/crate/wooden
"pew (middle)", /obj/structure/chair/pew
"pew (left)", /obj/structure/chair/pew/left
"pew (right)", /obj/structure/chair/pew/right
"display case chassis", /obj/structure/displaycase_chassis
*/
#define ASHCAP "/obj/item/stack/sheet/mineral/wood/ash"

/obj/proc/ProcessWoodVarients(list/parts)
	if (istype(parts[1], ASHCAP))//These wooden objects are wood and nothing else, so this should handle wood types easily
		icon_state = ("greyscale_" + icon_state)
		if(isobj(src))
			obj_flags += FIRE_PROOF
			obj_flags += LAVA_PROOF
		else if(isstructure(src))
			//TODO: STRUCTURES DROP THE RIGHT WOOD type
