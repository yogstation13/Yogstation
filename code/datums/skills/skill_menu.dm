/datum/skill_menu
	var/datum/skillset/skillset

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

	var/atom/movable/AM = skillset.get_atom()
	if(isliving(AM))
		data["is_living"] = TRUE
	else
		data["is_living"] = FALSE

	data["skills"] = list()
	for(var/skill_id in GLOB.all_skills)
		var/result = skillset.get_skill(skill_id)
		if(!result)
			continue
		var/datum/skill/skill = result
		var/list/S = list()

		S["name"] = skill.name
		S["id"] = skill.id
		S["desc"] = skill.desc
		S["level"] = skill.current_level
		S["experience"] = skill.experience
		S["is_default"] = skill.difficulty
		S["level_desc"] = skill.level_descriptions[skill.current_level]

		data["skills"] += list(S)

		data["disable_skills"] = skillset.use_skills
		data["experience_mod"] = skillset.experience_modifier

	if(check_rights_for(user.client, R_ADMIN) || isobserver(AM))
		data["admin_mode"] = TRUE
	return data

/datum/skill_menu/ui_act(action, params)
	if(..())
		return
/*
	var/mob/user = usr
	var/atom/movable/AM = skillset.get_atom()

	var/language_name = params["language_name"]
	var/datum/language/language_datum
	for(var/lang in GLOB.all_languages)
		var/datum/language/language = lang
		if(language_name == initial(language.name))
			language_datum = language
	var/is_admin = check_rights_for(user.client, R_ADMIN)

	switch(action)
		if("select_default")
			if(language_datum && AM.can_speak_language(language_datum))
				skillset.selected_language = language_datum
				. = TRUE
		if("grant_language")
			if((is_admin || isobserver(AM)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = input(user,"How do you want to add this language?","[language_datum]",null) as null|anything in choices
				var/spoken = FALSE
				var/understood = FALSE
				switch(choice)
					if("Only Spoken")
						spoken = TRUE
					if("Only Understood")
						understood = TRUE
					if("Both")
						spoken = TRUE
						understood = TRUE
				skillset.grant_language(language_datum, understood, spoken)
				if(is_admin)
					message_admins("[key_name_admin(user)] granted the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] granted the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("remove_language")
			if((is_admin || isobserver(AM)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = input(user,"Which part do you wish to remove?","[language_datum]",null) as null|anything in choices
				var/spoken = FALSE
				var/understood = FALSE
				switch(choice)
					if("Only Spoken")
						spoken = TRUE
					if("Only Understood")
						understood = TRUE
					if("Both")
						spoken = TRUE
						understood = TRUE
				skillset.remove_language(language_datum, understood, spoken)
				if(is_admin)
					message_admins("[key_name_admin(user)] removed the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] removed the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("toggle_omnitongue")
			if(is_admin || isobserver(AM))
				skillset.omnitongue = !skillset.omnitongue
				if(is_admin)
					message_admins("[key_name_admin(user)] [skillset.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that they know) of [key_name_admin(AM)].")
					log_admin("[key_name(user)] [skillset.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that_they know) of [key_name(AM)].")
				. = TRUE
*/
