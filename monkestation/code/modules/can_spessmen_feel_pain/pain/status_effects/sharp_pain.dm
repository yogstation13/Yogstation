/// Sharp pain. Used for a lot of pain at once, as a little of it is healed after the effect runs out.
/datum/status_effect/sharp_pain
	id = "sharp_pain"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN|HEAL_WOUNDS|HEAL_STATUS

	/// Amount of pain being given
	var/pain_amount = 0
	/// Type of pain being given
	var/pain_type
	/// The amount of pain we had before recieving the sharp pain
	var/initial_pain_amount = 0
	/// The zone we're afflicting
	var/targeted_zone

/datum/status_effect/sharp_pain/on_creation(
	mob/living/carbon/human/new_owner,
	targeted_zone,
	pain_amount = 0,
	pain_type = BRUTE,
	duration = 0,
)

	src.duration = duration
	src.targeted_zone = targeted_zone
	src.pain_amount = pain_amount
	src.pain_type = pain_type
	return ..()

/datum/status_effect/sharp_pain/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner.pain_controller)
		return FALSE

	if(!targeted_zone || pain_amount == 0)
		return FALSE

	var/obj/item/bodypart/afflicted_bodypart = human_owner.pain_controller.body_zones[targeted_zone]
	if(!afflicted_bodypart)
		return FALSE

	initial_pain_amount = afflicted_bodypart.pain
	human_owner.pain_controller.adjust_bodypart_pain(targeted_zone, pain_amount, pain_type)
	return TRUE

/datum/status_effect/sharp_pain/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/bodypart/afflicted_bodypart = human_owner.pain_controller?.body_zones[targeted_zone]
	if(!afflicted_bodypart)
		return

	var/healed_amount = pain_amount * -0.33
	if((afflicted_bodypart.pain + healed_amount) < initial_pain_amount)
		healed_amount = initial_pain_amount - afflicted_bodypart.pain

	human_owner.pain_controller.adjust_bodypart_pain(targeted_zone, healed_amount, pain_type)
