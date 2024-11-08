/datum/surgery/advanced/pacify
	requires_bodypart_type = BODYTYPE_ORGANIC

/datum/surgery/advanced/pacify/mechanic
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/pacify,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
		)
