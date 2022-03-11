SUBSYSTEM_DEF(skills)
	name = "Skills"
	flags = SS_NO_FIRE
	var/list/skills = list()
	var/list/skills_by_cat = list()
	var/list/skill_lists = list()

/datum/controller/subsystem/skills/Initialize()
	create_skilllists()
	return ..()

/datum/controller/subsystem/skills/proc/create_skilllists()
	// Creates the skills list
	var/list/temp_skill_list = list()
	for(var/skill_path in typesof(/datum/skill))
		if(skill_path == /datum/skill)
			continue
		var/datum/skill/new_skill = new skill_path()
		if(temp_skill_list[new_skill.id])
			var/datum/skill/other_skill = temp_skill_list[new_skill.id]
			CRASH("Two skills ([new_skill.type] and [other_skill.type]) have the same ID. Skipping [new_skill.type].")
			qdel(new_skill)
			continue
		temp_skill_list[new_skill.id] = new_skill
	if(!temp_skill_list || !temp_skill_list.len)
		to_chat(world, span_boldannounce("Error setting up skills, no skill datums found"))
	
	// Sorts them
	for(var/skill_id in GLOB.all_skill_ids)
		if(!temp_skill_list?[skill_id])
			CRASH("Skill ID [skill_id] is unused, but is in GLOB.all_skill_ids.")
			continue
		var/datum/skill/current_skill = temp_skill_list[skill_id]
		skills[current_skill.id] = current_skill
		LAZYREMOVE(temp_skill_list, skill_id)
	if(temp_skill_list && temp_skill_list.len)
		var/unsorted_skills = ""
		for(var/skill_id in temp_skill_list)
			var/datum/skill/current_skill = temp_skill_list[skill_id]
			skills[current_skill.id] = current_skill
			unsorted_skills += current_skill.type + " "
		unsorted_skills = replacetext(unsorted_skills," ","",-1)
		testing("Some skills ([unsorted_skills]) are unsorted.")
	
	// Creates the skills_by_cat list
	for(var/skill_id in skills)
		var/datum/skill/current_skill = skills[skill_id]
		var/current_cat = current_skill.catagory
		if(!skills_by_cat?[current_cat])
			skills_by_cat[current_cat] = list()
		LAZYADD(skills_by_cat[current_cat], current_skill.id)
	
	//Skill Lists
	for(var/skill_level in GLOB.all_skill_levels)
		if(!GLOB.skill_level_to_text?[skill_level])
			CRASH("A skill level ([skill_level]) is missing a text to go along with it. Skipping.")
			continue
		var/entry_title = "All [GLOB.skill_level_to_text[skill_level]]"

		var/list/temp_skilllist = list()
		for(var/skill_id in skills)
			temp_skilllist[skill_id] = skill_level
		
		skill_lists[entry_title] = temp_skilllist
