/obj/item/medical/bandage
	name = "\improper Bandage"
	desc = "A generic bandage of unknown origin and use. What does it cover? Is it a trendy accessory? Will I ever know?."
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "improv_bandage"
	w_class = 1
	throw_speed = 3
	throw_range = 7
	var/healtype = "brute" //determines what damage type the item heals
	var/healamount = 70 //determines how much it heals OVERALL (over duration)
	var/staunch_bleeding = 600 //does it stop bleeding and if so, how much?
	var/duration = 40 //duration in ticks of healing effect (these roughly equate to 1.5s each)
	var/activefor = 1
	var/used = 0 //has the bandage been used or not?
	var/obj/item/bodypart/healing_limb = null
	//bandages unwrap bloodied after the duration ends and fall to the floor with the user's blood on them

/obj/item/medical/bandage/proc/handle_bandage(mob/living/carbon/human/H)
	//handles bandage healing per tick, called in life
	if (!used)
		if (healing_limb && healing_limb.status == BODYPART_ORGANIC)
			var/success = 0
			switch (healtype)
				if ("brute")
					if (healing_limb.brute_dam)
						success = healing_limb.heal_damage(healamount/src.duration, 0, 0)
					else
						to_chat(H, "<span class='notice'>The wounds on your [src.healing_limb.name] have stopped bleeding and appear to be healed.</span>")
						used = 1
				if ("burn")
					if (healing_limb.burn_dam)
						success = healing_limb.heal_damage(0, healamount/src.duration, 0)
					else
						used = 1
						to_chat(H, "<span class='notice'>The burns on your [src.healing_limb.name] feel much better, and seem to be completely healed.</span>")
			if (success)
				H.update_damage_overlays(0)
			if (staunch_bleeding && !H.bleedsuppress)
				H.suppress_bloodloss(staunch_bleeding)
			if (activefor <= src.duration)
				activefor += 1
			else
				used = 1
	else
		//eject the bandage onto the floor with
		fall_off(H, healing_limb)

/obj/item/medical/bandage/proc/unwrap(mob/living/M, mob/living/carbon/human/T)
	//DUPLICATE CODE BUT I'M FUCKING LAZY <- this was not Morrow
	if (healing_limb.bandaged)
		M.visible_message("<span class='warning'>[M] grabs and pulls at the [src] on [T]'s [src.healing_limb.name], unwrapping it instantly!</span>", "<span class='notice'>You deftly yank [src] off [T]'s [src.healing_limb.name].</span>")
		name = "used [src.name]"
		desc = "Piled into a tangled, crusty mess, these bandages have obviously been used and then disposed of in great haste."
		color = "red"
		loc = T.loc
		healing_limb.bandaged = 0
		used = 1


/obj/item/medical/bandage/proc/fall_off(mob/living/carbon/human/H, obj/item/bodypart/L)
	if (L.bandaged)
		to_chat(H, "You loosen the bandage around [L.name] and let it fall to the floor.")
		name = "used [src.name]"
		desc = "Bloodied and crusted, these bandages have clearly been used and aren't fit for much anymore. Seems as if they were wrapped around someone's [L.name] last."
		color = "red"
		loc = H.loc
		L.bandaged = 0
		used = 1

/obj/item/medical/bandage/proc/apply(mob/living/user, mob/tar, obj/item/bodypart/lt)
	var/mob/living/carbon/human/temphuman
	if (!ishuman(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to use this!</span>")
		return 0

	if (ishuman(tar))
		temphuman = tar
		if (!lt.bandaged)
			if (user == tar)
				user.visible_message("<span class='notice'>[user] begins winding [src] about their [lt.name]..</span>", "<span class='notice'>You begin winding [src] around your [lt.name]..</span>")
			else
				user.visible_message("<span class='notice'>[user] begins winding [src] about [tar]'s [lt.name]..</span>", "<span class='notice'>You begin winding [src] around [tar]'s [lt.name]..</span>")

			if (do_after(user, 50, target = tar))
				if(!user.canUnEquip(src))
					return 0
				healing_limb = lt
				lt.bandaged = src
				loc = temphuman
				user.visible_message("[user] has applied [src] successfully.", "You have applied [src] successfully.")
				return 1
			else
				if(user.get_active_held_item() == src)
					if(!user.canUnEquip(src))
						return 0
					loc = temphuman.loc
					user.visible_message("<span class='warning'>Interrupted, [user] fumbles and drops [src] to the floor!</span>", "<span class='warning'>Losing your concentration, you find yourself unable to apply [src] and let it slip through your fingers to pool upon the floor!</span>")
				else
					user.visible_message("<span class='warning'>[user] stops applying [src] to [tar].</span>", "<span class='warning'>You stop applying [src] to [tar].</span>")
				return 0
		else
			to_chat(user, "[tar] is already bandaged for the moment.")
			return 0
	else
		to_chat(user, "This doesn't look like it'll work.")
		return 0

/obj/item/medical/bandage/proc/wash(obj/O, mob/user)
	if (src.used)
		to_chat(user, "You clean [src] fastidiously washing away as much of the detritus and residue as you can. The bandage can probably be used again now.")
		name = "reused bandages"
		desc = "Whatever quality these bandages once were, there's no sign of it any more. Not like the wounds you put this stuff over care, though."
		healamount = src.healamount * 0.85
		duration = src.duration * 1.15
		activefor = 1
		color = 0
		used = 0
	else
		to_chat(user, "There's no real need to wash this - it's perfectly clean!")

/obj/item/medical/bandage/attack(mob/living/carbon/human/T, mob/living/carbon/human/U)
	if (used)
		to_chat(U, "These bandages have already been used. They're worthless as they are. Maybe if they had the blood washed out of them with running water?")
		return

	var/obj/item/bodypart/O =  T.get_bodypart(check_zone(U.zone_selected))

	if (O.status == ORGAN_ROBOTIC)
		to_chat(U, "You don't have time to explain why there's no time to explain why you can't bandage this very obviously robotic limb.")
		return

	if (!O.bandaged)
		apply(U, T, O)
		return
	else if (O.bandaged)
		to_chat(U, "This limb has already been bandaged, so there's no point putting another one on.")
		return

/obj/item/medical/bandage/improvised
	name = "improvised bandage"
	desc = "A primitive bandage fashioned from some torn cloth and leftover elastic. Will do in a pinch, but is nowhere near as effective as actual medical-grade bandages."
	healtype = "brute"
	healamount = 40
	duration = 40
	staunch_bleeding = 240

/obj/item/medical/bandage/improvised_soaked
	name = "soaked improvised bandage"
	desc = "Primitive bandage thoroughly soaked in water, Probably decent for a burn wound, but definitely isn't sterile. Useless at stopping bleeding."
	healtype = "burn"
	color = "blue"
	healamount = 40
	duration = 40
	staunch_bleeding = 0
	