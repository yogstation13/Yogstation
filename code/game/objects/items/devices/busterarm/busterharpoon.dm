/datum/action/cooldown/buster/megabuster/megaharpoon
	name = "Whalebone Harpoon"
	desc = "Charge up your harpoon and ready it to be fired, if it makes contact with a person it will drag them to you and knock them down, or pull you towards whatever you hit."


/obj/item/gun/magic/wire/harpoon
	name = "Whalebone Harpoon Head"
	desc = "A harpoon head made of pure whalebone, hits like a freighter."
	ammo_type = /obj/item/ammo_casing/magic/wire/harpoon
	icon_state = "hook"
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
	icon_state = "hook"

/obj/projectile/wire/harpoon
	name = "harpoon"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 10
	armour_penetration = 100
	damage_type = BRUTE
	nodamage = TRUE
	range = 8
	hitsound = 'sound/effects/splat.ogg'
	immobilize = 1 SECONDS

/// Left buster-arm means megabuster goes in left hand -- I stole this from megabuster! -- cowbot93
/datum/action/cooldown/buster/megabuster/megaharpoon/l/Activate()
	var/obj/item/gun/magic/wire/harpoon/B = new()
	owner.visible_message(span_userdanger("[owner]'s arm lets out a harrowing sound!"))
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(owner, 2 SECONDS, owner, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		if(!owner.put_in_l_hand(B))
			to_chat(owner, span_warning("You can't do this with your left hand full!"))
		else
			owner.visible_message(span_danger("[owner]'s arm begins billowing out steam!"))
			if(owner.active_hand_index % 2 == 0)
				owner.swap_hand(0)
			StartCooldown()
