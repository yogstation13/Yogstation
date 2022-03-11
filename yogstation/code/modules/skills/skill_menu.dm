/datum/skill_menu
	var/datum/skillset/skillset
	var/current_skill = SKILL_STRENGTH

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
	for(var/datum/skill/skill in skillset.skill_list)
		var/list/S = list()

		S["name"] = skill.name
		S["id"] = skill.id
		S["icon"] = skill.icon
		S["desc"] = skill.desc
		S["level"] = skill.current_level
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
	var/client/user_client = user.client
	var/datum/mind/target_mind = skillset.owner
	var/mob/target_mob = target_mind.current
	var/client/target_client = target_mob.client
	var/datum/preferences/target_prefs = target_client.prefs

	var/datum/skill/skill = skillset.get_skill(current_skill)
	
	var/is_admin = check_rights_for(user.client, R_ADMIN)

	switch(action)
		if("increase_level")
			if(is_admin && !isnull(skill))
				skill.adjust_level(1)
				log_admin("[key_name(user)] increased [key_name(target_mob)]'s skill in [current_skill].")
				. = TRUE
		if("decrease_level")
			if(is_admin && !isnull(skill))
				skill.adjust_level(-1)
				log_admin("[key_name(user)] decrease [key_name(target_mob)]'s skill in [current_skill].")
				. = TRUE
		if("change_current_skill")
			current_skill = params["id"]
			. = TRUE
		if("toggle_use_skills")
			if(is_admin)
				skillset.use_skills = !skillset.use_skills
				log_admin("[key_name(user)] [skillset.use_skills ? "enabled" : "disabled"] skills for [key_name(target_mob)].")
				message_admins(span_adminnotice("[key_name_admin(user)] [skillset.use_skills ? "enabled" : "disabled"] skills for [ADMIN_LOOKUPFLW(target_mob)]."))
				. = TRUE
		if("debug_variables_skillset")
			if(is_admin)
				user_client.debug_variables(skillset)
				. = TRUE
		if("reset_skillset")
			if(is_admin && target_mind && target_mind && target_prefs)
				if(target_mind.assigned_role in target_prefs.job_skills)
					skillset.set_skill_levels(target_prefs.job_skills[target_mind.assigned_role])
				else
					var/datum/job/job_datum = SSjob.name_occupations_all[target_mind.assigned_role]
					skillset.set_skill_levels(job_datum.default_skill_list)
				log_admin("[key_name(user)] reset the skillset of [key_name(target_mob)].")
				message_admins(span_adminnotice("[key_name_admin(user)] reset the skillset of [ADMIN_LOOKUPFLW(target_mob)]."))
				. = TRUE
		if("set_skill_levels")
			if(is_admin)
				var/silent = FALSE
				var/list/skill_list = skillset.get_skill_levels()
				var/list/options = list("Job Default...", "Player Skill Lists...", "Your Skill Lists...", "Original")
				if(!target_prefs)
					options.Remove("Player Skill Lists...", "Original")
				options += SSskills.skill_lists
				var/choice = input("Select skill list", "Super skill trainer") as null|anything in options
				choice = sanitize_inlist(choice, options)
				switch(choice)
					if("Job Default...")
						var/job_choice = input("Select job skill list", "Super skill trainer") as null|anything in SSjob.name_occupations_all
						if(job_choice in SSjob.name_occupations_all)
							var/datum/job/job_datum = SSjob.name_occupations_all[job_choice]
							skill_list = job_datum.default_skill_list
					if("Player Skill Lists...")
						var/job_choice = input("Select job skill list", "Super skill trainer") as null|anything in target_prefs.job_skills
						if(job_choice in target_prefs.job_skills)
							skill_list = target_prefs.job_skills[job_choice]
					if("Your Skill Lists...")
						var/datum/preferences/user_prefs = user_client.prefs
						var/job_choice = input("Select job skill list", "Super skill trainer") as null|anything in user_prefs.job_skills
						if(job_choice in user_prefs.job_skills)
							skill_list = user_prefs.job_skills[job_choice]
					if("Original")
						if(target_mind.assigned_role in target_prefs.job_skills)
							skill_list = target_prefs.job_skills[target_mind.assigned_role]
				
				if(choice in SSskills.skill_lists)
					skill_list = SSskills.skill_lists[choice]

				skillset.set_skill_levels(skill_list, silent)
				. = TRUE
		if("debug_variables_skill")
			if(is_admin)
				user_client.debug_variables(skill)
				. = TRUE



/datum/skill_selection
	var/datum/skillset/skillset
	var/current_job = "Assistant"
	var/datum/preferences/pref

/datum/skill_selection/New(_skillset, _pref)
	skillset = _skillset
	pref = _pref

/datum/skill_selection/Destroy()
	skillset = null
	. = ..()

/datum/skill_selection/proc/save_changes()
	pref.job_skills[current_job] = skillset.get_skill_levels()

/datum/skill_selection/ui_state(mob/user)
	return GLOB.skill_selection_menu_state

/datum/skill_selection/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillSelectionMenu")
		ui.open()

/datum/skill_selection/ui_data(mob/user)
	var/list/data = list()

	data["currentJob"] = current_job
	var/list/job_name_list = list()
	for(var/datum/job/current_job_datum in SSjob.occupations)
		if(current_job_datum.uses_skills)
			LAZYADD(job_name_list, current_job_datum.title)
	data["jobs"] = job_name_list
	data["skills"] = list()
	var/datum/job/job_datum = SSjob.name_occupations_all[current_job]
	data["skillBalance"] = skillset.get_skill_ballance(job_datum)
	data["maxSkillPoints"] = job_datum.skillpoints
	
	for(var/datum/skill/skill in skillset.skill_list)
		var/list/skill_data = list()

		skill_data["name"] = skill.name
		skill_data["id"] = skill.id
		skill_data["icon"] = skill.icon
		skill_data["desc"] = skill.desc
		skill_data["level"] = skill.current_level
		skill_data["difficulty"] = skill.find_active_difficulty(current_job)
		skill_data["level_desc"] = skill.level_descriptions[skill.current_level]
		skill_data["cost"] = skill.get_full_cost(skill.current_level, current_job)
		skill_data["canDecrease"] = FALSE
		skill_data["canIncrease"] = FALSE
		if(skillset.can_change_skill(job_datum, skill.id, skill.current_level - 1))
			skill_data["costDecrease"] = -skill.get_cost(skill.current_level, current_job)
			skill_data["canDecrease"] = TRUE
		
		if(skillset.can_change_skill(job_datum, skill.id, skill.current_level + 1))
			skill_data["costIncrease"] = skill.get_cost(skill.current_level + 1, current_job)
			skill_data["canIncrease"] = TRUE

		data["skills"] += list(skill_data)

	data["disable_skills"] = skillset.use_skills
	data["skill_freeze"] = skillset.experience_modifier == 0
	return data

/datum/skill_selection/ui_act(action, params)
	if(..())
		return
	var/datum/job/job_datum = SSjob.name_occupations_all[current_job]
	var/mob/user = usr

	switch(action)
		if("increaseLevel")
			var/datum/skill/skill = skillset.get_skill(params["id"])
			if(skillset.can_change_skill(job_datum, skill.id, skill.current_level + 1))
				skillset.adjust_skill_level(params["id"], 1, TRUE)
				save_changes()
				. = TRUE
			else

		if("decreaseLevel")
			var/datum/skill/skill = skillset.get_skill(params["id"])
			if(skillset.can_change_skill(job_datum, skill.id, skill.current_level - 1))
				skillset.adjust_skill_level(params["id"], -1, TRUE)
				save_changes()
				. = TRUE

		if("changeCurrentJob")
			save_changes()
			var/new_job = params["job"]
			current_job = new_job
			job_datum = SSjob.name_occupations_all[new_job]
			var/list/new_skilllist = pref.job_skills[new_job]
			if(isnull(new_skilllist))
				new_skilllist = job_datum.default_skill_list
			skillset.set_skill_levels(new_skilllist, TRUE)
			. = TRUE
/*
		if("resetToLastSave")
			var/old_skilllist
			READ_FILE(S["job_skills"], old_skilllist)
			skillset.set_skill_levels(old_skilllist[current_job], TRUE)
			save_changes()
			. = TRUE
*/
		if("resetToJobDefault")
			skillset.set_skill_levels(job_datum.default_skill_list, TRUE)
			save_changes()
			. = TRUE

		if("openVV")
			var/client/C = user.client
			C.debug_variables(skillset)
			C.debug_variables(pref)
			. = TRUE
