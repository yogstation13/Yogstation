/*
Assistant
*/
/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	added_access = list()			//See /datum/job/assistant/get_access()
	base_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	minimal_character_age = 18 //Would make it even younger if I could because this role turns men into little brat boys and likewise for the other genders

	alt_titles = list("Intern", "Apprentice", "Subordinate", "Temporary Worker", "Associate")

/datum/job/assistant/get_access()
	. = ..()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. |= list(ACCESS_MAINT_TUNNELS)

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	if (CONFIG_GET(flag/grey_assistants))
		uniform = /obj/item/clothing/under/color/grey
		uniform_skirt = /obj/item/clothing/under/skirt/color/grey
	else
		uniform = /obj/item/clothing/under/color/random
		uniform_skirt = /obj/item/clothing/under/skirt/color/random
	return ..()
