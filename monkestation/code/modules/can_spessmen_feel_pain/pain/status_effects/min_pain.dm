/// A handler for temporarily increasing the minimum amount of pain a bodypart can be in.
/datum/status_effect/minimum_bodypart_pain
	id = "min_bodypart_pain"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN|HEAL_WOUNDS|HEAL_STATUS

	/// The min pain we're setting the bodypart to
	var/min_amount = 0
	/// The zone we're afflicting
	var/targeted_zone = BODY_ZONE_CHEST

/datum/status_effect/minimum_bodypart_pain/on_creation(
	mob/living/carbon/human/new_owner,
	targeted_zone,
	min_amount = 0,
	duration = 0,
)

	src.duration = duration
	src.targeted_zone = targeted_zone
	src.min_amount = min_amount
	return ..()

/datum/status_effect/minimum_bodypart_pain/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner.pain_controller)
		return FALSE

	if(!targeted_zone || min_amount == 0)
		return FALSE

	var/obj/item/bodypart/afflicted_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	if(!afflicted_bodypart)
		return FALSE

	human_owner.pain_controller.adjust_bodypart_min_pain(targeted_zone, min_amount)
	return TRUE

/datum/status_effect/minimum_bodypart_pain/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/afflicted_bodypart = human_owner.pain_controller?.body_zones[targeted_zone]
	if(!afflicted_bodypart)
		return

	human_owner.pain_controller.adjust_bodypart_min_pain(targeted_zone, -min_amount)
