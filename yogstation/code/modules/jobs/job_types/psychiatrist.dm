/datum/job/psych
	title = "Psychiatrist"
	flag = PSYCH
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"
	alt_titles = list("Counsellor", "Therapist", "Mentalist")

	outfit = /datum/outfit/job/psych

	minimal_character_age = 24 // "According to age statistics published by the Association of American Medical Colleges, the average age among medical students who matriculated at U.S. medical schools in the 2017-2018 school year was 24"

	added_access = list()
	base_access = list(ACCESS_MEDICAL)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_PSYCHIATRIST

	changed_maps = list("OmegaStation","GaxStation")

/datum/job/psych/proc/OmegaStationChanges()
	return TRUE

/datum/job/psych/proc/GaxStationChanges() // I'M SORRY
	return TRUE

/datum/outfit/job/psych
	name = "Psych"
	jobtype = /datum/job/psych

	shoes = /obj/item/clothing/shoes/sneakers/brown
	uniform = /obj/item/clothing/under/suit_jacket/burgundy
	l_hand = /obj/item/storage/briefcase
	glasses = /obj/item/clothing/glasses/regular
	ears = /obj/item/radio/headset/headset_med
