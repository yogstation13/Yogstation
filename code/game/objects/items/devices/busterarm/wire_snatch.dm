/* Formatting for these files, from top to bottom:
	* Action
	* Trigger()
	* IsAvailable(feedback = FALSE)
	* Items
	In regards to actions or items with left and right subtypes, list the base, then left, then right.
*/


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
	item_flags = NEEDS_PERMIT | DROPDEL | NOBLUDGEON
	weapon_weight = WEAPON_MEDIUM 
	force = 0
	can_charge = FALSE

/obj/item/gun/magic/wire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)
	if(ismob(loc))
		loc.visible_message(span_warning("A long cable comes out from [loc.name]'s arm!"), span_warning("You extend the buster's wire from your arm."))


/obj/item/gun/magic/wire/process_chamber()
	. = ..()
	if(!charges)
		qdel(src)


/obj/item/ammo_casing/magic/wire
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/projectile/wire
	caliber = CALIBER_HOOK
	icon_state = "hook"


/obj/projectile/wire
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 0
	armour_penetration = 100
	damage_type = BRUTE
	nodamage = TRUE
	range = 8
	hitsound = 'sound/effects/splat.ogg'
	knockdown = 0
	var/wire_icon_state = "chain"
	var/wire

/obj/projectile/wire/fire(setAngle)
	if(firer)
		wire = firer.Beam(src, icon_state = wire_icon_state, time = INFINITY, maxdistance = INFINITY)
	..()

/// Helper proc exclusively used for pulling the buster arm USER towards something anchored
/obj/projectile/wire/proc/zip(mob/living/user, turf/open/target)
	to_chat(user, span_warning("You pull yourself towards [target]."))
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.Immobilize(0.2 SECONDS)//so it's not cut short by walking
	user.forceMove(get_step_towards(target, user))

/obj/projectile/wire/on_hit(atom/target)
	var/mob/living/carbon/human/H = firer
	if(!H)
		return
	H.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
	if(isobj(target)) 
		var/obj/item/I = target
		if(!I?.anchored)
			I.throw_at(get_step_towards(H,I), 8, 2)
			H.visible_message(span_danger("[I] is pulled by [H]'s wire!"))
			if(istype(I, /obj/item/clothing/head))
				H.equip_to_slot_if_possible(I, ITEM_SLOT_HEAD)
				H.visible_message(span_danger("[H] pulls [I] onto [H.p_their()] head!"))
			else
				H.put_in_hands(I)
			return
		zip(H, target) 
	if(isliving(target)) 
		H.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
		H.swap_hand(0) 
		var/mob/living/L = target
		var/turf/T = get_step(get_turf(H), H.dir)
		var/turf/Q = get_turf(H)
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(H.zone_selected)
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		if(!L.anchored)
			if(istype(H))
				L.visible_message(span_danger("[L] is pulled by [H]'s wire!"),span_userdanger("A wire grabs you and pulls you towards [H]!"))
				L.Immobilize(1.0 SECONDS)
				if(prob(5))
					firer.say("GET OVER HERE!!")//slicer's request
				if(T.density) 
					to_chat(H, span_warning("[H] catches [L] and throws [L.p_them()] against [T]!"))
					to_chat(L, span_userdanger("[H] crushes you against [T]!"))
					playsound(L,'sound/effects/pop_expl.ogg', 130, 1)
					L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
					L.forceMove(Q)
					return
				for(var/obj/D in T.contents)
					if(D.density == TRUE)
						D.take_damage(50)
						L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
						L.forceMove(Q)
						to_chat(H, span_warning("[H] catches [L] throws [L.p_them()] against [D]!"))
						playsound(L,'sound/effects/pop_expl.ogg', 20, 1)
						return
				L.forceMove(T)
	if(iswallturf(target))
		var/turf/W = target
		zip(H, W)

/obj/projectile/wire/Destroy()
	qdel(wire) 
	return ..()
