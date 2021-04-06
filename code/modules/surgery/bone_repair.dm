/datum/surgery/organ_manipulation
	name = "Organ manipulation"
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = 1
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/fix_bones,
		/datum/surgery_step/set_bones,
		//there should be bone fixing -- now there is
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/fix_bones,
		/datum/surgery_step/set_bones,
		/datum/surgery_step/close
		)


/datum/surgery_step/fix_bones
	time = 64
	name = "mend bones"
	repeatable = 1
	//Bone gel
	implements = list(/obj/item/bone_gel = 100, /obj/item/screwdriver = 40)

/datum/surgery_step/fix_bones/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_bodypart)
		if(surgery.operated_bodypart.bone && surgery.operated_bodypart.bone.damage_severity > NO_FRACTURE)
			display_results(user, target, "<span class='notice'>You begin to apply [tool] to [target]'s [parse_zone(target_zone)]...</span>",
					"[user] begin to apply [tool] to [target]'s [parse_zone(target_zone)].",
					"[user] begin to apply something to [target]'s [parse_zone(target_zone)].")
		else
			to_chat(user, "<span class='notice'>There is no damage to these bones!</span>")
			return -1
	to_chat(user, "<span class='notice'>There are no bones in here!</span>")
	return -1

/datum/surgery_step/fix_bones/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully apply [tool] to [target]'s [parse_zone(target_zone)].</span>",
				"[user] successfully applies [tool] to [target]'s [parse_zone(target_zone)]!",
				"[user] successfully applies something to [target]'s [parse_zone(target_zone)]!")

	if(surgery.operated_bodypart)
		if(surgery.operated_bodypart.bone && surgery.operated_bodypart.bone.damage_severity > NO_FRACTURE)
			surgery.operated_bodypart.bone.gelled = TRUE


/datum/surgery_step/set_bones
	time = 64
	name = "set bones"
	repeatable = 1
	//Bone setter
	implements = list(/obj/item/bone_setter = 100, /obj/item/wrench = 50, /obj/item/wirecutters = 20)

/datum/surgery_step/set_bones/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_bodypart)
		if(surgery.operated_bodypart.bone && surgery.operated_bodypart.bone.damage_severity > NO_FRACTURE)
			if(!surgery.operated_bodypart.bone.gelled)
				to_chat(user, "<span class='notice'>You need to apply bone gel first!</span>")
				return -1
			display_results(user, target, "<span class='notice'>You begin to set the bones in [target]'s [parse_zone(target_zone)]...</span>",
					"[user] begin to set the bones in [target]'s [parse_zone(target_zone)].",
					"[user] begin to do something to [target]'s [parse_zone(target_zone)].")

		else
			to_chat(user, "<span class='notice'>There is no damage to these bones!</span>")
			return -1
	to_chat(user, "<span class='notice'>There are no bones in here!</span>")
	return -1

/datum/surgery_step/set_bones/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully set the bones in [target]'s [parse_zone(target_zone)].</span>",
				"[user] successfully sets the bones in [target]'s [parse_zone(target_zone)]!",
				"[user] successfully jiggles something in [target]'s [parse_zone(target_zone)]!")

	if(surgery.operated_bodypart)
		if(surgery.operated_bodypart.bone && surgery.operated_bodypart.bone.damage_severity > NO_FRACTURE)
			surgery.operated_bodypart.bone.gelled = FALSE
			surgery.operated_bodypart.bone.damage = 0
			surgery.operated_bodypart.bone.damage_severity = NO_FRACTURE