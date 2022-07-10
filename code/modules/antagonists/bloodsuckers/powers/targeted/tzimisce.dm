#define SIZE_SMALL 1
#define SIZE_MEDIUM 2
#define SIZE_BIG 4

/datum/action/bloodsucker/targeted/dice
	name = "Dice" 
	desc = "Slice, cut, sever. The Flesh obeys as my fingers lay touch on it."
	button_icon_state = "power_dice"
	power_explanation = "<b>Dice</b>:\n\
		Use on a dead corpse to extract muscle from it to be able to feed it to a vassalrack.\n\
		This won't take long and is your primary source of muscle acquiring, necessary for future endeavours.\n\
		This ability takes well to leveling up, higher levels will increase your mastery over a person's flesh while using the ability for it's combat purpose.\n\
		You shouldn't use this on your allies.."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	bloodcost = 10
	button_icon = 'icons/mob/actions/actions_tzimisce_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_tzimisce_bloodsucker.dmi'
	background_icon_state = "tzimisce_power_off"
	background_icon_state_on = "tzimisce_power_on"
	background_icon_state_off = "tzimisce_power_off"
	purchase_flags = TZIMISCE_CAN_BUY
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_AM_COSTLESS_UNCONSCIOUS
	target_range = 1
	cooldown = 10 SECONDS

/obj/item/muscle
	name = "muscle"
	desc = "Weird flex but ok"
	icon = 'icons/mob/actions/actions_tzimisce_bloodsucker.dmi'
	icon_state = "muscle_all"
	var/size

/obj/item/muscle/small
	name = "small muscle piece"
	desc = "This one sure wasn't important to it's owner."
	icon_state = "muscle_small"
	size = SIZE_SMALL
	w_class = WEIGHT_CLASS_TINY

/obj/item/muscle/medium
	name = "medium muscle piece"
	desc = "This would make for a great meal if it wasn't still twitching."
	icon_state = "muscle_medium"
	size = SIZE_MEDIUM
	w_class = WEIGHT_CLASS_SMALL

/obj/item/muscle/big
	name = "big muscle piece"
	desc = "I'm pretty sure it's owner needed this to live."
	icon_state = "muscle_big"
	size = SIZE_BIG

/obj/item/muscle/examine(mob/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(IS_BLOODSUCKER(user) && bloodsuckerdatum.my_clan == CLAN_TZIMISCE)
		. += span_cult("By looking at it you comprehend that it would yield [size] points for ritual usage.")

/obj/item/muscle/attackby(obj/item/I, mob/user, params) // handles muscle crafting
	var/newsize = 0
	var/quantity = 1
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!(IS_BLOODSUCKER(user) && bloodsuckerdatum.my_clan == CLAN_TZIMISCE))
		return
	if(istype(I, /obj/item/muscle))
		var/obj/item/muscle/muscle2 = I
		newsize = size + muscle2.size
		if(newsize > SIZE_BIG) //so you only have to change defines if you want to balance muscles
			to_chat(user, span_warning("You can't make [src] any bigger!"))
			return
		to_chat(user, span_notice("You merge [src] and [muscle2] into a bigger piece."))
		qdel(muscle2)
	if(I.sharpness == SHARP_EDGED)
		newsize = size / 2
		quantity = 2
		if(newsize < SIZE_SMALL)
			to_chat(user, span_warning("You can't cut [src] anymore!"))
			return 
		to_chat(user, span_notice("You cut [src] into smaller pieces."))
	switch(newsize)
		if(0)
			return ..()
		if(SIZE_SMALL)
			new /obj/item/muscle/small(user.drop_location())
			if(quantity == 2) // don't want to make it stackable
				new /obj/item/muscle/small(user.drop_location())
		if(SIZE_SMALL + 0.5)
			new /obj/item/muscle/small(user.drop_location())
			new /obj/item/muscle/medium(user.drop_location())
		if(SIZE_MEDIUM)
			new /obj/item/muscle/medium(user.drop_location())
			if(quantity == 2)
				new /obj/item/muscle/medium(user.drop_location())
		if(SIZE_MEDIUM + 1)
			size += 1
			return
		if(SIZE_BIG)
			new /obj/item/muscle/big(user.drop_location())
	qdel(src)

/datum/action/bloodsucker/targeted/dice/FireTargetedPower(atom/target_atom)
	var/mob/living/target = target_atom
	var/mob/living/carbon/user = owner
	user.face_atom(target)
	if(target.stat != DEAD)
		if(iscarbon(target))
			var/mob/living/carbon/Ctarget = target
			var/selected_zone = user.zone_selected
			var/list/viable_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			if(!viable_zones.Find(selected_zone))
				selected_zone = pick(viable_zones)
			var/obj/item/bodypart/target_part = Ctarget.get_bodypart(selected_zone)
			user.do_attack_animation(Ctarget, ATTACK_EFFECT_PUNCH)
			playsound(usr.loc, "sound/weapons/slice.ogg", 50, TRUE)
			if(!target_part)
				to_chat(user, span_warning("[Ctarget] has no limb there!"))
				Ctarget.adjustBruteLoss(15 * level_current / 2)
				return
			switch(level_current)
				if(0 to 3)
					Ctarget.apply_damage(50, STAMINA, selected_zone)
					to_chat(user, span_warning("You swiftly disable the nerves in [Ctarget]'s [target_part] with a precise strike."))
				if(3 to 6)
					Ctarget.apply_damage(25, STAMINA, selected_zone)
					Ctarget.apply_damage(25, BRUTE, selected_zone)
					Ctarget.drop_all_held_items()
					to_chat(user, span_warning("You hastly damage the ligaments in [Ctarget]'s [target_part] with a fierce blow."))
				if(6 to INFINITY)
					if(target_part.dismemberable)
						target_part.dismember()
						to_chat(user, span_warning("You sever [Ctarget]'s [target_part] with a clean swipe."))
					else
						Ctarget.apply_damage(30, BRUTE, selected_zone)
						Ctarget.drop_all_held_items()
						to_chat(user, span_warning("As [Ctarget]'s [target_part] is too tough to chop in a single action!"))
		else
			target.adjustBruteLoss(25)
		return
	playsound(usr.loc, "sound/weapons/slice.ogg", 50, TRUE)
	if(!do_mob(usr, target, 2.5 SECONDS))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		for(var/obj/item/bodypart/bodypart in H.bodyparts)
			if(bodypart.body_part != HEAD && bodypart.body_part != CHEST)
				if(bodypart.dismemberable)
					bodypart.dismember()
					qdel(bodypart)
					new /obj/item/muscle/medium(H.loc)
				else
					to_chat(user, span_warning("You can't dismember this [bodypart] of [target]"))
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/obj/item/bodypart/bodypart in C.bodyparts)
			if(bodypart.body_part != HEAD && bodypart.body_part != CHEST)
				if(bodypart.dismemberable)
					bodypart.dismember()
					qdel(bodypart)
					new /obj/item/muscle/small(C.loc)
		return
	target.gib()
	new /obj/item/muscle/medium(target.loc)

/datum/action/bloodsucker/targeted/dice/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/bloodsucker/targeted/dice/CheckCanTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(target_atom))
		return TRUE
	return FALSE

#undef SIZE_SMALL
#undef SIZE_MEDIUM
#undef SIZE_BIG