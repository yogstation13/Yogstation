//debride wounds
/datum/surgery_step/debride
	name = "clean wound"
	implements = list(TOOL_SCALPEL = 100, /obj/item/kitchen/knife = 65, /obj/item/shard = 45)
	time = 4 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'

/datum/surgery_step/debride/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to cut off dead flesh around the wound upon [target]'s [parse_zone(target_zone)].", span_notice("You begin cutting away the dead and damaged tissue on [target]'s [parse_zone(target_zone)], creating a cleaner wound bed..."))

/datum/surgery_step/debride/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(15, "brute", "[target_zone]", wound_bonus = CANT_WOUND)


	user.visible_message("[user] scrapes [tool] across [target]'s wounds with surgical precision, cleaning the area.", span_notice("You scrape away the detritus and scarred flesh from [target]'s [parse_zone(target_zone)]. The wound is now fully debrided and ready for dressing."))
	return TRUE

//add dressing to wounds
/datum/surgery_step/apply_dressing //brute
	name = "apply gauze"
	implements = list(/obj/item/stack/medical/gauze = 100, /obj/item/medical/bandage/improvised = 65, /obj/item/clothing/torncloth = 35)
	time = 2.4 SECONDS
	fuckup_damage = 0
	preop_sound = 'sound/effects/rip2.ogg'
	success_sound = 'sound/effects/rip1.ogg'
	var/dressing_type = "brute"

/datum/surgery_step/apply_dressing/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts dressing [target]'s [parse_zone(target_zone)] wounds with [tool]..", span_notice("You start wrapping and dressing [target]'s [parse_zone(target_zone)] with [tool].."))

/datum/surgery_step/apply_dressing/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/heal_limb = H.get_bodypart(check_zone(target_zone))

		if (heal_limb)
			switch (dressing_type)
				if ("brute")
					heal_limb.heal_damage(85, 0) //brute
					H.update_damage_overlays()
				if ("burn")
					heal_limb.heal_damage(0, 85) //burn
					H.update_damage_overlays()

		else
			to_chat(user, "There's no limb there to dress!")
			return 0

		if(locate(/datum/surgery_step/debride) in surgery.steps)
			heal_limb.heal_damage(15,0)
			H.update_damage_overlays()

		if (istype(tool, /obj/item/stack/medical/gauze/))
			var/obj/item/stack/medical/gauze/G = tool
			G.use(2)
		else
			qdel(tool)

	user.visible_message("[user] dresses [target]'s wounds with [tool], securing them tightly.", span_notice("You bind [target]'s [parse_zone(target_zone)] wound tightly with [tool]."))
	return TRUE

/datum/surgery_step/apply_dressing/burn
	name = "apply bandage"
	implements = list(/obj/item/stack/medical/gauze = 100, /obj/item/medical/bandage/improvised_soaked = 65, /obj/item/clothing/torncloth = 25)
	time = 24
	dressing_type = "burn"

//surgeries go here
/datum/surgery/heal_brute
	name = "patch wounds"
	desc = "Heals a body part of brute damage. Useful for allowing a body to be defibrillated."
	icon = 'icons/obj/stack_medical.dmi'
	icon_state = "brutepack_3"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/debride, /datum/surgery_step/apply_dressing, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)

/datum/surgery/heal_burn
	name = "treat burns"
	desc = "Heals a body part of burn damage. Useful for allowing a body to be defibrillated."
	icon = 'icons/obj/stack_medical.dmi'
	icon_state = "ointment_3"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/debride, /datum/surgery_step/apply_dressing/burn, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
