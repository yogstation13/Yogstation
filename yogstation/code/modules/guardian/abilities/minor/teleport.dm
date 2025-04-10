/datum/guardian_ability/minor/teleport
	name = "Teleportation Pad"
	desc = "The guardian can prepare a teleportation pad, and teleport things to it afterwards."
	cost = 3
	spell_type = /datum/action/cooldown/spell/pointed/guardian/teleport
	action_types = list(/datum/action/guardian/place_beacon)
	var/obj/structure/receiving_pad/beacon

/datum/action/cooldown/spell/pointed/guardian/teleport
	name = "Teleport"
	desc = "Teleport someone to your recieving pad."

/datum/action/cooldown/spell/pointed/guardian/teleport/InterceptClickOn(mob/living/caller_but_not_a_byond_built_in_proc, params, atom/movable/target)
	. = ..()
	if(!.)
		return FALSE
	if (!istype(target))
		return
	if (!isguardian(caller_but_not_a_byond_built_in_proc))
		return
	var/mob/living/simple_animal/hostile/guardian/guardian = caller_but_not_a_byond_built_in_proc
	var/datum/guardian_ability/minor/teleport/ability = guardian.has_ability(/datum/guardian_ability/minor/teleport)
	if (!guardian.is_deployed())
		to_chat(guardian, span_bolddanger("You must be manifested to warp a target!"))
		return
	if (!ability.beacon)
		to_chat(guardian, span_bolddanger("You need a beacon placed to warp things!"))
		return
	if (!guardian.Adjacent(target))
		to_chat(guardian, span_bolddanger("You must be adjacent to your target!"))
		return
	if (target.anchored)
		to_chat(guardian, span_bolddanger("Your target cannot be anchored!"))
		return

	var/turf/target_turf = get_turf(target)
	if(ability.beacon.z != target_turf.z)
		to_chat(guardian, span_bolddanger("The beacon is too far away to warp to!"))
		return

	to_chat(guardian, span_bolddanger("You begin to warp [target]."))
	target.visible_message(span_danger("[target] starts to glow faintly!"), span_userdanger("You start to faintly glow, and you feel strangely weightless!"))
	guardian.do_attack_animation(target)

	if(!do_after(guardian, 5 SECONDS, target)) //now start the channel
		to_chat(guardian, span_bolddanger("You need to hold still!"))
		return

	new /obj/effect/temp_visual/guardian/phase/out(target_turf)
	if(isliving(target))
		var/mob/living/L = target
		L.flash_act()
	target.visible_message(span_danger("[target] disappears in a flash of light!"), \
		span_userdanger("Your vision is obscured by a flash of light!"))
	do_teleport(target, ability.beacon, 0, channel = TELEPORT_CHANNEL_WORMHOLE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(target))

/datum/action/guardian/place_beacon
	name = "Place Bluespace Beacon"
	desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."
	button_icon_state = "omae_wa_shinderu"

/datum/action/guardian/place_beacon/on_use(mob/living/simple_animal/hostile/guardian/user)
	var/turf/beacon_loc = get_turf(user)
	if (!isfloorturf(beacon_loc))
		return
	var/datum/guardian_ability/minor/teleport/ability = user.has_ability(/datum/guardian_ability/minor/teleport)
	if (ability.beacon)
		ability.beacon.disappear()
		ability.beacon = null
	ability.beacon = new(beacon_loc, user)
	to_chat(user, span_bolddanger("Beacon placed! You may now warp targets and objects to it, including your user, via the Teleport ability."))

// the pad
/obj/structure/receiving_pad
	name = "bluespace receiving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A receiving zone for bluespace teleportations."
	icon_state = "light_on-w"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/receiving_pad/New(loc, mob/living/simple_animal/hostile/guardian/G)
	. = ..()
	if (G.namedatum)
		add_atom_colour(G.namedatum.color, FIXED_COLOUR_PRIORITY)

/obj/structure/receiving_pad/proc/disappear()
	visible_message(span_warning("[src] vanishes!"))
	qdel(src)
