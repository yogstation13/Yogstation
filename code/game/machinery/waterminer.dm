/*
/obj/machinery/water_miner
	name = "water harvester"
	desc = "Automatically harvests water from below, purifies it, and packs it into easily carriable canisters which are often exported by combine cities."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen_empty"
	density = TRUE
	var/full = FALSE
	var/mining = FALSE
	var/water_gather_progress = FALSE

/obj/machinery/water_miner/examine(mob/user)
	. = ..()
	if(full)
		. += span_notice("<b>Alt-click</b> it to remove the full water canister.")
	else if (!mining)
		. += span_notice("<b>Alt-click</b> it to start a harvesting cycle.")

/obj/machinery/water_miner/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || busy)
		return
	if(full)
		to_chat(user, span_notice("You remove the full water canister."))
		return
	if(mining)
		to_chat(user, span_warning("You stop the mining cycle."))
		mining = FALSE
		return
	to_chat(user, span_warning("You start the mining cycle."))
	mining = TRUE
	update_appearance(UPDATE_ICON)
	addtimer(CALLBACK(src, PROC_REF(wash_cycle)), 200)

	START_PROCESSING(SSfastprocess, src)

/obj/machinery/water_miner/process(delta_time)
	if(!busy)
		animate(src, transform=matrix(), time=0.2 SECONDS)
		return PROCESS_KILL
	if(anchored)
		water_gather_progress++
	return
*/
