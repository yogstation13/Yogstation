/datum/surgery/organ_manipulation
	name = "Organ manipulation"
	icon_state = "organ_manipulation"
	desc = "This surgery covers operations to remove/insert internal organs, tails, and cyber implants."
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = 1
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		//there should be bone fixing
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/alien
	name = "Alien organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	steps = list(
		/datum/surgery_step/saw,
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/mechanic
	name = "Prosthesis organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/organ_manipulation/mechanic/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery_step/manipulate_organs
	time = 6.4 SECONDS
	name = "manipulate organs"
	repeatable = 1
	implements = list(/obj/item/organ = 100, /obj/item/reagent_containers/food/snacks/organ = 0, /obj/item/organ_storage = 100)
	preop_sound = 'sound/surgery/organ2.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	var/implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 55)
	var/current_type
	var/obj/item/organ/I = null

/datum/surgery_step/manipulate_organs/New()
	..()
	implements = implements + implements_extract

/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	I = null
	if(istype(tool, /obj/item/organ_storage))
		preop_sound = initial(preop_sound)
		success_sound = initial(success_sound)
		if(!tool.contents.len)
			to_chat(user, span_notice("There is nothing inside [tool]!"))
			return -1
		I = tool.contents[1]
		if(!isorgan(I))
			to_chat(user, span_notice("You cannot put [I] into [target]'s [parse_zone(target_zone)]!"))
			return -1
		tool = I
	if(isorgan(tool))
		current_type = "insert"
		preop_sound = initial(preop_sound)
		success_sound = initial(success_sound)
		I = tool
		if(target_zone != I.zone || target.getorganslot(I.slot))
			to_chat(user, span_notice("There is no room for [I] in [target]'s [parse_zone(target_zone)]!"))
			return -1

		display_results(user, target, span_notice("You begin to insert [tool] into [target]'s [parse_zone(target_zone)]..."),
			"[user] begins to insert [tool] into [target]'s [parse_zone(target_zone)].",
			"[user] begins to insert something into [target]'s [parse_zone(target_zone)].")

	else if(implement_type in implements_extract)
		current_type = "extract"
		preop_sound = 'sound/surgery/hemostat1.ogg'
		success_sound = 'sound/surgery/organ2.ogg'
		var/list/organs = target.getorganszone(target_zone)
		var/mob/living/simple_animal/horror/H = target.has_horror_inside()
		if(H)
			user.visible_message("[user] begins to extract [H] from [target]'s [parse_zone(target_zone)].",
					"<span class='notice'>You begin to extract [H] from [target]'s [parse_zone(target_zone)]...</span>")
			return TRUE
		if(!organs.len)
			to_chat(user, span_notice("There are no removable organs in [target]'s [parse_zone(target_zone)]!"))
			return -1
		else
			for(var/obj/item/organ/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			I = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
			if(I && user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				I = organs[I]
				if(!I)
					return -1
				display_results(user, target, span_notice("You begin to extract [I] from [target]'s [parse_zone(target_zone)]..."),
					"[user] begins to extract [I] from [target]'s [parse_zone(target_zone)].",
					"[user] begins to extract something from [target]'s [parse_zone(target_zone)].")
			else
				return -1

	else if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		to_chat(user, span_warning("[tool] was bitten by someone! It's too damaged to use!"))
		return -1

/datum/surgery_step/manipulate_organs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(current_type == "insert")
		if(istype(tool, /obj/item/organ_storage))
			I = tool.contents[1]
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = I
		else
			I = tool
		user.temporarilyRemoveItemFromInventory(I, TRUE)
		I.Insert(target)
		display_results(user, target, span_notice("You insert [tool] into [target]'s [parse_zone(target_zone)]."),
			"[user] inserts [tool] into [target]'s [parse_zone(target_zone)]!",
			"[user] inserts something into [target]'s [parse_zone(target_zone)]!")

	else if(current_type == "extract")
		var/mob/living/simple_animal/horror/H = target.has_horror_inside()
		if(H && H.victim == target)
			user.visible_message("[user] successfully extracts [H] from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You successfully extract [H] from [target]'s [parse_zone(target_zone)].</span>")
			log_combat(user, target, "surgically removed [H] from", addition="INTENT: [uppertext(user.a_intent)]")
			H.leave_victim()
			return FALSE
		if(I && I.owner == target)
			display_results(user, target, span_notice("You successfully extract [I] from [target]'s [parse_zone(target_zone)]."),
				"[user] successfully extracts [I] from [target]'s [parse_zone(target_zone)]!",
				"[user] successfully extracts something from [target]'s [parse_zone(target_zone)]!")
			log_combat(user, target, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			I.Remove(target)
			I.forceMove(get_turf(target))
		else
			display_results(user, target, span_notice("You can't extract anything from [target]'s [parse_zone(target_zone)]!"),
				"[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!")
	return 0
