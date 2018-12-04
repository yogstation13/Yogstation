/obj/machinery/disposal_bluespace
	name = "disposal teleporter attachment"
	desc = "A disposals attachment used to teleport from one disposals pipe to another. Can be anchored to disposal pipe trunks."
	icon = 'yogstation/icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "bluespace_attachment"
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	layer = DISPOSAL_PIPE_LAYER + 0.001 // Just slightly higher than a disposal pipe
	density = FALSE
	circuit = /obj/item/circuitboard/machine/disposal_bluespace
	var/obj/machinery/disposal_bluespace/linked
	var/power_efficiency = 1
	var/obj/structure/disposalpipe/trunk/trunk = null

/obj/machinery/disposal_bluespace/Initialize()
	. = ..()
	trunk_check()
	var/turf/T = get_turf(src)
	hide(T && T.intact && !isspaceturf(T))	// space never hides pipes

/obj/machinery/disposal_bluespace/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	power_efficiency = E

/obj/machinery/disposal_bluespace/Destroy()
	. = ..()
	if(trunk && trunk.linked == src)
		trunk.linked = null

/obj/structure/disposalpipe/trunk/Destroy()
	if(linked)
		if(istype(linked, /obj/machinery/disposal_bluespace))
			var/obj/machinery/disposal_bluespace/D = linked
			D.trunk = null
			D.update_icon()
			D.anchored = FALSE
	return ..()

/obj/machinery/disposal_bluespace/wrench_act(mob/user, obj/item/I)
	if(!anchored)
		var/turf/T = get_turf(src)
		if(T.intact && isfloorturf(T))
			to_chat(user, "<span class='warning'>You can only attach [src] if the floor plating is removed!</span>")
			return TRUE
		var/obj/structure/disposalpipe/trunk/trunk_attempt = locate() in loc
		if(!trunk_attempt || trunk_attempt.linked)
			to_chat(user, "<span class='warning'>There is no trunk to attach to!</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You start wrenching [src] in place...</span>")
		I.play_tool_sound(src, 100)
		if(I.use_tool(src, user, 8))
			if(!anchored)
				if(trunk_check(TRUE))
					anchored = TRUE
					to_chat(user, "<span class='notice'>[src] has been wrenched in place.</span>")
				else
					anchored = FALSE
					to_chat(user, "<span class='warning'>You fail to wrench down [src].</span>")
	else
		to_chat(user, "<span class='notice'>You start unwrenching [src]...</span>")
		I.play_tool_sound(src, 100)
		if(I.use_tool(src, user, 12))
			if(anchored)
				anchored = FALSE
				trunk_check()
				to_chat(user, "<span class='notice'>[src] has been unwrenched.</span>")
	return TRUE

/obj/machinery/disposal_bluespace/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "bluespace_attachment-o", "bluespace_attachment", I))
		return

	if(panel_open)
		if(I.tool_behaviour == TOOL_MULTITOOL)
			if(!multitool_check_buffer(user, I))
				return
			var/obj/item/multitool/M = I
			M.buffer = src
			to_chat(user, "<span class='notice'>You save the data in [I]'s buffer. It can now be saved to teleporter attachments with closed panels.</span>")
			return TRUE
	else if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		if(istype(M.buffer, /obj/machinery/disposal_bluespace))
			if(M.buffer == src)
				to_chat(user, "<span class='warning'>You cannot link a teleporter attachment to itself!</span>")
				return TRUE
			else
				linked = M.buffer
				to_chat(user, "<span class='notice'>You link [src] to the one in [I]'s buffer.</span>")
				return TRUE
		else
			to_chat(user, "<span class='warning'>There is no teleporter attachment data saved in [I]'s buffer!</span>")
			return TRUE

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/disposal_bluespace/proc/trunk_check(force_anchored = FALSE)
	if(anchored || force_anchored)
		if(trunk)
			return TRUE
		trunk = locate() in loc
		if(!trunk || trunk.linked)
			if(anchored)
				anchored = FALSE
			update_icon()
			return FALSE
		else
			trunk.linked = src
			update_icon()
			return TRUE
	else
		if(trunk)
			if(trunk.linked == src)
				trunk.linked = null
			trunk = null
			update_icon()
			return FALSE

//a lil' override so we can actually use this
/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)
	var/obj/machinery/disposal_bluespace/B = linked
	if(H.dir == DOWN || !istype(B))
		return ..()
	return B.transfer(H)

/obj/machinery/disposal_bluespace/proc/sparks()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, get_turf(src))
	s.start()

/obj/machinery/disposal_bluespace/proc/transfer(obj/structure/disposalholder/H)
	if(!trunk)
		return null // should never happen
	if(!linked || !linked.trunk || (stat & (NOPOWER|BROKEN)))
		if(prob(50)) // 50/50 chance of expelling or dumping backwards
			return trunk.transfer_to_dir(H, trunk.dir)
		else
			return null
	// alright first we need to use power and raise shit before we teleport our suspicious package into the captain's office
	// Making a disposals loop with this is a great way to waste a shit ton of power.
	use_power(12000 / power_efficiency)
	sparks()
	linked.sparks()

	// a bit of copypaste.... unfortunately, tg coders don't have foresight. like at all.
	// find other holder in next loc, if inactive merge it with current
	var/obj/structure/disposalholder/H2 = locate() in linked.trunk
	if(H2 && !H2.active)
		H.merge(H2)
	H.dir = DOWN
	H.forceMove(linked.trunk)
	return linked.trunk

/obj/machinery/disposal_bluespace/update_icon()
	if(panel_open)
		icon_state = "bluespace_attachment-o"
	else if((stat & (NOPOWER|BROKEN)) || !trunk)
		icon_state = "bluespace_attachment_off"
	else
		icon_state = "bluespace_attachment"

/obj/machinery/disposal_bluespace/power_change()
	..()
	update_icon()

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM: 0	// hide if floor is intact
