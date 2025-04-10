//Split into Team List -> Team Details ?
/datum/admins/proc/team_listing()
	var/list/content = list()
	for(var/datum/team/T in GLOB.antagonist_teams)
		content += "<h3>[T.name] - [T.type]</h3>"
		content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=rename_team;team=[REF(T)]'>Rename</a>"
		content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=delete_team;team=[REF(T)]'>Delete</a>"
		content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=communicate;team=[REF(T)]'>Communicate</a>"
		for(var/command in T.get_admin_commands())
			content += "<a href='byond://?src=[REF(T)];command=[command]'>[command]</a>"
		content += "<br>"
		content += "Objectives:<br><ol>"
		for(var/datum/objective/O in T.objectives)
			content += "<li>[O.explanation_text] - <a href='byond://?_src_=holder;[HrefToken()];team_command=remove_objective;team=[REF(T)];tobjective=[REF(O)]'>Remove</a></li>"
		content += "</ol><a href='byond://?_src_=holder;[HrefToken()];team_command=add_objective;team=[REF(T)]'>Add Objective</a><br>"
		content += "Members: <br><ul>"
		for(var/datum/mind/M in T.members)
			content += "<li>[M.name] - <a href='byond://?_src_=holder;[HrefToken()];team_command=remove_member;team=[REF(T)];tmember=[REF(M)]'>Remove Member</a></li>"
		content += "</ul><a href='byond://?_src_=holder;[HrefToken()];team_command=add_member;team=[REF(T)]'>Add Member</a>"
		content += "<hr>"
	content += "<a href='byond://?_src_=holder;[HrefToken()];team_command=create_team'>Create Team</a><br>"
	return content.Join()


/datum/admins/proc/check_teams()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr,"The game hasn't started yet!")
		return

	var/datum/browser/popup = new(usr, "teams", "Team Listing", 500, 500)
	popup.set_content(team_listing())
	popup.open()

/datum/admins/proc/admin_create_team(mob/user)
	var/team_name = stripped_input(user,"Team name ?")
	if(!team_name)
		return
	var/datum/team/T = new()
	T.name = team_name

	message_admins("[key_name_admin(usr)] created new [name] antagonist team.")
	log_admin("[key_name(usr)] created new [name] antagonist team.")

/datum/team/proc/admin_rename(mob/user)
	var/old_name = name
	var/team_name = stripped_input(user,"new team name ?","Team rename",old_name)
	if(!team_name)
		return
	name = team_name
	message_admins("[key_name_admin(usr)] renamed [old_name] team to [name]")
	log_admin("[key_name(usr)] renamed [old_name] team to [name]")

/datum/team/proc/admin_communicate(mob/user)
	var/message = input(user,"Message for the team ?","Team Message") as text|null
	if(!message)
		return
	for(var/datum/mind/M in members)
		to_chat(M.current,message)

	message_admins("[key_name_admin(usr)] messaged [name] team with : [message]")
	log_admin("Team Message: [key_name(usr)] -> [name] team : [message]")

/datum/team/proc/admin_add_objective(mob/user)
	//any antag with get_team == src => add objective to that antag
	//otherwise create new custom antag
	if(!GLOB.admin_objective_list)
		generate_admin_objective_list()

	var/selected_type = input("Select objective type:", "Objective type") as null|anything in GLOB.admin_objective_list
	selected_type = GLOB.admin_objective_list[selected_type]
	if (!selected_type)
		return

	var/datum/objective/O = new selected_type
	O.team = src
	O.admin_edit(user)
	objectives |= O

	var/custom_antag_name

	if(LAZYLEN(members))
		for(var/datum/mind/M in members)
			var/datum/antagonist/team_antag
			for(var/datum/antagonist/A in M.antag_datums)
				if(A.get_team() == src)
					team_antag = A
			if(!team_antag)
				team_antag = new /datum/antagonist/custom
				if(!custom_antag_name)
					custom_antag_name = stripped_input(user, "Custom team antagonist name:", "Custom antag", "Antagonist")
					if(!custom_antag_name)
						custom_antag_name = member_name
				member_name = custom_antag_name
				team_antag.name = member_name
				M.add_antag_datum(team_antag,src)
			antag_path = team_antag.type
	else if(!antag_path)
		custom_antag_name = stripped_input(user, "Custom team antagonist name:", "Custom antag", "Antagonist")
		if(!custom_antag_name)
			custom_antag_name = member_name
		member_name = custom_antag_name
		antag_path = /datum/antagonist/custom

	message_admins("[key_name_admin(usr)] added objective \"[O.explanation_text]\" to [name]")
	log_admin("[key_name(usr)] added objective \"[O.explanation_text]\" to [name]")

/datum/team/proc/admin_remove_objective(mob/user,datum/objective/O)
	objectives -= O

	message_admins("[key_name_admin(usr)] removed objective \"[O.explanation_text]\" from [name]")
	log_admin("[key_name(usr)] removed objective \"[O.explanation_text]\" from [name]")
	//qdel maybe

/datum/team/proc/admin_add_member(mob/user)
	var/list/minds = list()
	for(var/mob/M in GLOB.mob_list)
		if(M.mind)
			minds |= M.mind
	var/datum/mind/value = input("Select new member:", "New team member", null) as null|anything in minds
	if (!value)
		return

	message_admins("[key_name_admin(usr)] added [key_name_admin(value)] as a member of [name] team")
	log_admin("[key_name(usr)] added [key_name(value)] as a member of [name] team")

	if(antag_path)
		var/datum/antagonist/team_antag = new antag_path
		team_antag.name = member_name
		value.add_antag_datum(team_antag, src)
	else
		add_member(value)

/datum/team/proc/admin_remove_member(mob/user,datum/mind/M)
	message_admins("[key_name_admin(usr)] removed [key_name_admin(M)] from [name] team")
	log_admin("[key_name(usr)] removed [key_name(M)] from [name] team")
	if(antag_path)
		M.remove_antag_datum(antag_path)
	remove_member(M)

//After a bit of consideration i block team deletion if there's any members left until unified objective handling is in.
/datum/team/proc/admin_delete(mob/user)
	if(members.len > 0)
		to_chat(user,"Team has members left, remove them first and make sure you know what you're doing.")
		return
	qdel(src)

/datum/team/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			return

/datum/team/proc/get_admin_commands()
	return list()

