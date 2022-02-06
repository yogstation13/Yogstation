/datum/skill_menu
	var/datum/skillset/skillset
	var/current_skill = SKILL_STRENGHT

/datum/skill_menu/New(_skillset)
	skillset = _skillset

/datum/skill_menu/Destroy()
	skillset = null
	. = ..()

/datum/skill_menu/ui_state(mob/user)
	return GLOB.skill_menu_state

/datum/skill_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillMenu")
		ui.open()

/datum/skill_menu/ui_data(mob/user)
	var/list/data = list()
	var/datum/mind/target = skillset.owner
	data["name"] = target.name
	data["job"] = target.assigned_role
	data["job_title"] = target.role_alt_title
	data["show_job_title"] = target.assigned_role == target.role_alt_title
	if(ishuman(target.current))
		var/mob/living/carbon/human/H = target.current
		data["gender"] = H.gender
		data["species"] = H.dna.species.name
		data["age"] = H.age

	var/atom/movable/AM = skillset.get_atom()
	if(isliving(AM))
		data["is_living"] = TRUE
	else
		data["is_living"] = FALSE

	data["skills"] = list()
	for(var/skill_id in GLOB.all_skill_ids)
		var/list/S = list()
		var/datum/skill/skill = skillset.get_skill(skill_id)

		S["name"] = skill.name
		S["id"] = skill.id
		S["icon"] = skill.icon
		S["desc"] = skill.desc
		S["level"] = skill.current_level
		S["experience"] = skill.experience
		S["difficulty"] = skill.find_active_difficulty()
		S["level_desc"] = skill.level_descriptions[skill.current_level]
		S["selected"] = skill.id == current_skill

		data["skills"] += list(S)

		if(skill.id == current_skill)
			data["current_name"] = skill.name
			data["current_id"] = skill.id
			data["current_icon"] = skill.icon
			data["current_desc"] = skill.desc
			data["current_level"] = skill.current_level
			data["current_experience"] = skill.experience
			data["current_difficulty"] = skill.find_active_difficulty()
			data["current_level_desc"] = skill.level_descriptions[skill.current_level]

	data["disable_skills"] = skillset.use_skills
	data["skill_freeze"] = skillset.experience_modifier == 0

	if(check_rights_for(user.client, R_ADMIN) || isobserver(AM))
		data["admin_mode"] = TRUE
	return data

/datum/skill_menu/ui_act(action, params)
	if(..())
		return
	var/mob/user = usr

	var/datum/skill/skill = skillset.get_skill(current_skill)
	
	var/is_admin = check_rights_for(user.client, R_ADMIN)

	switch(action)
		if("increase_level")
			if(is_admin && !isnull(skill))
				skill.adjust_level(1)
				. = TRUE
		if("decrease_level")
			if(is_admin && !isnull(skill))
				skill.adjust_level(-1)
				. = TRUE
		if("change_current_skill")
			current_skill = params["id"]
			. = TRUE
		if("toggle_use_skills")
			if(is_admin)
				skillset.use_skills = !skillset.use_skills
				. = TRUE
		if("debug_variables_skillset")
			if(is_admin)
				var/client/C = user.client
				C.debug_variables(skillset)
				. = TRUE
		if("reset_skillset")
			if(is_admin)
				var/client/C = user.client
				C.debug_variables(skillset)
				. = TRUE
		if("debug_variables_skill")
			if(is_admin)
				var/client/C = user.client
				C.debug_variables(skill)
				. = TRUE
		if("reset_skillset")
			if(is_admin)
				var/client/C = user.client
				C.debug_variables(skillset)
				. = TRUE
