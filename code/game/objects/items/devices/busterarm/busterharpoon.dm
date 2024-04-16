/datum/action/cooldown/buster/megabuster/megaharpoon
	name = "gasharpoon"
	desc = "Charge up your harpoon and ready it to be fired, if it makes contact with a person it will drag them to you and immobilize them."
	cooldown_time = 10 SECONDS
	button_icon_state = "harpoonhead"
	
	
/obj/item/gun/magic/wire/harpoon
	name = "Harpoon Head"
	desc = "A harpoon head made of pure plasteel, hits like a freighter."
	ammo_type = /obj/item/ammo_casing/magic/wire/harpoon
	icon_state = "gasharpoon"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	item_flags = NEEDS_PERMIT | DROPDEL
	force = 0
	can_charge = FALSE

/obj/item/ammo_casing/magic/wire/harpoon
	name = "harpoon"
	desc = "A harpoon."
	projectile_type = /obj/projectile/wire/harpoon
	caliber = CALIBER_HOOK
	icon_state = "harpoonhead"

/obj/projectile/wire/harpoon/fire(setAngle)
	if(firer)
		wire = firer.Beam(src, icon_state = "harpoonrope", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/projectile/wire/harpoon
	name = "harpoon"
	icon_state = "harpoonhead"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 10
	armour_penetration = 100
	damage_type = BRUTE
	nodamage = TRUE
	range = 8
	hitsound = 'sound/effects/splat.ogg'
	immobilize = 1 SECONDS

/obj/projectile/wire/harpoon/on_hit(atom/target)
	var/mob/living/L = target
	var/mob/living/carbon/human/H = firer
	if(!L)
		return
	L.apply_status_effect(STATUS_EFFECT_EXPOSED_HARPOONED)
	if(isobj(target)) // If it's an object
		var/obj/item/I = target
		if(!I?.anchored) // Give it to us if it's not anchored
			I.throw_at(get_step_towards(H,I), 8, 2)
			H.visible_message(span_danger("[I] is pulled by [H]'s harpoon!"))
			if(istype(I, /obj/item/clothing/head))
				H.equip_to_slot_if_possible(I, ITEM_SLOT_HEAD)
				H.visible_message(span_danger("[H] pulls [I] onto [H.p_their()] head!"))
			else
				H.put_in_hands(I)
			return
		zip(H, target) // Pull us towards it if it's anchored
	if(isliving(target)) // If it's somebody
		H.swap_hand(0) //for the sake of throttling people you catch
		var/turf/T = get_step(get_turf(H), H.dir)
		var/turf/Q = get_turf(H)
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(H.zone_selected)
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		if(!L.anchored) // Only pull them if they're unanchored
			if(istype(H))
				L.visible_message(span_danger("[L] is pulled by [H]'s harpoon!"),span_userdanger("A harpoon pierces you and pulls you towards [H]!"))
				L.Immobilize(1.0 SECONDS)
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

/// Left buster-arm means megabuster goes in left hand -- I stole this from megabuster! -- cowbot93
/datum/action/cooldown/buster/megabuster/megaharpoon/l/Activate()
	var/obj/item/gun/magic/wire/harpoon/B = new()
	owner.visible_message(span_userdanger("[owner]'s arm lets out a harrowing sound!"))
	playsound(owner,'sound/weapons/bladeslice.ogg', 60, 1)
	if(do_after(owner, 2 SECONDS, owner, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		if(!owner.put_in_l_hand(B))
			to_chat(owner, span_warning("You can't do this with your left hand full!"))
		else
			owner.visible_message(span_danger("[owner]'s readies the harpoon to fire!"))
			if(owner.active_hand_index % 2 == 0)
				owner.swap_hand(0)
			StartCooldown()
