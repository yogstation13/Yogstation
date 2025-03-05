/datum/surgery/splenorrhaphy
	name = "Splenorrhaphy"
	organ_to_manipulate = ORGAN_SLOT_SPLEEN
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/splenorrhaphy,
		/datum/surgery_step/close,
	)

/datum/surgery/splenorrhaphy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/internal/spleen/target_spleen = target.get_organ_slot(ORGAN_SLOT_SPLEEN)
	if(target_spleen)
		if(target_spleen.damage > 50 && !target_spleen.operated)
			return TRUE
	return FALSE


////it fixes the spleen im not a doctor
//95% chance of success, not 100 because organs are delicate
/datum/surgery_step/splenorrhaphy
	name = "fix damage to spleen (cautery)"
	implements = list(
		TOOL_CAUTERY = 95,
		/obj/item/weldingtool = 55,
		/obj/item/lighter = 35)
	time = 52
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/splenorrhaphy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to cauterize a damaged piece of [target]'s spleen..."),
		span_notice("[user] begins to make an incision in [target]."),
		span_notice("[user] begins to make an incision in [target]."),
	)
	display_pain(target, "Your abdomen burns in horrific stabbing pain!")

/datum/surgery_step/splenorrhaphy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/internal/spleen/target_spleen = target.get_organ_slot(ORGAN_SLOT_SPLEEN)
	human_target.setOrganLoss(ORGAN_SLOT_SPLEEN, 10) //not bad, not great
	if(target_spleen)
		target_spleen.operated = TRUE
	display_results(
		user,
		target,
		span_notice("You successfully cauterize the damaged part of [target]'s spleen."),
		span_notice("[user] successfully cauterizes the damaged part of [target]'s spleen"),
		span_notice("[user] successfully cauterizes the damaged part of [target]'s spleen."),
	)
	display_pain(target, "The pain receeds slightly.")
	return ..()

/datum/surgery_step/splenorrhaphy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	var/mob/living/carbon/human/human_target = target
	human_target.adjustOrganLoss(ORGAN_SLOT_SPLEEN, 15)
	display_results(
		user,
		target,
		span_warning("You burn an artery!! Woops!"),
		span_warning("[user] burns the wrong part of [target]'s spleen!"),
		span_warning("[user] burns the wrong part of [target]'s spleen!"),
	)
	display_pain(target, "You feel a sharp stab inside your abdomen!")
