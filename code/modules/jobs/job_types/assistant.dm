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
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	alt_titles = list("Intern", "Apprentice", "Subordinate", "Temporary Worker", "Associate")
	default_skill_list = list(
		SKILL_STRENGHT = SKILLLEVEL_BASIC,
		SKILL_DEXTERITY = SKILLLEVEL_BASIC,
		SKILL_ENDURANCE = SKILLLEVEL_BASIC,
		SKILL_BOTANY = SKILLLEVEL_BASIC,
		SKILL_COOKING = SKILLLEVEL_BASIC,
		SKILL_CREATIVITY = SKILLLEVEL_BASIC,
		SKILL_SURVIVAL = SKILLLEVEL_BASIC,
		SKILL_PILOTING = SKILLLEVEL_UNSKILLED,
		SKILL_LEADERSHIP = SKILLLEVEL_UNSKILLED,
		SKILL_FORENSICS = SKILLLEVEL_UNSKILLED,
		SKILL_HAND_TO_HAND = SKILLLEVEL_UNSKILLED,
		SKILL_MELEE_WEAPONS = SKILLLEVEL_UNSKILLED,
		SKILL_RANGED_WEAPONS = SKILLLEVEL_UNSKILLED,
		SKILL_MEDICINE = SKILLLEVEL_BASIC,
		SKILL_ANATOMY = SKILLLEVEL_UNSKILLED,
		SKILL_CHEMISTRY = SKILLLEVEL_UNSKILLED,
		SKILL_PHSYCHOLOGY = SKILLLEVEL_UNSKILLED,
		SKILL_DESIGN = SKILLLEVEL_BASIC,
		SKILL_ROBOTICS = SKILLLEVEL_UNSKILLED,
		SKILL_BIOLOGY = SKILLLEVEL_UNSKILLED,
		SKILL_MECHANICS = SKILLLEVEL_BASIC,
		SKILL_IT = SKILLLEVEL_UNSKILLED,
		SKILL_ATMOSPHERICS = SKILLLEVEL_UNSKILLED)

/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

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
