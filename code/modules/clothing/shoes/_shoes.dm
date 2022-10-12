/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET

	permeability_coefficient = 0.5
	slowdown = SHOES_SLOWDOWN
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	var/offset = 0
	var/equipped_before_drop = FALSE
	var/can_be_bloody = TRUE
	var/xenoshoe = NO_DIGIT  // Check for if shoes can be worn by straight legs (NO_DIGIT) which is default, both / hybrid (EITHER_STYLE), or digitigrade only (YES_DIGIT)
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION // Assigns shoes to have variations for if worn clothing doesn't enforce straight legs (such as cursed jumpskirts)
	var/adjusted = NORMAL_STYLE // Default needed to make the above work

/obj/item/clothing/shoes/suicide_act(mob/living/carbon/user)
	if(rand(2)>1)
		user.visible_message(span_suicide("[user] begins tying \the [src] up waaay too tightly! It looks like [user.p_theyre()] trying to commit suicide!"))
		var/obj/item/bodypart/l_leg = user.get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/r_leg = user.get_bodypart(BODY_ZONE_R_LEG)
		if(l_leg)
			l_leg.dismember()
			playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		if(r_leg)
			r_leg.dismember()
			playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	else//didnt realize this suicide act existed (was in miscellaneous.dm) and didnt want to remove it, so made it a 50/50 chance. Why not!
		user.visible_message(span_suicide("[user] is bashing [user.p_their()] own head in with [src]! Ain't that a kick in the head?"))
		for(var/i = 0, i < 3, i++)
			sleep(0.3 SECONDS)
			playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
		return(BRUTELOSS)

/obj/item/clothing/shoes/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		var/bloody = FALSE
		if(HAS_BLOOD_DNA(src))
			bloody = TRUE
		else
			bloody = bloody_shoes[BLOOD_STATE_HUMAN]

		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedshoe")
		if(bloody)
			. += mutable_appearance('icons/effects/blood.dmi', "shoeblood")

/obj/item/clothing/shoes/equipped(mob/user, slot)
	if(adjusted)
		adjusted = NORMAL_STYLE
	if(mutantrace_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(DIGITIGRADE in H.dna.species.species_traits)
			for(var/X in H.bodyparts)
				var/obj/item/bodypart/O = X
				if(!O.use_digitigrade)
					continue
				if(O.use_digitigrade == FULL_DIGITIGRADE)
					adjusted = DIGITIGRADE_STYLE
		user.update_inv_shoes()
	. = ..()
	if(offset && slot_flags & slotdefine2slotbit(slot))
		user.pixel_y += offset
		worn_y_dimension -= (offset * 2)
		equipped_before_drop = TRUE

	user.update_inv_shoes()

/obj/item/clothing/shoes/proc/restore_offsets(mob/user)
	equipped_before_drop = FALSE
	user.pixel_y -= offset
	worn_y_dimension = world.icon_size

/obj/item/clothing/shoes/dropped(mob/user)
	if(offset && equipped_before_drop)
		restore_offsets(user)
	. = ..()

/obj/item/clothing/shoes/update_clothes_damaged_state()
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/clothing/shoes/wash(clean_types)
	. = ..()
	if(!(clean_types & CLEAN_TYPE_BLOOD) || blood_state == BLOOD_STATE_NOT_BLOODY)
		return
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()
	return TRUE

/obj/item/proc/negates_gravity()
	return FALSE
