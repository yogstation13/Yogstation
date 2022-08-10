/datum/permissions_controller/db
	var/list/dbranks = list()
	var/list/dbadmins = list()

/datum/permissions_controller/db/clear_admins()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	dbranks.Cut()
	dbadmins.Cut()

/datum/permissions_controller/db/load_admins()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	. = ..()

	if(!SSdbcore.Connect())
		message_admins("Failed to connect to database to load admins.")
		log_sql("Failed to connect to database to load admins")
		return
	
	var/datum/DBQuery/query_load_admin_ranks = SSdbcore.NewQuery("SELECT rank, flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")]")
	if(!query_load_admin_ranks.Execute())
		message_admins("Error loading admin ranks from database.")
		log_sql("Error loading admin ranks from database.")
	else
		while(query_load_admin_ranks.NextRow())
			var/rank_name = trim(query_load_admin_ranks.item[1])
			var/rank_flags = text2num(query_load_admin_ranks.item[2])
			var/rank_exclude_flags = text2num(query_load_admin_ranks.item[3])
			var/rank_can_edit_flags = text2num(query_load_admin_ranks.item[4])
			dbranks[rank_name] = list("flags" = rank_flags & (~rank_exclude_flags), "can_edit_flags" = rank_can_edit_flags)
	qdel(query_load_admin_ranks)

	var/datum/DBQuery/query_load_admins = SSdbcore.NewQuery("SELECT ckey, rank FROM [format_table_name("admin")] ORDER BY rank")
	if(!query_load_admins.Execute())
		message_admins("Error loading admins from database. Loading from backup.")
		log_sql("Error loading admins from database. Loading from backup.")
	else
		while(query_load_admins.NextRow())
			var/admin_ckey = ckey(query_load_admins.item[1])
			var/admin_rank = trim(query_load_admins.item[2])
			if(dbranks[admin_rank] == null)
				message_admins("[admin_ckey] loaded with invalid admin rank [admin_rank].")
				continue
			if(admin_ckey in legacy_admins)
				continue
			dbadmins[admin_ckey] = admin_rank
	qdel(query_load_admins)

/datum/permissions_controller/db/_load_permissions_for(var/client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(..())
		return TRUE
	
	var/rank = dbadmins[C.ckey]
	if(!rank)
		return FALSE
	var/rights = dbranks[rank]
	if(!rights)
		return FALSE
	new /datum/admins(C.ckey, rights["flags"])
	return TRUE

/datum/permissions_controller/db/get_rights_for_ckey(ckey)
	. = ..()
	if(.)
		return

	var/rank = dbadmins[ckey]
	if(!rank)
		return
	var/rights = dbranks[rank]
	if(!rights)
		return
	else
		return rights["flags"]

/datum/permissions_controller/db/get_rank_name(client/subject)
	. = ..()
	if(.)
		return
	if(subject.ckey in dbadmins)
		return dbadmins[subject.ckey]

/datum/permissions_controller/db/pp_data(mob/user)
	. = ..()
	var/perm_rights = check_rights_for(user.client, R_PERSIST_PERMS)
	var/grant_flags = 0
	if(user.ckey in legacy_admins)
		grant_flags = legacy_ranks[legacy_admins[user.ckey]] || 0
	else if(user.ckey in dbadmins)
		var/dbrank = dbadmins[user.ckey]
		if(dbranks[dbrank])
			grant_flags = dbranks[dbrank]["can_edit_flags"]
	for(var/admin in dbadmins)
		var/data = list()
		data["ckey"] = admin
		data["rank"] = dbadmins[admin]
		var/rights_text = "Rights: [rights2text(dbranks[data["rank"]]["flags"], " ")]\nGrant Rights: [rights2text(dbranks[data["rank"]]["can_edit_flags"], " ", "*")]"
		data["rights"] = rights_text
		data["deadminned"] = (admin in deadmins)
		data["protected_admin"] = (dbranks[data["rank"]]["flags"] & grant_flags) != dbranks[data["rank"]]["flags"]
		data["protected_rank"] = !perm_rights || data["protected_admin"]
		.["admins"] |= list(data)

/datum/permissions_controller/db/should_add_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(!..())
		return FALSE
	return !(ckey in dbadmins)

/// Sets a rank in the DB
/// Returns true of the rank was set
/datum/permissions_controller/db/proc/set_db_rank(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	
	var/grant_flags = 0
	if(usr.ckey in legacy_admins)
		grant_flags = legacy_ranks[legacy_admins[usr.ckey]] || 0
	else if(usr.ckey in dbadmins)
		var/dbrank = dbadmins[usr.ckey]
		if(dbranks[dbrank])
			grant_flags = dbranks[dbrank]["can_edit_flags"]

	if((ckey in dbadmins) && (dbadmins[ckey] in dbranks) && (dbranks[dbadmins[ckey]]["flags"] & grant_flags) != dbranks[dbadmins[ckey]]["flags"])
		return FALSE

	var/list/ranks = list()
	ranks += "*New Rank*"
	for(var/rank in dbranks)
		var/flags = dbranks[rank]["flags"]
		if((flags & grant_flags) == flags)
			ranks += rank
	
	var/new_rank = input("Please select a rank", "New rank") as null|anything in ranks
	if(new_rank == "*New Rank*")
		new_rank = trim(input("Please input a new rank", "New custom rank") as text|null)
	if(!new_rank)
		return FALSE
	
	if(!(new_rank in dbranks))
		var/current_flags = list("flags" = 0, "can_edit_flags" = 0)
		if((ckey in dbadmins) && (dbadmins[ckey] in dbranks))
			current_flags = dbranks[dbadmins[ckey]]
		dbranks[new_rank] = current_flags
		var/datum/DBQuery/query_add_rank = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_ranks")] (`rank`, flags, exclude_flags, can_edit_flags)
			VALUES (:new_rank, :flags, '0', :edit_flags) ON DUPLICATE KEY UPDATE
		"}, list("new_rank" = new_rank, "flags" = current_flags["flags"], "edit_flags" = current_flags["can_edit_flags"]))
		if(!query_add_rank.warn_execute())
			qdel(query_add_rank)
			return
		qdel(query_add_rank)
		var/datum/DBQuery/query_add_rank_log = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
			VALUES (:time, :round_id, :adminckey, INET_ATON(:adminip), 'add rank', :new_rank, CONCAT('New rank added: ', :new_rank))
		"}, list("time" = SQLtime(), "round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "new_rank" = new_rank))
		if(!query_add_rank_log.warn_execute())
			qdel(query_add_rank_log)
			return
		qdel(query_add_rank_log)
	var/old_rank = dbadmins[ckey] || "NEW ADMIN"
	dbadmins[ckey] = new_rank
	var/datum/DBQuery/query_change_rank = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("admin")] (`rank`, ckey) VALUES(:new_rank, :admin_ckey)",
		list("new_rank" = new_rank, "admin_ckey" = ckey)
	)
	if(!query_change_rank.warn_execute())
		qdel(query_change_rank)
		return
	qdel(query_change_rank)
	var/datum/DBQuery/query_change_rank_log = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
		VALUES (:time, :round_id, :adminckey, INET_ATON(:adminip), 'change admin rank', :target, CONCAT('Rank of ', :target, ' changed from ', :old_rank, ' to ', :new_rank))
	"}, list("time" = SQLtime(), "round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "target" = ckey, "old_rank" = old_rank, "new_rank" = new_rank))
	if(!query_change_rank_log.warn_execute())
		qdel(query_change_rank_log)
		return
	qdel(query_change_rank_log)
	var/datum/admins/holder = admin_datums[ckey]
	if(holder)
		holder.deactivate()
		holder.activate()
	return TRUE

/datum/permissions_controller/db/make_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	var/permanent = (SSdbcore.Connect() && check_rights(R_PERSIST_PERMS, FALSE) && (alert("Permanent changes are saved to the database for future rounds, temporary changes will affect only the current round", "Permanent or Temporary?", "Permanent", "Temporary", "Cancel") == "Permanent"))
	if(!permanent)
		return ..()

	set_db_rank(ckey)
	return TRUE

/datum/permissions_controller/db/edit_rank(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(..())
		return TRUE

	if(!(ckey in dbadmins))
		return FALSE
	
	var/permanent = ((ckey in dbadmins) && SSdbcore.Connect() && check_rights(R_PERSIST_PERMS, FALSE) && (alert("Permanent changes are saved to the database for future rounds, temporary changes will affect only the current round", "Permanent or Temporary?", "Permanent", "Temporary", "Cancel") == "Permanent"))
	if(!permanent)
		if(set_legacy_rank(ckey))
			dbadmins -= ckey
		return TRUE
	
	set_db_rank(ckey)

	return TRUE

/datum/permissions_controller/db/edit_perms(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(..())
		return TRUE
	
	if(!(ckey in dbadmins))
		return FALSE
	
	if(!SSdbcore.Connect())
		to_chat(usr, "Cannot connect to database to edit rank [dbadmins[ckey]]", confidential = TRUE)
		return TRUE
	
	if(!check_rights(R_PERSIST_PERMS, FALSE))
		to_chat(usr, "You do not have access to modify this rank.")
		return TRUE
	
	var/grant_flags = 0
	if(usr.ckey in legacy_admins)
		grant_flags = legacy_ranks[legacy_admins[usr.ckey]] || 0
	else if(usr.ckey in dbadmins)
		var/dbrank = dbadmins[usr.ckey]
		if(dbranks[dbrank])
			grant_flags = dbranks[dbrank]["can_edit_flags"]

	if(!((dbadmins[ckey] in dbranks) && (dbranks[dbadmins[ckey]]["flags"] & grant_flags) == dbranks[dbadmins[ckey]]["flags"]))
		to_chat(usr, "You do not have access to modify this rank.")
		return TRUE

	if(alert(usr, "This rank cannot be modified temporarily, and modifying it will change all admins using this rank. Do you wish to continue?", "Confirmation", "Yes", "No") != "Yes")
		return TRUE

	var/rank = dbranks[dbadmins[ckey]]

	var/new_flags = input_bitfield(usr, "Permission flags<br>This will affect ALL admins with this rank.", "admin_flags", rank["flags"], 350, 590, allowed_edit_list = grant_flags)
	if(isnull(new_flags))
		return
	
	var/new_can_edit_flags = input_bitfield(usr, "Editable permission flags<br>These are the flags this rank is allowed to edit if they have access to the permissions panel.<br>They will be unable to modify admins to a rank that has a flag not included here.<br>This will affect ALL admins with this rank.", "admin_flags", rank["can_edit_flags"], 350, 710, grant_flags)
	if(isnull(new_can_edit_flags))
		return
	
	var/rank_name = dbadmins[ckey]
	var/m = "edited the permissions of rank [rank_name] permanently"
	var/datum/DBQuery/query_change_rank_flags = SSdbcore.NewQuery(
		"UPDATE [format_table_name("admin_ranks")] SET flags = :new_flags, exclude_flags = :new_exclude_flags, can_edit_flags = :new_can_edit_flags WHERE `rank` = :rank_name",
		list("new_flags" = new_flags, "new_exclude_flags" = 0, "new_can_edit_flags" = new_can_edit_flags, "rank_name" = rank_name)
	)
	if(!query_change_rank_flags.warn_execute())
		qdel(query_change_rank_flags)
		return
	qdel(query_change_rank_flags)
	var/log_message = "Permissions of [rank_name] changed from[rights2text(rank["flags"]," ")][rights2text(rank["can_edit_flags"]," ", "*")] to[rights2text(new_flags," ")][rights2text(new_can_edit_flags," ", "*")]"
	var/datum/DBQuery/query_change_rank_flags_log = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
		VALUES (:time, :round_id, :adminckey, INET_ATON(:adminip), 'change rank flags', :rank_name, :log)
	"}, list("time" = SQLtime(), "round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "rank_name" = rank_name, "log" = log_message))
	if(!query_change_rank_flags_log.warn_execute())
		qdel(query_change_rank_flags_log)
		return
	qdel(query_change_rank_flags_log)
	rank["flags"] = new_flags
	rank["can_edit_flags"] = new_can_edit_flags

	for(var/admin in admin_datums)
		if(dbadmins[admin] == rank_name)
			var/datum/admins/holder = admin_datums[admin]
			holder.deactivate()
			holder.activate()
	
	message_admins("[key_name_admin(usr)] [m]")
	log_admin("[key_name(usr)] [m]")
	return TRUE

/datum/permissions_controller/db/remove_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(..())
		return TRUE

	if(!(ckey in dbadmins))
		return FALSE
	
	var/grant_flags = 0
	if(usr.ckey in legacy_admins)
		grant_flags = legacy_ranks[legacy_admins[usr.ckey]] || 0
	else if(usr.ckey in dbadmins)
		var/dbrank = dbadmins[usr.ckey]
		if(dbranks[dbrank])
			grant_flags = dbranks[dbrank]["can_edit_flags"]

	if(!((dbadmins[ckey] in dbranks) && (dbranks[dbadmins[ckey]]["flags"] & grant_flags) == dbranks[dbadmins[ckey]]["flags"]))
		to_chat(usr, "You do not have access to delete this admin")
		return TRUE

	var/permanent = ((ckey in dbadmins) && SSdbcore.Connect() && check_rights(R_PERSIST_PERMS, FALSE) && (alert("Permanent changes are saved to the database for future rounds, temporary changes will affect only the current round", "Permanent or Temporary?", "Permanent", "Temporary", "Cancel") == "Permanent"))

	if(permanent)
		if(alert(usr, "Are you sure you wish to permanently remove [ckey] from the admins list?", "Confirmation", "Yes", "No") != "Yes")
			return TRUE
		var/datum/DBQuery/query_add_rank = SSdbcore.NewQuery(
			"DELETE FROM [format_table_name("admin")] WHERE ckey = :ckey",
			list("ckey" = ckey)
		)
		if(!query_add_rank.warn_execute())
			qdel(query_add_rank)
			return
		qdel(query_add_rank)
		var/datum/DBQuery/query_add_rank_log = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (datetime, round_id, adminckey, adminip, operation, target, log)
			VALUES (:time, :round_id, :adminckey, INET_ATON(:adminip), 'remove admin', :admin_ckey, CONCAT('Admin removed: ', :admin_ckey))
		"}, list("time" = SQLtime(), "round_id" = "[GLOB.round_id]", "adminckey" = usr.ckey, "adminip" = usr.client.address, "admin_ckey" = ckey))
		if(!query_add_rank_log.warn_execute())
			qdel(query_add_rank_log)
			return
		qdel(query_add_rank_log)
	else
		if(alert(usr, "Are you sure you wish to temporarily remove [ckey] from the admins list?", "Confirmation", "Yes", "No") != "Yes")
			return TRUE
	
	var/datum/admins/holder = admin_datums[ckey] || deadmins[ckey]
	if(holder)
		qdel(holder)
	
	dbadmins -= ckey
	return TRUE

