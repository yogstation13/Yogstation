/datum/guardian_ability/minor/teleport
	name = "Teleportation Pad"
	desc = "The guardian can prepare a teleportation pad, and teleport things to it afterwards."
	cost = 3
	spell_type = /obj/effect/proc_holder/spell/targeted/guardian/teleport

/datum/guardian_ability/minor/teleport/Apply()
	..()
	add_verb(guardian, /mob/living/simple_animal/hostile/guardian/proc/Beacon)

/datum/guardian_ability/minor/teleport/Remove()
	..()
	remove_verb(guardian, /mob/living/simple_animal/hostile/guardian/proc/Beacon)

/obj/effect/proc_holder/spell/targeted/guardian/teleport
	name = "Teleport"
	desc = "Teleport someone to your recieving pad."

/obj/effect/proc_holder/spell/targeted/guardian/teleport/InterceptClickOn(mob/living/caller, params, atom/movable/A)
	if(!istype(A))
		return
	if(!isguardian(caller))
		revert_cast()
		return
	var/mob/living/simple_animal/hostile/guardian/G = caller
	if(!G.is_deployed())
		to_chat(G, span_bolddanger("You must be manifested to warp a target!"))
		return
	if(!G.beacon)
		to_chat(G, span_bolddanger("You need a beacon placed to warp things!"))
		return
	if(!G.Adjacent(A))
		to_chat(G, span_bolddanger("You must be adjacent to your target!"))
		return
	if(A.anchored)
		to_chat(G, span_bolddanger("Your target cannot be anchored!"))
		return

	var/turf/T = get_turf(A)
	if(G.beacon.z != T.z)
		to_chat(G, span_bolddanger("The beacon is too far away to warp to!"))
		return
	remove_ranged_ability()

	to_chat(G, span_bolddanger("You begin to warp [A]."))
	A.visible_message(span_danger("[A] starts to glow faintly!"), span_userdanger("You start to faintly glow, and you feel strangely weightless!"))
	G.do_attack_animation(A)

	if(!do_mob(G, A, 60)) //now start the channel
		to_chat(G, span_bolddanger("You need to hold still!"))
		return

	new /obj/effect/temp_visual/guardian/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message(span_danger("[A] disappears in a flash of light!"), \
	span_userdanger("Your vision is obscured by a flash of light!"))
	do_teleport(A, G.beacon, 0, channel = TELEPORT_CHANNEL_WORMHOLE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(A))

/mob/living/simple_animal/hostile/guardian/proc/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."
	if(beacon_cooldown >= world.time)
		to_chat(src, span_bolddanger("Your power is on cooldown. You must wait five minutes between placing beacons."))
		return
	var/turf/beacon_loc = get_turf(src.loc)
	if(!isfloorturf(beacon_loc))
		return
	if(beacon)
		beacon.disappear()
		beacon = null
	beacon = new(beacon_loc, src)
	to_chat(src, span_bolddanger("Beacon placed! You may now warp targets and objects to it, including your user, via the Teleport ability."))
	beacon_cooldown = world.time + 5 MINUTES


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
	if(G.namedatum)
		add_atom_colour(G.namedatum.colour, FIXED_COLOUR_PRIORITY)

/obj/structure/receiving_pad/proc/disappear()
	visible_message(span_warning("[src] vanishes!"))
	qdel(src)
