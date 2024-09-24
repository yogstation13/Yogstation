
/obj/machinery/water_miner
	name = "water harvester"
	desc = "Automatically harvests water from below, filters it, and packs it into easily carriable canisters which are often exported by combine cities."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = 0
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
	if(!user.canUseTopic(src, !issilicon(user)) || mining)
		return
	if(full)
		new	/obj/item/water_canister(src.loc)
		to_chat(user, span_notice("You remove the full water canister."))
		full = FALSE
		update_icon_state()
		return
	if(mining)
		to_chat(user, span_warning("You stop the mining cycle."))
		mining = FALSE
		return
	to_chat(user, span_warning("You start the mining cycle."))
	mining = TRUE
	update_appearance(UPDATE_ICON)

	START_PROCESSING(SSfastprocess, src)

/obj/machinery/water_miner/process(delta_time)
	if(!mining)
		return PROCESS_KILL
	if(anchored)
		water_gather_progress++
		if(water_gather_progress > 499)
			water_gather_progress = 0
			full = TRUE
			mining = FALSE
			update_icon_state()
			return PROCESS_KILL
	else
		mining = FALSE
	return


/obj/machinery/water_miner/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && I.use_tool(src, user, 20, volume=50))
		if(!anchored)
			if(istype(loc, /turf/open/halflife/water))
				anchored = 1
				user.visible_message( \
					"[user] sets \the [src] down into the water.", \
					span_notice("You burrow \the [src] into the water."),
					span_italics("You hear the splash of water."))
			else
				to_chat(user, span_warning("This needs to be anchored over a source of water!"))
		else
			anchored = 0
			user.visible_message( \
				"[user] raises \the [src] from the water.", \
				span_notice("You raise \the [src] out from the water."),
				span_italics("You hear something rising from the water."))

/obj/machinery/water_miner/update_icon_state()
	. = ..()
	if(!full)
		icon_state = "biogen-empty"
	else
		icon_state = "biogen-stand"

/obj/item/water_canister
	name = "water canister"
	desc = "A reinforced canister containing filtered water. This can be sold to the benefactors via the dropship."
	icon_state = "oxygen"
	force = 10
	icon = 'yogstation/icons/obj/tank.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	hitsound = 'sound/weapons/smash.ogg'
	pickup_sound = 'sound/items/gas_tank_pick_up.ogg'
	drop_sound = 'sound/items/gas_tank_drop.ogg'
	sound_vary = TRUE
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
