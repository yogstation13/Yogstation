/*
Wooden Items as of 15/6/20, from sheet_types.dm there is also the bonfire which is seperate in towercap.dm
X = Item is fully functional with the system
- = Item is not craftable (currently) with alt woods

ITEMS
"wooden sandals", /obj/item/clothing/shoes/sandal X
"wood floor tile", /obj/item/stack/tile/wood
"rifle stock", /obj/item/weaponcrafting/stock -
"rolling pin", /obj/item/kitchen/rollingpin X
"picture frame", /obj/item/wallframe/picture -
"wooden buckler", /obj/item/shield/riot/buckler X
"tiki mask", /obj/item/clothing/mask/gas/tiki_mask -
"honey frame", /obj/item/honey_frame -
"wooden bucket", /obj/item/reagent_containers/glass/bucket/wooden X
"rake", /obj/item/cultivator/rake X
"mortar", /obj/item/reagent_containers/glass/mortar X
"firebrand", /obj/item/match/firebrand -
"pestle", /obj/item/pestle X

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
		resistance_flags += FIRE_PROOF
		resistance_flags += LAVA_PROOF
		resistance_flags -= FLAMMABLE
		if(isstructure(src))
			var/obj/structure/W = src
			W.woodtype = ASHCAP

