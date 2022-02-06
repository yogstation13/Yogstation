//Skillsets
/datum/skillset
	var/list/skill_list = list()
	var/datum/mind/owner
	var/default_value = SKILLLEVEL_UNSKILLED
	var/skills_transferable = TRUE
	var/use_skills = FALSE
	var/experience_modifier = 1
	var/datum/skill_menu/skill_menu

/datum/skillset/New(var/datum/mind/new_owner)
	owner = new_owner

	skill_list = list(
		SKILL_STRENGHT = new /datum/skill/strength,
		SKILL_DEXTERITY = new /datum/skill/dexterity,
		SKILL_ENDURANCE = new /datum/skill/endurance,
		SKILL_BOTANY = new /datum/skill/botany,
		SKILL_COOKING = new /datum/skill/cooking,
		SKILL_CREATIVITY = new /datum/skill/creativity,
		SKILL_SURVIVAL = new /datum/skill/survival,
		SKILL_PILOTING = new /datum/skill/piloting,
		SKILL_LEADERSHIP = new /datum/skill/leadership,
		SKILL_FORENSICS = new /datum/skill/forensics,
		SKILL_HAND_TO_HAND = new /datum/skill/hand_to_hand,
		SKILL_MELEE_WEAPONS = new /datum/skill/melee,
		SKILL_RANGED_WEAPONS = new /datum/skill/ranged,
		SKILL_MEDICINE = new /datum/skill/medicine,
		SKILL_ANATOMY = new /datum/skill/anatomy,
		SKILL_CHEMISTRY = new /datum/skill/chemistry,
		SKILL_PHSYCHOLOGY = new /datum/skill/psychology,
		SKILL_DESIGN = new /datum/skill/design,
		SKILL_ROBOTICS = new /datum/skill/robotics,
		SKILL_BIOLOGY = new /datum/skill/biology,
		SKILL_MECHANICS = new /datum/skill/mechanics,
		SKILL_IT = new /datum/skill/it,
		SKILL_ATMOSPHERICS = new /datum/skill/atmospherics
	)

	for(var/current_item in GLOB.all_skill_ids)
		var/datum/skill/current_skill = skill_list[current_item]
		current_skill.parent = src

	skill_menu = new(src)
	..()

/datum/skillset/Destroy()
	owner = null
	. = ..()

/datum/skillset/proc/get_skill(skill_id)
	return skill_list[skill_id]

/datum/skillset/proc/set_skill_level(skill_id, new_level, var/silent = FALSE)
	return skill_list[skill_id].set_level(new_level, silent)

/datum/skillset/proc/adjust_skill_level(skill_id, change, var/silent = FALSE)
	return skill_list[skill_id].adjust_level(change, silent)

/datum/skillset/proc/get_skill_level(skill_id)
	return skill_list[skill_id].current_level

/datum/skillset/proc/set_skill_list(skill_id, var/list/skill_list, var/silent = FALSE)
	set_skill_level(skill_id, skill_list[skill_id], silent)

/datum/skillset/proc/set_skill_levels(var/list/skill_list, var/silent = FALSE)
	for(var/skill_id in GLOB.all_skill_ids)
		var/new_skill_value = null
		new_skill_value = skill_list?[skill_id]
		if(isnull(new_skill_value))
			new_skill_value = SKILLLEVEL_UNSKILLED
		message_admins(isnull(new_skill_value))
		set_skill_level(skill_id, new_skill_value, silent)

/datum/skillset/proc/get_skill_levels()
	var/list/skill_list = list()
	for(var/skill_id in GLOB.all_skill_ids)
		skill_list[skill_id] = get_skill(skill_id)
	return skill_list

/datum/skillset/proc/open_skill_menu(mob/user)
	if(!skill_menu)
		skill_menu = new (src)
	skill_menu.ui_interact(user)

/datum/skillset/proc/get_atom()
	if(owner)
		return owner.current
	return FALSE

// Show skills verb
/*
/mob/living/verb/show_skills()
	set category = "IC"
	set name = "Show Own Skills"

	skillset.open_ui()

/obj/machinery/autolathe/ui_interact(mob/user, datum/tgui/ui)

/datum/skillset/ui_data(mob/user)

/obj/machinery/autolathe/ui_act(action, params)
	if(..())
		return
*/
