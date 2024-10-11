/datum/surgery/lobectomy/mechanic
	name = "Prosthesis Lobectomy"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	target_mobtypes = list(/mob/living/carbon/human) // Simpler mobs don't have bodypart types
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/lobectomy,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)
