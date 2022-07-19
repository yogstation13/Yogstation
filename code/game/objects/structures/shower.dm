#define SHOWER_FREEZING "freezing"
#define SHOWER_NORMAL "normal"
#define SHOWER_BOILING "boiling"

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	use_power = NO_POWER_USE
	var/on = FALSE
	var/current_temperature = SHOWER_NORMAL
	var/datum/looping_sound/showering/soundloop
	var/reagent_id = /datum/reagent/water
	var/reaction_volume = 200

/obj/machinery/shower/Initialize()
	. = ..()
	create_reagents(reaction_volume)
	reagents.add_reagent(reagent_id, reaction_volume)

	soundloop = new(list(src), FALSE)

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(reagents)
	return ..()

/obj/machinery/shower/interact(mob/M)
	on = !on
	update_icon()
	handle_mist()
	add_fingerprint(M)
	if(on)
		START_PROCESSING(SSmachines, src)
		process()
		soundloop.start()
	else
		soundloop.stop()
		if(isopenturf(loc))
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, wet_time_to_add = 1 SECONDS)

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, span_notice("The water temperature seems to be [current_temperature]."))
	else
		return ..()

/obj/machinery/shower/AltClick(mob/living/user)
	..()
	to_chat(user, span_notice("You begin to adjust the temperature..."))
	if(do_after(user, 5 SECONDS, src))
		switch(current_temperature)
			if(SHOWER_NORMAL)
				current_temperature = SHOWER_FREEZING
			if(SHOWER_FREEZING)
				current_temperature = SHOWER_BOILING
			if(SHOWER_BOILING)
				current_temperature = SHOWER_NORMAL
		user.visible_message(span_notice("[user] adjusts the shower."), span_notice("You adjust the shower to [current_temperature] temperature."))
		user.log_message("has adjusted a shower at [AREACOORD(src)] to [current_temperature].", LOG_ATTACK)
		add_fingerprint(user)
	handle_mist()
	return TRUE

/obj/machinery/shower/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>alt-click</b> to change the temperature.")

/obj/machinery/shower/update_icon()
	. = ..()
	cut_overlays()
	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER))

/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, .proc/make_mist), 5 SECONDS)

	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		addtimer(CALLBACK(src, .proc/clear_mist), 25 SECONDS)

/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		new /obj/effect/mist(loc)

/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		qdel(mist)


/obj/machinery/shower/Crossed(atom/movable/AM)
	..()
	if(on)
		wash_atom(AM)

/obj/machinery/shower/proc/wash_atom(atom/A)
	A.wash(CLEAN_RAD | CLEAN_TYPE_WEAK) // Clean radiation non-instantly
	A.wash(CLEAN_WASH)
	SEND_SIGNAL(A, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)
	reagents.reaction(A, TOUCH, reaction_volume)

	if(isliving(A))
		check_heat(A)

/obj/machinery/shower/process()
	if(on)
		wash_atom(loc)
		for(var/am in loc)
			wash_atom(am)
	else
		return PROCESS_KILL

/obj/machinery/shower/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 3)
	qdel(src)

/obj/machinery/shower/proc/check_heat(mob/living/L)
	var/mob/living/carbon/C = L

	if(current_temperature == SHOWER_FREEZING)
		if(iscarbon(L))
			C.adjust_bodytemperature(-80, 80)
		to_chat(L, span_warning("[src] is freezing!"))
	else if(current_temperature == SHOWER_BOILING)
		if(iscarbon(L))
			C.adjust_bodytemperature(35, 0, 500)
		if(!HAS_TRAIT(L, TRAIT_RESISTHEAT))
			L.adjustFireLoss(5)
		to_chat(L, span_danger("[src] is searing!"))
	else
		if(iscarbon(L))
			if(C.bodytemperature < 288) // 15C
				C.adjust_bodytemperature(10)
			if(C.bodytemperature > 298) // 25C
				C.adjust_bodytemperature(-10)

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
