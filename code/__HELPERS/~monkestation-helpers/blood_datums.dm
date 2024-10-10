/proc/random_human_blood_type()
	var/static/list/human_blood_type_weights = list(
		/datum/blood_type/crew/human/o_minus = 4,
		/datum/blood_type/crew/human/o_plus = 36,
		/datum/blood_type/crew/human/a_minus = 28,
		/datum/blood_type/crew/human/a_plus = 3,
		/datum/blood_type/crew/human/b_minus = 20,
		/datum/blood_type/crew/human/b_plus = 1,
		/datum/blood_type/crew/human/ab_minus = 5,
		/datum/blood_type/crew/human/ab_plus = 1
	)

	return pick_weight(human_blood_type_weights)
