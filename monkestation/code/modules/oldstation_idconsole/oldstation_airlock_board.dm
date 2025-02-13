/obj/item/electronics/airlock/old //subtype of airlock electronics for charlie station, useful if you want to make locked doors or lockers
	name = "ancient airlock electronics"
	desc = "Looks like a circuit. Probably is. Looks odd." //that isnt a misspell of old

/obj/item/electronics/airlock/old/ui_static_data(mob/user)
	var/list/data = list()

	var/list/regions = list()
	var/list/tgui_region_data = SSid_access.all_region_access_tgui
	for(var/region in SSid_access.station_regions)
		regions += tgui_region_data[region]

	regions += tgui_region_data[REGION_CHARLIE_STATION] //im not removing other regions because i dont want this to be a downgrade

	data["regions"] = regions
	return data

/datum/design/airlock_board_offstation
	name = "Ancient Airlock Electronics"
	id = "airlock_board_offstation"
	build_type = AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass =SMALL_MATERIAL_AMOUNT*0.5)
	build_path = /obj/item/electronics/airlock/old
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
