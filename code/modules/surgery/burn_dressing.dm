
/////BURN FIXING SURGERIES//////

///// Debride burnt flesh
/datum/surgery/debride
	name = "Debride infected flesh"
	icon = 'icons/obj/stack_medical.dmi'
	icon_state = "gauze"
	steps = list(/datum/surgery_step/debride_infected, /datum/surgery_step/dress)
	target_mobtypes = list(/mob/living/carbon)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE
	targetable_wound = /datum/wound/burn

/datum/surgery/debride/can_start(mob/living/user, mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	if(..())
		var/obj/item/bodypart/targeted_bodypart = target.get_bodypart(user.zone_selected)
		var/datum/wound/burn/burn_wound = targeted_bodypart.get_wound_type(targetable_wound)
		return(burn_wound && burn_wound.infestation > 0)

//SURGERY STEPS

///// Debride
/datum/surgery_step/debride_infected
	name = "excise infection"
	implements = list(TOOL_SCALPEL = 100, TOOL_SAW = 60, TOOL_WIRECUTTER = 40)
	time = 3 SECONDS
	repeatable = TRUE
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'
	/// How much sanitization is added per step
	var/sanitization_added = 0.5
	/// How much infestation is removed per step (positive number)
	var/infestation_removed = 4

/datum/surgery_step/debride_infected/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		var/datum/wound/burn/burn_wound = surgery.operated_wound
		if(burn_wound.infestation <= 0)
			to_chat(user, span_notice("[target]'s [parse_zone(user.zone_selected)] has no infected flesh to remove!"))
			surgery.status++
			repeatable = FALSE
			return
		display_results(user, target, span_notice("You begin to excise infected flesh from [target]'s [parse_zone(user.zone_selected)]..."),
			span_notice("[user] begins to excise infected flesh from [target]'s [parse_zone(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to excise infected flesh from [target]'s [parse_zone(user.zone_selected)]."))
	else
		user.visible_message(span_notice("[user] looks for [target]'s [parse_zone(user.zone_selected)]."), span_notice("You look for [target]'s [parse_zone(user.zone_selected)]..."))

/datum/surgery_step/debride_infected/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/burn/burn_wound = surgery.operated_wound
	if(burn_wound)
		display_results(user, target, span_notice("You successfully excise some of the infected flesh from [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] successfully excises some of the infected flesh from [target]'s [parse_zone(target_zone)] with [tool]!"),
			span_notice("[user] successfully excises some of the infected flesh from  [target]'s [parse_zone(target_zone)]!"))
		log_combat(user, target, "excised infected flesh in", addition="INTENT: [uppertext(user.a_intent)]")
		surgery.operated_bodypart.receive_damage(brute=3, wound_bonus=CANT_WOUND)
		burn_wound.infestation -= infestation_removed
		burn_wound.sanitization += sanitization_added
		if(burn_wound.infestation <= 0)
			repeatable = FALSE
	else
		to_chat(user, span_warning("[target] has no infected flesh there!"))
	return ..()

/datum/surgery_step/debride_infected/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	display_results(user, target, span_notice("You carve away some of the healthy flesh from [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] carves away some of the healthy flesh from [target]'s [parse_zone(target_zone)] with [tool]!"),
		span_notice("[user] carves away some of the healthy flesh from  [target]'s [parse_zone(target_zone)]!"))
	surgery.operated_bodypart.receive_damage(brute=rand(4,8), sharpness=TRUE)

/datum/surgery_step/debride_infected/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(!..())
		return
	var/datum/wound/burn/burn_wound = surgery.operated_wound
	while(burn_wound && burn_wound.infestation > 0.25)
		if(!..())
			break

///// Dressing burns
/datum/surgery_step/dress
	name = "bandage burns"
	implements = list(/obj/item/stack/medical/gauze = 100)
	time = 4 SECONDS
	preop_sound = 'sound/effects/rip2.ogg'
	success_sound = 'sound/effects/rip1.ogg'

/datum/surgery_step/dress/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/wound/burn/burn_wound = surgery.operated_wound
	if(burn_wound)
		display_results(user, target, span_notice("You begin to dress the burns on [target]'s [parse_zone(user.zone_selected)]..."),
			span_notice("[user] begins to dress the burns on [target]'s [parse_zone(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to dress the burns on [target]'s [parse_zone(user.zone_selected)]."))
	else
		user.visible_message(span_notice("[user] looks for [target]'s [parse_zone(user.zone_selected)]."), span_notice("You look for [target]'s [parse_zone(user.zone_selected)]..."))

/datum/surgery_step/dress/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/burn/burn_wound = surgery.operated_wound
	if(burn_wound)
		display_results(user, target, span_notice("You successfully wrap [target]'s [parse_zone(target_zone)] with [tool]."),
			span_notice("[user] successfully wraps [target]'s [parse_zone(target_zone)] with [tool]!"),
			span_notice("[user] successfully wraps [target]'s [parse_zone(target_zone)]!"))
		log_combat(user, target, "dressed burns in", addition="INTENT: [uppertext(user.a_intent)]")
		burn_wound.sanitization += 3
		burn_wound.flesh_healing += 5
		var/obj/item/bodypart/the_part = target.get_bodypart(target_zone)
		the_part.apply_gauze(tool)
	else
		to_chat(user, span_warning("[target] has no burns there!"))
	return ..()

/datum/surgery_step/dress/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)
