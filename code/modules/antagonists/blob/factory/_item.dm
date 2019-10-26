#define FACTORY_BASE 1
#define FACTORY_MILLED 2
#define FACTORY_ASSEMBLED 3
#define FACTORY_FINALIZED 4

/obj/item/factory/base
	name = "unfinished item"
	desc = "A component that has to go through factory machines before being finished."
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	var/item
	var/stage = FACTORY_BASE
	var/createAmount = 1

	//var/ammo_bonus = 0

/obj/item/factory/base/examine(mob/user)
	. = ..()
	switch(stage)
		if(FACTORY_BASE)
			. += "<br><tt>It needs to be milled.</tt>"
		if(FACTORY_MILLED)
			. += "<br><tt>It has been milled, and now needs to be assembled.</tt>"

		if(FACTORY_ASSEMBLED)
			. += "<br><tt>It has been assembled, and now needs to be packed.</tt>"

		if(FACTORY_FINALIZED)
			. += "<br><tt>It has been finished, and you should not be seeing this.</tt>"

/obj/item/factory/base/proc/setStage(newStage)
	switch(newStage)
		if(FACTORY_BASE)
			stage = FACTORY_BASE
			return
		if(FACTORY_MILLED)
			stage = FACTORY_MILLED
			name = "milled item"
			return
		if(FACTORY_ASSEMBLED)
			stage = FACTORY_ASSEMBLED
			name = "assembled item"
			return
		if(FACTORY_FINALIZED)
			stage = FACTORY_FINALIZED
			name = "BUGGED"
			return

/obj/item/factory/base/proc/finalize()
	if(stage != FACTORY_FINALIZED)
		return

	var/turf = get_turf(src)
	for(var/i = 1 to createAmount)
		new item(turf)
	qdel(src)