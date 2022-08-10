/datum/permissions_controller/forums
	/// Admins from the forums
	var/list/forums_admins = list()

	/// Admins who are overriden for this round
	var/list/overrides = list()

/datum/permissions_controller/forums/clear_admins()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	forums_admins.Cut()
	overrides.Cut()

/datum/permissions_controller/forums/_load_permissions_for(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(C.ckey in overrides)
		return ..()

	forums_admins -= C.ckey // In case they have been demoted since last login

	var/permissions = query_permissions_for(C.ckey)
	
	if(permissions)
		forums_admins[C.ckey] = permissions
		new /datum/admins(C.ckey, permissions["rights"])
		return TRUE

	return ..()

/// Queries forums to find permissions
/datum/permissions_controller/forums/proc/query_permissions_for(ckey)
	if(!CONFIG_GET(string/xenforo_key))
		CRASH("Trying to load forums permisisons without xenforo key")

	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/apiurl)]/linking/byond/[ckey]", "", list("XF-Api-Key" = CONFIG_GET(string/xenforo_key)))
	req.begin_async()

	UNTIL(req.is_complete())
	
	var/datum/http_response/response = req.into_response()
	var/list/body = json_decode(response.body)
	if(!body["success"])
		return FALSE
	
	var/flags = 0
	var/list/permissions = body["user"]["permissions"]
	for(var/permission in permissions)
		var/list/parts = splittext(permission, ".")
		if(parts[1] != "ingame")
			continue
		var/newflag = admin_keyword_to_flag(parts[2])
		if(!newflag)
			stack_trace("WARNING: Permission \"[parts[2]]\" not found.")
		flags |= newflag
	if(flags)
		return list("rank" = body["display_group"]["title"], "rights" = flags)
	else
		return FALSE

/datum/permissions_controller/forums/get_rights_for_ckey(ckey)
	. = ..()
	if(.)
		return
	if(!(ckey in overrides) && (ckey in forums_admins))
		return forums_admins[ckey]["rights"]

/datum/permissions_controller/forums/get_rank_name(client/subject)
	. = ..()
	if(.)
		return
	if(!(subject.ckey in overrides) && (subject.ckey in forums_admins))
		return forums_admins[subject.ckey]["rank"]

/datum/permissions_controller/forums/pp_data(mob/user)
	. = ..()
	for(var/admin in forums_admins)
		if(admin in overrides)
			continue
		var/data = list()
		data["ckey"] = admin
		data["rank"] = forums_admins[admin]["rank"]
		data["rights"] = rights2text(forums_admins[admin]["rights"], seperator = " ")
		data["deadminned"] = (admin in deadmins) 
		data["protected_rank"] = TRUE
		.["admins"] |= list(data)

/datum/permissions_controller/forums/should_add_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(!..())
		return FALSE
	if(ckey in overrides)
		return TRUE
	return !query_permissions_for(ckey)

/datum/permissions_controller/forums/edit_rank(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(..())
		return TRUE

	if((ckey in forums_admins) && !(ckey in overrides))
		if(alert("Forums permissions cannot be edited from this panel. Would you like to add an override for this round?", "Confirmation", "Yes", "No") != "Yes")
			return TRUE
		if(set_legacy_rank(ckey))
			overrides += ckey
		return TRUE
	return FALSE

/datum/permissions_controller/forums/edit_perms(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(..())
		return TRUE
	
	if((ckey in forums_admins) && !(ckey in overrides))
		to_chat(usr, "Permissions for forums ranks cannot be edited in game. To temporarily modify a users permissions first give them a temporary rank.", confidential = TRUE)
		return TRUE
	
	return FALSE

/datum/permissions_controller/forums/remove_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(..())
		return TRUE
	
	if((ckey in forums_admins) && !(ckey in overrides))
		if(alert("Forums permissions cannot be edited from this panel. Would you like to demote for this round?", "Confirmation", "Yes", "No") != "Yes")
			return TRUE
		overrides += ckey
		forums_admins -= ckey
		if(ckey in admin_datums)
			qdel(admin_datums[ckey])
		if(ckey in deadmins)
			qdel(deadmins[ckey])
		return TRUE
	return FALSE
