/datum/surgery/amputation
	requires_bodypart_type = BODYTYPE_ORGANIC

/datum/surgery/amputation/mechanic
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/saw, //Circular saws are apparently good for cutting metal. Huh. Still Scapels arent though.
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/sever_limb,
	)
