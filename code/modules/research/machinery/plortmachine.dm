/**********************Plort Redemption Machine**************************/
//Accepts slime "Cores" as they are definetly NOT called, and turns them into stuff. Probably money? maybe goods? idk im writing this thing before i code it.

/obj/machinery/plortrefinery
	name = "plort redemption machine"
	desc = "A machine that accepts slime cores, and sells them to the highest bidder. This generates research, depending on the rarity."
	icon = 'icons/obj/machines/mining_machines.dmi' // TODO	
	icon_state = "ore_redemption" // TODO
	layer = BELOW_OBJ_LAYER
	density = TRUE
	speed_process = TRUE
	var/research_upgrade = 1
	var/point_gain = 0

/obj/machinery/plortrefinery/accept_check(obj/item/O)
	if(istype(O, /obj/item/slime_extract))
		return TRUE
	else
		return FALSE

/obj/machinery/plortrefinery/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Converting cores at <b>[research_upgrade*100]%</b> their value.<span>"

/obj/machinery/plortrefinery/RefreshParts()
	var/research_upgrade_temp = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		research_upgrade_temp = 1 * M.rating
	research_upgrade = research_upgrade_temp

/obj/machinery/plortrefinery/attackby(obj/item/W, mob/user, params)
	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", W))
		updateUsrDialog()
		return

	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return

	if(istype(O, /obj/item/slime_extract))
		refine_plort(O)
		qdel(O)
		return

/obj/machinery/plortrefinery/proc/refine_plort()
	point_gain = plort_value * research_upgrade
	linked_techweb.add_stored_point_type(TECHWEB_POINT_TYPE_DEFAULT, point_gain)


/obj/machinery/plortrefinery/Initialize()
	. = ..()
	linked_techweb = SSresearch.science_tech
