/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter0"
	plane = FLOOR_PLANE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	circuit = /obj/item/circuitboard/machine/igniter
	max_integrity = 300
	armor = list(MELEE = 50, BULLET = 30, LASER = 70, ENERGY = 50, BOMB = 20, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	var/id = null
	var/on = FALSE
	var/safety = FALSE // If is true igniter wont turn on

/obj/machinery/igniter/incinerator_toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/igniter/incinerator_atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/igniter/incinerator_syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/igniter/on
	on = TRUE
	icon_state = "igniter1"

/obj/machinery/igniter/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)

	use_power(50)
	if(!safety)
		on = !(on)
	else
		on = FALSE
	update_icon()

/obj/machinery/igniter/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, O))
		to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance hatch of [src]."))
		return TRUE
	if(default_deconstruction_crowbar(O))
		return TRUE

/obj/machinery/igniter/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='[span_notice("The maintenance panel is [panel_open ? "opened" : "closed"].")]"

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if(safety || panel_open)
		on = FALSE
		update_icon()
		return
	if (src.on && !(stat & NOPOWER))
		var/turf/location = src.loc
		if (isturf(location))
			location.hotspot_expose(1000,500,1)
	return TRUE

/obj/machinery/igniter/Initialize()
	. = ..()
	wires = new /datum/wires/igniter(src)
	icon_state = "igniter[on]"

/obj/machinery/igniter/update_icon()
	if(stat & NOPOWER)
		icon_state = "igniter0"
	else
		icon_state = "igniter[on]"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/datum/effect_system/spark_spread/spark_system

/obj/machinery/sparker/toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/sparker/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)

/obj/machinery/sparker/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/sparker/update_icon()
	if(disable)
		icon_state = "[initial(icon_state)]-d"
	else if(powered())
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]-p"

/obj/machinery/sparker/powered()
	if(disable)
		return FALSE
	return ..()

/obj/machinery/sparker/attackby(obj/item/W, mob/user, params)
	if (W.tool_behaviour == TOOL_SCREWDRIVER)
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message(span_notice("[user] has disabled \the [src]!"), span_notice("You disable the connection to \the [src]."))
		if (!src.disable)
			user.visible_message(span_notice("[user] has reconnected \the [src]!"), span_notice("You fix the connection to \the [src]."))
		update_icon()
	else
		return ..()

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return src.ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[initial(icon_state)]-spark", src)
	spark_system.start()
	last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,2500,1)
	return TRUE

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(stat & (BROKEN|NOPOWER)))
		ignite()
