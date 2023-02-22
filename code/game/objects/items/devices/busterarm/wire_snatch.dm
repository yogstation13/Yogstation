/* Formatting for these files, from top to bottom:
	* Spell/Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to spells or items with left and right subtypes, list the base, then left, then right.
*/
////////////////// Spell //////////////////
/datum/action/cooldown/buster/wire_snatch
	name = "Wire Snatch"
	desc = "Extend a wire for reeling in foes from a distance. Reeled in targets will be unable to walk for 1.5 seconds. \
			Anchored targets that are hit will pull you towards them instead. \
			It can be used 3 times before reeling back into the arm."
	icon_icon = 'icons/obj/guns/magic.dmi'
	button_icon_state = "hook"
	cooldown_time = 5 SECONDS

/// Left buster-arm means wire goes in right hand
/datum/action/cooldown/buster/wire_snatch/l/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/obj/item/gun/magic/wire/T = new()
	for(var/obj/item/gun/magic/wire/J in owner)
		qdel(J)
		to_chat(owner, span_notice("The wire returns into your wrist."))
		return
	if(!owner.put_in_r_hand(T))
		to_chat(owner, span_warning("You can't do this with your right hand full!"))
	else
		if(owner.active_hand_index % 2 == 1)
			owner.swap_hand(0) //making the grappling hook hand (right) the active one so using it is streamlined

/// Right buster-arm means wire goes in left hand
/datum/action/cooldown/buster/wire_snatch/r/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/obj/item/gun/magic/wire/T = new()
	for(var/obj/item/gun/magic/wire/J in owner)
		qdel(J)
		to_chat(owner, span_notice("The wire returns into your wrist."))
		return
	if(!owner.put_in_l_hand(T))
		to_chat(owner, span_warning("You can't do this with your right hand full!"))
	else
		if(owner.active_hand_index % 2 == 0)
			owner.swap_hand(0) //making the grappling hook hand (right) the active one so using it is streamlined

/datum/action/cooldown/buster/wire_snatch/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/wire_snatch/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

////////////////// Wire Gun Item //////////////////
/obj/item/gun/magic/wire
	name = "grappling wire"
	desc = "A combat-ready cable usable for closing the distance, bringing you to walls and heavy targets you hit or bringing lighter ones to you."
	ammo_type = /obj/item/ammo_casing/magic/wire
	icon_state = "hook"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 3
	item_flags = NEEDS_PERMIT | DROPDEL
	force = 0
	can_charge = FALSE

/obj/item/gun/magic/wire/Initialize()
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)
	if(ismob(loc))
		loc.visible_message(span_warning("A long cable comes out from [loc.name]'s arm!"), span_warning("You extend the breaker's wire from your arm."))

/// Deletes the wire once it has no more shots left
/obj/item/gun/magic/wire/process_chamber()
	. = ..()
	if(!charges)
		qdel(src)

/// Ammo Casing
/obj/item/ammo_casing/magic/wire
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/item/projectile/wire
	caliber = "hook"
	icon_state = "hook"

/// Projectile
/obj/item/projectile/wire
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 0
	armour_penetration = 100
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/effects/splat.ogg'
	knockdown = 0
	var/wire

/obj/item/projectile/wire/fire(setAngle)
	if(firer)
		wire = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()

/// Helper proc exclusively used for pulling the buster arm USER towards something anchored
/obj/item/projectile/wire/proc/zip(mob/living/user, turf/open/target)
	to_chat(user, span_warning("You pull yourself towards [target]."))
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.Immobilize(0.2 SECONDS)//so it's not cut short by walking
	user.throw_at(get_step_towards(target,user), 8, 4)

/obj/item/projectile/wire/on_hit(atom/target)
	var/mob/living/carbon/human/H = firer
	if(!H)
		return
	if(isobj(target)) // If it's an object
		var/obj/item/I = target
		if(!I?.anchored) // Give it to us if it's not anchored
			I.throw_at(get_step_towards(H,I), 8, 2)
			H.visible_message(span_danger("[I] is pulled by [H]'s wire!"))
			if(istype(I, /obj/item/clothing/head))
				H.equip_to_slot_if_possible(I, SLOT_HEAD)
				H.visible_message(span_danger("[H] pulls [I] onto [H.p_their()] head!"))
			else
				H.put_in_hands(I)
			return
		zip(H, target) // Pull us towards it if it's anchored
	if(isliving(target)) // If it's somebody
		var/mob/living/L = target
		var/turf/T = get_step(get_turf(H), H.dir)
		var/turf/Q = get_turf(H)
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(H.zone_selected)
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		if(!L.anchored) // Only pull them if they're unanchored
			if(istype(H))
				L.visible_message(span_danger("[L] is pulled by [H]'s wire!"),span_userdanger("A wire grabs you and pulls you towards [H]!"))				
				L.Immobilize(1.5 SECONDS)
				if(prob(5))
					firer.say("GET OVER HERE!!")//slicer's request
				if(T.density) // If we happen to be facing a wall after the wire snatches them
					to_chat(H, span_warning("[H] catches [L] and throws [L.p_them()] against [T]!"))
					to_chat(L, span_userdanger("[H] crushes you against [T]!"))
					playsound(L,'sound/effects/pop_expl.ogg', 130, 1)
					L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
					L.forceMove(Q)
					return
				// If we happen to be facing a dense object after the wire snatches them, like a table or window
				for(var/obj/D in T.contents)
					if(D.density == TRUE)
						D.take_damage(50)	
						L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
						L.forceMove(Q)
						to_chat(H, span_warning("[H] catches [L] throws [L.p_them()] against [D]!"))
						playsound(L,'sound/effects/pop_expl.ogg', 20, 1)
						return
				L.forceMove(T)
	if(iswallturf(target)) // If we hit a wall, pull us to it
		var/turf/W = target
		zip(H, W)

/obj/item/projectile/wire/Destroy()
	qdel(wire) // Cleans up the beam that we generate once we hit something
	return ..()
