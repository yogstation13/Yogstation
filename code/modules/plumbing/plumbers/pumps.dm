/obj/machinery/power/liquid_pump
	name = "liquid pump"
	desc = "Pump up those sweet liquids from under the surface."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	density = TRUE

	idle_power_usage = 10
	active_power_usage = 1000

	var/powered = FALSE
	var/pump_power = 2 //units we pump per process (2 seconds)

	var/obj/structure/geyser/geyser
	var/volume = 200


/obj/machinery/power/liquid_pump/Initialize(mapload)
	create_reagents(volume)
	AddComponent(/datum/component/plumbing/simple_supply)
	return ..()

/obj/machinery/power/liquid_pump/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/power/liquid_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		toggle_active()

/obj/machinery/power/liquid_pump/proc/toggle_active(mob/user, obj/item/I) //we split this in a seperate proc so we can also deactivate if we got no geyser under us
	geyser = null
	if(user)
		user.visible_message(span_notice("[user.name] [anchored ? "fasten" : "unfasten"] [src]"), \
		span_notice("You [anchored ? "fasten" : "unfasten"] [src]"))
	var/datum/component/plumbing/P = GetComponent(/datum/component/plumbing)
	if(anchored)
		P.start()
		connect_to_network()
	else
		P.disable()
		disconnect_from_network()

/obj/machinery/power/liquid_pump/process()
	if(!anchored)
		return
	if(!geyser)
		for(var/obj/structure/geyser/G in loc.contents)
			geyser = G
		if(!geyser) //we didnt find one, abort
			toggle_active()
			anchored = FALSE
			visible_message(span_warning("The [name] makes a sad beep!"))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			return

	if(avail(active_power_usage))
		if(!powered) //we werent powered before this tick so update our sprite
			powered = TRUE
			icon_state = "[initial(icon_state)]-on"
		add_load(active_power_usage)
		pump()
	else if(powered) //we were powered, but now we arent
		powered = FALSE
		icon_state = initial(icon_state)

/obj/machinery/power/liquid_pump/proc/pump()
	if(!geyser || !geyser.reagents)
		return
	geyser.reagents.trans_to(src, pump_power)
