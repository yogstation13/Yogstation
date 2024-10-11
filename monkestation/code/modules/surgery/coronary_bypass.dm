/datum/surgery/coronary_bypass/mechanic
	name = "Prosthesis Coronary Bypass"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	target_mobtypes = list(/mob/living/carbon/human) // Simpler mobs don't have bodypart types
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/incise_heart,
		/datum/surgery_step/coronary_bypass,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)
