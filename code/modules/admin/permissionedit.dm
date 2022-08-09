/client/proc/edit_admin_permissions()
	set category = "Server"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions"
	if(!check_rights(R_PERMISSIONS))
		return
	new /datum/permissions_panel(usr)

/datum/permissions_panel/New(mob/user)
	ui_interact(user)

/datum/permissions_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		ui = new(user, src, "PermissionsPanel")
		ui.open()

/datum/permissions_panel/ui_data()
	. = GLOB.permissions.pp_data()

/datum/permissions_panel/ui_state(mob/user)
	return GLOB.permissions_state

/datum/permissions_panel/ui_act(action, list/params)
	if(..())
		return
	message_admins("Doing [action] to [params["ckey"]]")
	switch(action)
		if("addNewAdmin")
			GLOB.permissions.add_admin()
			return TRUE
		if("forceSwapAdmin")
			var/ckey = params["ckey"]
			var/adminned_datum = GLOB.permissions.admin_datums[ckey]
			var/deadminned_datum = GLOB.permissions.deadmins[ckey]
			if(adminned_datum)
				force_deadmin(ckey, adminned_datum)
			if(deadminned_datum)
				force_readmin(ckey, deadminned_datum)
			return TRUE
		if("resetMFA")
			var/admin_ckey = params["ckey"]
			if(alert("WARNING! This will reset the 2FA code and backup for [admin_ckey], possibly comprimising the security of the server. Are you sure you wish to continue?", "Confirmation", "Cancel", "Continue") != "Continue")
				return
			if(alert("If you have been requested to reset the MFA credentials for someone, please confirm that you have verified their identity. Resetting MFA for an unverified person can result in a breach of server security.", "Confirmation", "I Understand", "Cancel") != "I Understand")
				return
			message_admins("MFA for [admin_ckey] has been reset by [usr]!")
			log_admin("MFA Reset for [admin_ckey] by [usr]!")
			mfa_reset(admin_ckey)
			return TRUE
		if("editRank")
			GLOB.permissions.edit_rank(params["ckey"])
			return TRUE
		if("editPerms")
			GLOB.permissions.edit_perms(params["ckey"])
			return TRUE
		if("removeAdmin")
			GLOB.permissions.remove_admin(params["ckey"])	
			return TRUE
	

// /datum/admins/proc/edit_admin_permissions(action, target, operation, page)
// 	if(!check_rights(R_PERMISSIONS))
// 		return
// 	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/group/permissions)
// 	asset_cache_datum.send(usr)
// 	var/list/output = list("<link rel='stylesheet' type='text/css' href='[SSassets.transport.get_asset_url("panels.css")]'><a href='?_src_=holder;[HrefToken()];editrightsbrowser=1'>\[Permissions\]</a>")
// 	if(action)
// 		output += " | <a href='?_src_=holder;[HrefToken()];editrightsbrowserlog=1;editrightspage=0'>\[Log\]</a><hr style='background:#000000; border:0; height:3px'>"
// 	else
// 		output += "<br><a href='?_src_=holder;[HrefToken()];editrightsbrowserlog=1;editrightspage=0'>\[Log\]</a>"
// 	if(action == 1)
// 		var/logcount = 0
// 		var/logssperpage = 20
// 		var/pagecount = 0
// 		page = text2num(page)
// 		var/datum/DBQuery/query_count_admin_logs = SSdbcore.NewQuery(
// 			"SELECT COUNT(id) FROM [format_table_name("admin_log")] WHERE (:target IS NULL OR adminckey = :target) AND (:operation IS NULL OR operation = :operation)",
// 			list("target" = target, "operation" = operation)
// 		)
// 		if(!query_count_admin_logs.warn_execute())
// 			qdel(query_count_admin_logs)
// 			return
// 		if(query_count_admin_logs.NextRow())
// 			logcount = text2num(query_count_admin_logs.item[1])
// 		qdel(query_count_admin_logs)
// 		if(logcount > logssperpage)
// 			output += "<br><b>Page: </b>"
// 			while(logcount > 0)
// 				output += "|<a href='?_src_=holder;[HrefToken()];editrightsbrowserlog=1;editrightstarget=[target];editrightsoperation=[operation];editrightspage=[pagecount]'>[pagecount == page ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
// 				logcount -= logssperpage
// 				pagecount++
// 			output += "|"
// 		var/datum/DBQuery/query_search_admin_logs = SSdbcore.NewQuery({"
// 			SELECT
// 				datetime,
// 				round_id,
// 				IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), adminckey),
// 				operation,
// 				IF(ckey IS NULL, target, byond_key),
// 				log
// 			FROM [format_table_name("admin_log")]
// 			LEFT JOIN [format_table_name("player")] ON target = ckey
// 			WHERE (:target IS NULL OR ckey = :target) AND (:operation IS NULL OR operation = :operation)
// 			ORDER BY datetime DESC
// 			LIMIT :skip, :take
// 		"}, list("target" = target, "operation" = operation, "skip" = logssperpage * page, "take" = logssperpage))
// 		if(!query_search_admin_logs.warn_execute())
// 			qdel(query_search_admin_logs)
// 			return
// 		while(query_search_admin_logs.NextRow())
// 			var/datetime = query_search_admin_logs.item[1]
// 			var/round_id = query_search_admin_logs.item[2]
// 			var/admin_key  = query_search_admin_logs.item[3]
// 			operation = query_search_admin_logs.item[4]
// 			target = query_search_admin_logs.item[5]
// 			var/log = query_search_admin_logs.item[6]
// 			output += "<p style='margin:0px'><b>[datetime] | Round ID [round_id] | Admin [admin_key] | Operation [operation] on [target]</b><br>[log]</p><hr style='background:#000000; border:0; height:3px'>"
// 		qdel(query_search_admin_logs)
// 	else if(!action)
// 		output += {"<head>
// 		<meta charset='UTF-8'>
// 		<title>Permissions Panel</title>
// 		<script type='text/javascript' src='[SSassets.transport.get_asset_url("search.js")]'></script>
// 		</head>
// 		<body onload='selectTextField();updateSearch();'>
// 		<div id='main'><table id='searchable' cellspacing='0'>
// 		<tr class='title'>
// 		<th style='width:150px;'>CKEY <a class='small' href='?src=[REF(src)];[HrefToken()];editrights=add'>\[+\]</a></th>
// 		<th style='width:125px;'>RANK</th>
// 		<th style='width:40%;'>PERMISSIONS</th>
// 		</tr>
// 		"}
// 		for(var/adm_ckey in GLOB.permissions.admin_datums+GLOB.permissions.deadmins)
// 			var/datum/admins/D = GLOB.permissions.admin_datums[adm_ckey]
// 			if(!D)
// 				D = GLOB.permissions.deadmins[adm_ckey]
// 				if (!D)
// 					continue
// 			var/deadminlink = ""
// 			if(D.owner)
// 				adm_ckey = D.owner.key
// 			if (D.deadmined)
// 				deadminlink = " <a class='small' href='?src=[REF(src)];[HrefToken()];editrights=activate;key=[adm_ckey]'>\[RA\]</a>"
// 			else
// 				deadminlink = " <a class='small' href='?src=[REF(src)];[HrefToken()];editrights=deactivate;key=[adm_ckey]'>\[DA\]</a>"
// 			output += "<tr>"
// 			output += "<td style='text-align:center;'>[adm_ckey]<br>[deadminlink]<a class='small' href='?src=[REF(src)];[HrefToken()];editrights=remove;key=[adm_ckey]'>\[-\]</a><a class='small' href='?src=[REF(src)];[HrefToken()];editrights=mfareset;key=[adm_ckey]'>\[2FA\]</a></td>"
// 			output += "<td><a href='?src=[REF(src)];[HrefToken()];editrights=rank;key=[adm_ckey]'>[D.rank_name()]</a></td>"
// 			output += "<td><a class='small' href='?src=[REF(src)];[HrefToken()];editrights=permissions;key=[adm_ckey]'>[rights2text(D.rights," ")]</a></td>"
// 			output += "</tr>"
// 		output += "</table></div><div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div></body>"
// 	if(QDELETED(usr))
// 		return
// 	usr << browse("<!DOCTYPE html><html>[jointext(output, "")]</html>","window=editrights;size=1000x650")

// /datum/admins/proc/edit_rights_topic(list/href_list)
// 	if(!check_rights(R_PERMISSIONS))
// 		message_admins("[key_name_admin(usr)] attempted to edit admin permissions without sufficient rights.")
// 		log_admin("[key_name(usr)] attempted to edit admin permissions without sufficient rights.")
// 		return
// 	if(IsAdminAdvancedProcCall())
// 		to_chat(usr, "<span class='admin prefix'>Admin Edit blocked: Advanced ProcCall detected.</span>", confidential=TRUE)
// 		return
// 	if(!owner.mfa_query())
// 		return
// 	var/datum/asset/permissions_assets = get_asset_datum(/datum/asset/simple/namespaced/common)
// 	permissions_assets.send(owner)
// 	var/admin_key = href_list["key"]
// 	var/admin_ckey = ckey(admin_key)
// 	var/datum/admins/D = GLOB.permissions.admin_datums[admin_ckey]
// 	var/task = href_list["editrights"]
// 	if(CONFIG_GET(flag/protect_legacy_admins) && task == "rank")
// 		if(admin_ckey in GLOB.protected_admins)
// 			to_chat(usr, "<span class='admin prefix'>Editing the rank of this admin is blocked by server configuration.</span>", confidential=TRUE)
// 			return
// 	if(task != "add")
// 		D = GLOB.permissions.admin_datums[admin_ckey]
// 		if(!D)
// 			D = GLOB.permissions.deadmins[admin_ckey]
// 		if(!D)
// 			return
// 	switch(task)
// 		if("add")
// 			admin_key = input("New admin's key","Admin key") as text|null
// 			admin_ckey = ckey(admin_key)
// 			if(admin_ckey in GLOB.permissions.admin_datums+GLOB.permissions.deadmins)
// 				to_chat(usr, span_danger("[admin_key] is already an admin."), confidential=TRUE)
// 				return
// 			change_admin_rank(admin_ckey, admin_key, null)
// 		if("remove")
// 			remove_admin(admin_ckey, admin_key, D)
// 		if("rank")
// 			change_admin_rank(admin_ckey, admin_key, D)
// 		if("permissions")
// 			change_admin_flags(admin_ckey, admin_key, D)
// 		if("activate")
// 			force_readmin(admin_key, D)
// 		if("deactivate")
// 			force_deadmin(admin_key, D)
// 		if("mfareset")
// 			if(alert("WARNING! This will reset the 2FA code and backup for [admin_key], possibly comprimising the security of the server. Are you sure you wish to continue?", "Confirmation", "Cancel", "Continue") != "Continue")
// 				return
// 			if(alert("If you have been requested to reset the MFA credentials for someone, please confirm that you have verified their identity. Resetting MFA for an unverified person can result in a break of server security.", "Confirmation", "I Understand", "Cancel") != "I Understand")
// 				return
// 			message_admins("MFA for [admin_ckey] has been reset by [usr]!")
// 			log_admin("MFA Reset for [admin_ckey] by [usr]!")
// 			mfa_reset(admin_ckey)
// 	edit_admin_permissions()

// /datum/admins/proc/add_admin(admin_ckey, admin_key)
// 	if(admin_ckey)
// 		. = admin_ckey
// 	else
// 		admin_key = input("New admin's key","Admin key") as text|null
// 		. = ckey(admin_key)
// 	if(!.)
// 		return FALSE
// 	if(!admin_ckey && (. in GLOB.permissions.admin_datums+GLOB.permissions.deadmins))
// 		to_chat(usr, span_danger("[admin_key] is already an admin."), confidential=TRUE)
// 		return FALSE

// /datum/admins/proc/remove_admin(admin_ckey, admin_key, datum/admins/D)
// 	if(alert("Are you sure you want to remove [admin_ckey]?","Confirm Removal","Do it","Cancel") == "Do it")
// 		GLOB.permissions.admin_datums -= admin_ckey
// 		GLOB.permissions.deadmins -= admin_ckey
// 		if(D)
// 			D.disassociate()
// 		var/m1 = "[key_name_admin(usr)] removed [admin_key] from the admins list temporarily"
// 		var/m2 = "[key_name(usr)] removed [admin_key] from the admins list temporarily"
// 		message_admins(m1)
// 		log_admin(m2)

/datum/permissions_panel/proc/force_readmin(admin_key, datum/admins/D)
	if(!D || !D.deadmined)
		return
	D.activate()
	message_admins("[key_name_admin(usr)] forcefully readmined [admin_key]")
	log_admin("[key_name(usr)] forcefully readmined [admin_key]")

/datum/permissions_panel/proc/force_deadmin(admin_key, datum/admins/D)
	if(!D || D.deadmined)
		return
	message_admins("[key_name_admin(usr)] forcefully deadmined [admin_key]")
	log_admin("[key_name(usr)] forcefully deadmined [admin_key]")
	D.deactivate() //after logs so the deadmined admin can see the message.

/datum/admins/proc/auto_deadmin()
	if(GLOB.permissions.admins.len < CONFIG_GET(number/auto_deadmin_threshold))
		log_admin("[owner] auto-deadmin failed due to low admin count.")
		to_chat(owner, span_userdanger("You have not be auto-deadminned due to lack of admins on the server, you can still deadmin manually."))
		return FALSE
	to_chat(owner, span_interface("You are now a normal player."))
	var/old_owner = owner
	deactivate()
	message_admins("[old_owner] deadmined via auto-deadmin config.")
	log_admin("[old_owner] deadmined via auto-deadmin config.")
	return TRUE

// /datum/admins/proc/change_admin_rank(admin_ckey, admin_key, datum/admins/D)
// 	if(!check_rights(R_PERMISSIONS))
// 		return
// 	var/list/rank_names = list()
// 	rank_names += "*New Rank*"
// 	for(var/R in GLOB.legacy_ranks)
// 		rank_names += R
// 	var/new_rank = input("Please select a rank", "New rank") as null|anything in rank_names
// 	if(new_rank == "*New Rank*")
// 		new_rank = trim(input("Please input a new rank", "New custom rank") as text|null)
// 	if(!new_rank)
// 		return
// 	D.rank_name = new_rank
// 	if(new_rank in GLOB.legacy_ranks)
// 		D.rights = GLOB.legacy_ranks[new_rank]
// 	var/client/C = D.owner
// 	D.disassociate()
// 	D.associate(C)
// 	var/m1 = "[key_name_admin(usr)] edited the admin rank of [admin_key] to [new_rank] temporarily"
// 	var/m2 = "[key_name(usr)] edited the admin rank of [admin_key] to [new_rank] temporarily"
// 	message_admins(m1)
// 	log_admin(m2)

// /datum/admins/proc/change_admin_flags(admin_ckey, admin_key, datum/admins/D)
// 	var/new_flags = input_bitfield(usr, "Permission flags<br>This will affect only the current admin [admin_key]", "admin_flags", D.rights, 350, 590)
// 	if(isnull(new_flags))
// 		return
// 	var/m1 = "[key_name_admin(usr)] edited the permissions of [admin_key] temporarily"
// 	var/m2 = "[key_name(usr)] edited the permissions of [admin_key] temporarily"
// 	D.rights = new_flags
// 	var/client/C = D.owner
// 	D.disassociate()
// 	D.associate(C)
// 	message_admins(m1)
// 	log_admin(m2)
