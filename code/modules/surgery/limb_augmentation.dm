
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	name = "sever muscles"
	implements = list(TOOL_SCALPEL = 100, TOOL_WIRECUTTER = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class ='notice'>You begin to sever the muscles on [target]'s [parse_zone(user.zone_selected)]...</span>",
		"[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_selected)].",
		"[user] begins an incision on [target]'s [parse_zone(user.zone_selected)].")

/datum/surgery_step/replace_limb
	name = "replace limb"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100)
	time = 32
	var/obj/item/bodypart/L = null // L because "limb"


/datum/surgery_step/replace_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage) && istype(tool.contents[1], /obj/item/bodypart))
		tool = tool.contents[1]
	var/obj/item/bodypart/aug = tool
	if(aug.status != BODYPART_ROBOTIC)
		to_chat(user, span_warning("That's not an augment, silly!"))
		return -1
	if(aug.body_zone != target_zone)
		to_chat(user, span_warning("[tool] isn't the right type for [parse_zone(target_zone)]."))
		return -1
	L = surgery.operated_bodypart
	if(L)
		display_results(user, target, "<span class ='notice'>You begin to augment [target]'s [parse_zone(user.zone_selected)]...</span>",
			"[user] begins to augment [target]'s [parse_zone(user.zone_selected)] with [aug].",
			"[user] begins to augment [target]'s [parse_zone(user.zone_selected)].")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")


//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "Augmentation"
	desc = "Replace a limb with a robot part."
	icon_state = "augmentation"
	steps = list(/datum/surgery_step/incise, 
				/datum/surgery_step/clamp_bleeders, 
				/datum/surgery_step/retract_skin, 
				/datum/surgery_step/replace, 
				/datum/surgery_step/saw,
				/datum/surgery_step/replace_limb 
				)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE

/datum/surgery/augmentation/mechanic
	steps = list(/datum/surgery_step/mechanic_open,
				/datum/surgery_step/open_hatch,
				/datum/surgery_step/mechanic_unwrench,
				/datum/surgery_step/prepare_electronics,
				/datum/surgery_step/replace_limb)
	requires_bodypart_type = BODYPART_ROBOTIC

//SURGERY STEP SUCCESSES

/datum/surgery_step/replace_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/bodypart/tool, datum/surgery/surgery)
	if(L)
		if(istype(tool, /obj/item/organ_storage))
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = tool.contents[1]
		if(istype(tool) && user.temporarilyRemoveItemFromInventory(tool))
			tool.replace_limb(target, TRUE)
		display_results(user, target, span_notice("You successfully augment [target]'s [parse_zone(target_zone)]."),
			"[user] successfully augments [target]'s [parse_zone(target_zone)] with [tool]!",
			"[user] successfully augments [target]'s [parse_zone(target_zone)]!")
		log_combat(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
		var/points = 150 * (target.client ? 1 : 0.1)
		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))
		to_chat(user, "<span class = 'notice'>The augment uploads diagnostic data to the research cloud, giving a bonus of research points!</span>")
	else
		to_chat(user, span_warning("[target] has no organic [parse_zone(target_zone)] there!"))
	return TRUE
