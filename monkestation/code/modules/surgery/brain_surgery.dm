/datum/surgery/brain_surgery
	requires_bodypart_type = BODYTYPE_ORGANIC

/datum/surgery/brain_surgery/mechanic //we need to keep brain surgery despite reboot surgery for the edgecase of stuff like you have a human chest and a robo head
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/fix_brain,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)
