/datum/surgery/eye_surgery
	requires_bodypart_type = BODYTYPE_ORGANIC

/datum/surgery/eye_surgery/mechanic
	name = "Eye surgery"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	target_mobtypes = list(/mob/living/carbon/human)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/fix_eyes,
		/datum/surgery_step/mechanic_close,
	)
