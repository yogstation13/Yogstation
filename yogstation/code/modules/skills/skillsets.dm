//Skillsets
/datum/skillset
	var/list/skill_list = list()
	var/list/id_skill_list = list()
	var/datum/mind/owner
	var/default_value = SKILLLEVEL_UNSKILLED
	var/skills_transferable = TRUE
	var/use_skills = FALSE
	var/experience_modifier = 1
	var/datum/skill_menu/skill_menu
	var/datum/skill_selection/skill_selection_menu

/datum/skillset/New(var/datum/mind/new_owner)
	owner = new_owner

	// Adds new skills to the representive list
	for(var/current_skill in typesof(/datum/skill))
		var/datum/skill/new_skill = new current_skill(src)
		id_skill_list[new_skill.id] = new_skill
	
	// Just so this is in order
	for(var/current_skill_id in GLOB.all_skill_ids)
		var/datum/skill/current_skill = get_skill(current_skill_id)
		LAZYADD(skill_list, current_skill)
	..()

/datum/skillset/Destroy()
	owner = null
	qdel(skill_menu)
	qdel(skill_selection_menu)
	for(var/datum/skill/current_skill in skill_list)
		// Just in case something messed up very bad we dont delete something important
		if(current_skill.parent == src)
			qdel(current_skill)
	. = ..()

/datum/skillset/proc/Copy(var/datum/skillset/new_skillset, var/datum/mind/new_owner)
	if(isnull(new_skillset))
		new_skillset = new()
	if(!isnull(new_owner))
		new_skillset.owner = new_owner
	new_skillset.set_skill_levels(get_skill_levels(), TRUE)
	return new_skillset

// Gets the skill with the given ID from the representive
/datum/skillset/proc/get_skill(skill_id)
	return id_skill_list[skill_id]

// Simple proc that allows you to set the level for a skill without needing to dig for the datum
/datum/skillset/proc/set_skill_level(skill_id, new_level, var/silent = FALSE)
	return id_skill_list[skill_id].set_level(new_level, silent)

// Same as above but allows you to adjust it instead
/datum/skillset/proc/adjust_skill_level(skill_id, change, var/silent = FALSE)
	return id_skill_list[skill_id].adjust_level(change, silent)

// Gets the skill level of the given ID
/datum/skillset/proc/get_skill_level(skill_id)
	return id_skill_list[skill_id].current_level

// Takes a representive list and applies the levels to all the skills, useful for presets or save data
/datum/skillset/proc/set_skill_levels(var/list/new_skill_list, var/silent = FALSE)
	for(var/skill_id in GLOB.all_skill_ids)
		var/new_skill_value = null
		new_skill_value = new_skill_list?[skill_id]
		if(isnull(new_skill_value))
			new_skill_value = SKILLLEVEL_UNSKILLED
		set_skill_level(skill_id, new_skill_value, silent)

// Returns a representive list of all skill levels for use in the above proc
/datum/skillset/proc/get_skill_levels()
	var/list/temp_skill_list = list()
	for(var/skill_id in GLOB.all_skill_ids)
		temp_skill_list[skill_id] = get_skill(skill_id).current_level
	return temp_skill_list

// Gets the number of remaining skill points
/datum/skillset/proc/get_skill_ballance(var/datum/job/job, var/excluded_skill = null)
	var/used_points = 0
	for(var/datum/skill/S in skill_list)
		if(!(S.id == excluded_skill))
			used_points += S.get_full_cost(job = job)
	var/skillpoints = 0
	if(job.skillpoints)
		skillpoints = job.skillpoints
	skillpoints -= used_points
	return skillpoints

// Checks if the given level can be changed and is within the budget
/datum/skillset/proc/can_change_skill(var/datum/job/job, var/skill, var/skill_level)
	var/datum/skill/changed_skill = get_skill(skill)
	if(isnull(skill_level))
		skill_level = changed_skill.current_level
	if(skill_level > SKILLLEVEL_MASTER || skill_level < SKILLLEVEL_UNSKILLED)
		return FALSE
	var/total_points = get_skill_ballance(job, changed_skill) - changed_skill.get_cost(skill_level, job)
	if(total_points >= 0)
		return TRUE
	return FALSE

// Gets the current body
/datum/skillset/proc/get_atom()
	if(owner)
		return owner.current
	return FALSE

// Opens the skill menu for the given mob
/datum/skillset/proc/open_skill_menu(mob/user)
	if(!skill_menu)
		skill_menu = new (src)
	skill_menu.ui_interact(user)

// Opens the skill selection menu for the given mob
/datum/skillset/proc/open_skill_selection_menu(mob/user)
	if(!skill_selection_menu)
		skill_selection_menu = new (src)
	skill_selection_menu.ui_interact(user)


/mob/living/verb/show_skills()
	set category = "IC"
	set name = "Show Own Skills"

	find_skillset(src)?.open_skill_menu(usr)
