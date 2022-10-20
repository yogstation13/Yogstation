/**********************Plort Redemption Machine**************************/
//Accepts slime "Cores" as they are definetly NOT called, and turns them into stuff. Probably money? maybe goods? idk im writing this thing before i code it.

/obj/machinery/plortrefinery
	name = "plort redemption machine"
	desc = "A machine that accepts slime cores, and sells them to the highest bidder. This generates money and research, depending on the rarity."
	icon = 'icons/obj/machines/mining_machines.dmi' // TODO	
	icon_state = "ore_redemption" // TODO
	layer = BELOW_OBJ_LAYER
	density = TRUE
	speed_process = TRUE
	var/list/plort_values = list(/obj/item/slime_extract/grey = 1,/obj/item/slime_extract/gold = 1, /obj/item/slime_extract/silver = 1, /obj/item/slime_extract/metal = 1, /obj/item/slime_extract/purple = 1, /obj/item/slime_extract/darkpurple = 1, /obj/item/slime_extract/orange = 1, /obj/item/slime_extract/yellow = 1, /obj/item/slime_extract/red = 1, /obj/item/slime_extract/blue = 1, /obj/item/slime_extract/darkblue = 1, /obj/item/slime_extract/pink = 1, /obj/item/slime_extract/green = 1, /obj/item/slime_extract/lightpink = 1, /obj/item/slime_extract/black = 1, /obj/item/slime_extract/oil = 1, /obj/item/slime_extract/adamantine = 1, /obj/item/slime_extract/bluespace = 1, /obj/item/slime_extract/pyrite = 1, /obj/item/slime_extract/cerulean = 1, /obj/item/slime_extract/sepia = 1, /obj/item/slime_extract/rainbow = 1)
	var/research_points = 0
	var/value_points = 0
	var/point_upgrade = 1
	var/research_upgrade = 1
	var/point_gain = 0

/obj/machinery/plortrefinery/accept_check(obj/item/O)
	if(istype(O, /obj/item/slime_extract))
		return TRUE
	else
		return FALSE

/obj/machinery/plortrefinery/RefreshParts()
	var/research_upgrade_temp = 1
	var/point_upgrade_temp = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		plort_pickup_rate_temp = 15 * M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		point_upgrade_temp = 0.65 + (0.35 * L.rating)
	plort_pickup_rate = plort_pickup_rate_temp
	point_upgrade = point_upgrade_temp



point_gain = 









	linked_techweb.add_stored_point_type(TECHWEB_POINT_TYPE_DEFAULT, point_gain)






/obj/machinery/doppler_array/research/science/Initialize()
	. = ..()
	linked_techweb = SSresearch.science_tech

