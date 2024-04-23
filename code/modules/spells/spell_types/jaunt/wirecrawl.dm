/**
 * ### Blood Crawl
 *
 * Lets the caster enter and exit pools of blood.
 */
/datum/action/cooldown/spell/jaunt/wirecrawl
	name = "Wire Crawl"
	desc = "Allows you to break your body down into electricity and travel through wires."

	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "electricity2"

	spell_requirements = NONE
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

	/// The time it takes to enter blood
	var/enter_blood_time = 3 SECONDS
	/// The time it takes to exit blood
	var/exit_blood_time = 0 SECONDS
	/// The radius around us that we look for wires in
	var/enter_radius = 1
	/// If TRUE, we equip "wire crawl" hands to the jaunter to prevent using items
	var/equip_wire_hands = TRUE
	
	jaunt_type = /obj/effect/dummy/phased_mob/wirecrawl

/datum/action/cooldown/spell/jaunt/wirecrawl/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/wirecrawl/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/jaunt/wirecrawl/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(find_nearby_power(get_turf(owner)))
		return TRUE
	if(feedback)
		to_chat(owner, span_warning("There must be a nearby power outlet!"))
	return FALSE

/datum/action/cooldown/spell/jaunt/wirecrawl/cast(mob/living/cast_on)
	. = ..()
	// Should always return something because we checked that in can_cast_spell before arriving here
	var/obj/structure/cable/wire = find_nearby_power(get_turf(cast_on))
	do_wirecrawl(wire, cast_on)

/// Returns a nearby blood decal, or null if there aren't any
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/find_nearby_power(turf/origin)
	for(var/obj/machinery/power/power in range(enter_radius, origin))
		for(var/obj/structure/cable/cable in range(0 , power))//try to find a cable directly under a power thing first
			return cable
	for(var/obj/structure/cable/cable in range(enter_radius, origin))
		if(!cable.invisibility)//otherwise, find a cable that isn't covered
			return cable
	return null

/**
 * Attempts to enter or exit the passed blood pool.
 * Returns TRUE if we successfully entered or exited said pool, FALSE otherwise
 */
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/do_wirecrawl(obj/structure/cable/wire, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(wire, jaunter)
	else
		. = try_enter_jaunt(wire, jaunter)

	if(!.)
		reset_spell_cooldown()
		to_chat(jaunter, span_warning("You are unable to wire crawl!"))

/**
 * Attempts to enter the passed blood pool.
 * If forced is TRUE, it will override enter_blood_time.
 */
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/try_enter_jaunt(obj/structure/cable/wire, mob/living/jaunter, forced = FALSE)
	if(!forced)
		if(enter_blood_time > 0 SECONDS)
			do_sparks(5, FALSE, jaunter)
			wire.visible_message(span_warning("[jaunter] starts to sink into [wire]!"))
			if(!do_after(jaunter, enter_blood_time, wire))
				return FALSE

	// The actual turf we enter
	var/turf/jaunt_turf = get_turf(wire)

	// Begin the jaunt
	jaunter.notransform = TRUE
	var/obj/effect/dummy/phased_mob/wirecrawl/holder = enter_jaunt(jaunter, jaunt_turf)
	if(!holder)
		jaunter.notransform = FALSE
		return FALSE

	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))
	if(equip_wire_hands && iscarbon(jaunter))
		jaunter.drop_all_held_items()
		// Give them some bloody hands to prevent them from doing things
		var/obj/item/wirecrawl/left_hand = new(jaunter)
		var/obj/item/wirecrawl/right_hand = new(jaunter)
		jaunter.put_in_hands(left_hand)
		jaunter.put_in_hands(right_hand)

	wire.visible_message(span_warning("[jaunter] zips into [wire]!"))
	jaunter.extinguish_mob()

	jaunter.add_wirevision(wire)
	holder.travelled = wire.powernet
	do_sparks(10, FALSE, jaunter)

	jaunter.notransform = FALSE
	return TRUE

/**
 * Attempts to Exit the passed blood pool.
 * If forced is TRUE, it will override exit_blood_time, and if we're currently consuming someone.
 */
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/try_exit_jaunt(obj/structure/cable/wire, mob/living/jaunter, forced = FALSE)
	if(!forced)
		if(jaunter.notransform)
			to_chat(jaunter, span_warning("You cannot exit yet!!"))
			return FALSE

		if(exit_blood_time > 0 SECONDS)
			wire.visible_message(span_warning("[wire] starts to crackle..."))
			do_sparks(5, FALSE, jaunter)
			if(!do_after(jaunter, exit_blood_time, wire))
				return FALSE

	if(!exit_jaunt(jaunter, get_turf(wire)))
		return FALSE

	jaunter.remove_wirevision()
	do_sparks(10, FALSE, jaunter)

	wire.visible_message(span_boldwarning("[jaunter] zips out of [wire]!"))
	return TRUE

/datum/action/cooldown/spell/jaunt/wirecrawl/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	if(equip_wire_hands && iscarbon(unjaunter))
		for(var/obj/item/wirecrawl/wire_hand in unjaunter.held_items)
			unjaunter.temporarilyRemoveItemFromInventory(wire_hand, force = TRUE)
			qdel(wire_hand)
	return ..()

/obj/effect/dummy/phased_mob/wirecrawl
	name = "wire"
	///keep track of the powernet we're in
	var/datum/powernet/travelled

/obj/effect/dummy/phased_mob/wirecrawl/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	
/obj/effect/dummy/phased_mob/wirecrawl/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/dummy/phased_mob/wirecrawl/phased_check(mob/living/user, direction)
	var/turf/oldloc = get_turf(user)
	var/obj/structure/cable/current = locate() in oldloc
	if(!current || !istype(current) || !travelled)//if someone snips the wire you're currently in, or it gets destroyed in some way, get out
		eject_jaunter()
		return

	var/turf/newloc = ..()
	for(var/obj/structure/cable/wire in newloc)
		if(travelled != wire.powernet) //no jumping to a different powernet
			continue
		user.update_wire_vision(wire)
		new /obj/effect/particle_effect/sparks/electricity/short(get_turf(user))
		return newloc

/obj/effect/dummy/phased_mob/wirecrawl/process(delta_time)//so if the existing wire is destroyed, they are forced out
	. = ..()
	var/turf/currentloc = get_turf(jaunter)
	var/obj/structure/cable/current = locate() in currentloc
	if(!current || !istype(current) || !travelled)//if someone snips the wire you're currently in, or it gets destroyed in some way, get out
		eject_jaunter()
		return

/obj/effect/dummy/phased_mob/wirecrawl/eject_jaunter()
	var/mob/living/ejected = jaunter
	ejected.remove_wirevision()
	. = ..()

//vision
/mob/living/proc/update_wire_vision(var/obj/structure/cable/wire)
	if(!istype(src.loc, /obj/effect/dummy/phased_mob/wirecrawl))//only get wirevision if phased
		return
	if(!wire) //if there's no wire, grab a random one in the location
		wire = locate() in get_turf(src)
	remove_wirevision()
	if(!wire) //if there's STILL no wire, just give up
		return
	add_wirevision(wire)

/mob/living/proc/add_wirevision(obj/structure/cable/wire)
	if(!wire || !istype(wire) || !wire.powernet)
		return
	var/list/totalMembers = list()

	var/datum/powernet/P = wire.powernet
	if(P)
		totalMembers += P.nodes
		totalMembers += P.cables

	if(!totalMembers.len)
		return
		
	sight |= (SEE_TURFS|BLIND)

	if(client)
		for(var/object in totalMembers)//cables and power machinery are not the same unfortunately
			if(in_view_range(client.mob, object))
				if(istype(object, /obj/structure/cable))
					var/obj/structure/cable/display = object
					if(!display.wire_vision_img)
						var/turf/their_turf = get_turf(display)
						display.wire_vision_img = image(display, display.loc, dir = display.dir)
						SET_PLANE(display.wire_vision_img, ABOVE_HUD_PLANE, their_turf)
					client.images += display.wire_vision_img
					wires_shown += display.wire_vision_img
				
				else if(istype(object, /obj/machinery/power))
					var/obj/machinery/power/display = object
					if(!display.wire_vision_img)
						var/turf/their_turf = get_turf(display)
						display.wire_vision_img = image(display, display.loc, dir = display.dir)
						SET_PLANE(display.wire_vision_img, ABOVE_HUD_PLANE, their_turf)
					client.images += display.wire_vision_img
					wires_shown += display.wire_vision_img

/mob/living/proc/remove_wirevision()
	if(client)
		for(var/image/current_image in wires_shown)
			client.images -= current_image
		wires_shown.len = 0
	sight &= ~(SEE_TURFS|BLIND)


/obj/item/wirecrawl
	name = "wire crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	item_flags = ABSTRACT | DROPDEL

/obj/item/wirecrawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

