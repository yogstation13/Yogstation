GLOBAL_DATUM(permissions, /datum/permissions_controller)
GENERAL_PROTECT_DATUM(/datum/permissions_controller)

// Creates permissions controller based on the config
/proc/init_permissions()
	if(GLOB.permissions != null)
		CRASH("Permissions controller loaded twice")

	var/controller_type = /datum/permissions_controller
	switch(ckey(CONFIG_GET(string/permissions_backend)))
		if("database")
			if(CONFIG_GET(flag/sql_enabled))
				controller_type = /datum/permissions_controller/db
			else
				stack_trace("Attempted to load database permissions with sql disabled.")
		if("forums")
			if(CONFIG_GET(string/xenforo_key))
				controller_type = /datum/permissions_controller/forums
			else
				stack_trace("Attempted to load forums permissions without a xenforo api key")
	GLOB.permissions = new controller_type()

// Handles admin permissions management, overriden to support external backends
// Base datum supports legacy file based admin loading
/datum/permissions_controller
	/// Admins that should not be allowed to be modified by the permissions panel
	var/list/protected_admins = list()

	/// Ranks that should not be allowed to be modified by the permissions panel
	var/list/protected_ranks = list()

	/// Admins loaded with the legacy system
	var/list/legacy_admins = list()

	/// Ranks loaded with the legacy system
	var/list/legacy_ranks = list()

	// These lists are mostly handled by the datums themselves
	/// Associated list of ckey -> admin datums
	var/list/admin_datums = list()

	/// List of all admin clients
	var/list/admins = list()

	/// List of all deadmins
	var/list/deadmins = list()

/// Clears any existing stored admins and (re) loads the data from the backend
/datum/permissions_controller/proc/start()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	
	clear_admins()
	load_admins()
	for(var/client/C in GLOB.clients)
		load_permissions_for(C)

/// Removes all admin status from everyone
/datum/permissions_controller/proc/clear_admins()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	//clear the datums references
	admin_datums.Cut()
	for(var/client/C in GLOB.permissions.admins)
		C.remove_admin_verbs()
		C.holder = null
	admins.Cut()
	protected_admins.Cut()
	protected_ranks.Cut()
	legacy_admins.Cut()
	legacy_ranks.Cut()
	deadmins.Cut()
	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)

/// Pulls in admin data, for if the backend caches the admin data
/datum/permissions_controller/proc/load_admins()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	var/previous_rights = 0
	for(var/line in world.file2list("[global.config.directory]/admin_ranks.txt"))
		if(!line || findtextEx(line,"#",1,2) || line == " ") //YOGS - added our DB support
			continue
		var/next = findtext(line, "=")
		var/prev = findchar(line, "+-*", next, 0)
		var/rank_name = trim(copytext(line, 1, next))
		if(!rank_name) continue
		var/rights = 0
		while(prev)
			next = findchar(line, "+-*", prev + 1, 0)
			rights |= admin_keyword_to_flag(copytext(line, prev, next), previous_rights)
			prev = next
		previous_rights = rights
		legacy_ranks[rank_name] = rights
		if(CONFIG_GET(flag/protect_legacy_ranks))
			protected_ranks |= rank_name

	//ckeys listed in admins.txt are always made admins before sql loading is attempted
	var/list/lines = world.file2list("[global.config.directory]/admins.txt")
	for(var/line in lines)
		if(!length(line) || findtextEx(line, "#", 1, 2) || line == " ") //yogs - added our DB support
			continue
		var/list/entry = splittext(line, "=")
		if(entry.len < 2)
			continue
		var/ckey = ckey(entry[1])
		var/rank = trim(entry[2])
		if(!ckey || !rank)
			continue
		if(rank in legacy_ranks)
			legacy_admins[ckey] = rank
			if(CONFIG_GET(flag/protect_legacy_admins))
				protected_admins |= ckey

/// Queries the backend permissions system then creates their datum if they should have one
/// Returns true if a datum was created
/datum/permissions_controller/proc/load_permissions_for(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(C.ckey in legacy_admins)
		new /datum/admins(C.ckey, legacy_ranks[legacy_admins[C.ckey]])
		return TRUE
	
	if(_load_permissions_for(C))
		return TRUE
	
	if(CONFIG_GET(flag/autoadmin))
		var/auto_rank = CONFIG_GET(string/autoadmin_rank)
		if(auto_rank in legacy_ranks)
			legacy_admins[C.ckey] = auto_rank
			new /datum/admins(C.ckey, legacy_ranks[C.ckey])
			return TRUE

	if(CONFIG_GET(flag/enable_localhost_rank))
		var/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(C.address) || (C.address in localhost_addresses))
			legacy_ranks["!localhost!"] = R_EVERYTHING - R_PERSIST_PERMS
			legacy_admins[C.ckey] = "!localhost!"
			new /datum/admins(C.ckey, R_EVERYTHING - R_PERSIST_PERMS)
			return TRUE
	
	return FALSE

/// Most backends probably want to override this one
/// Loads after legacy but before autoadmin/localhost
/// If you woud like your backend to load before legacy, or after autoadmin/localhost
/// Override the above function instead
/datum/permissions_controller/proc/_load_permissions_for(client/C)
	PROTECTED_PROC(TRUE)
	return FALSE

/datum/permissions_controller/proc/check_for_rights(client/subject, rights_required)
	if(!subject || !subject.holder) // Null and deadmins have no rights
		return FALSE
	if(rights_required)
		return !!(get_rights_for(subject) & rights_required)
	return TRUE

/datum/permissions_controller/proc/get_rights_for(client/subject)
	. = 0
	if(!subject || !subject.holder)
		return
	return get_rights_for_ckey(subject.ckey)

/datum/permissions_controller/proc/get_rights_for_ckey(ckey)
	if(ckey in legacy_admins)
		if(legacy_admins[ckey] in legacy_ranks)
			return legacy_ranks[legacy_admins[ckey]]
	
/// Returns -1 if fewer, 0 if same, 1 if more
/datum/permissions_controller/proc/compare_rights(client/A, client/B)
	if(!A && !B) // If both null, same
		return 0
	if(!A)
		return -1
	if(!B)
		return 1
	
	if(!A.holder && !B.holder)
		return 0
	if(!A.holder)
		return -1
	if(!B.holder)
		return 1
	
	var/A_rights = get_rights_for(A)
	var/B_rights = get_rights_for(B)
	if(A_rights == B_rights)
		return 0
	if(A_rights > B_rights)
		return 1
	return -1
	

/datum/permissions_controller/proc/get_rank_name(client/subject)
	var/ckey = subject.ckey
	if(ckey in legacy_admins)
		return legacy_admins[ckey]

/datum/permissions_controller/proc/pp_data(mob/user)
	var/user_rights = get_rights_for(user.client)
	. = list()
	.["admins"] = list()
	for(var/legmin in legacy_admins)
		var/data = list()
		data["ckey"] = legmin
		data["rank"] = legacy_admins[legmin]
		var/rights = legacy_ranks[data["rank"]]
		data["rights"] = rights2text(rights, seperator = " ")
		var/can_edit = (rights & user_rights) == rights
		data["protected_admin"] = (legmin in protected_admins) || !can_edit
		data["protected_rank"] = (data["rank"] in protected_ranks) || !can_edit
		data["deadminned"] = (legmin in deadmins)
		.["admins"] |= list(data)

// Functions used to modify permissions
// Returns true if permissions modification was handled

/// This proc prompts the user for the name that want to add
/// Then uses should_add_admin(ckey) to determine if there is a reason
/// that ckey shouldn't be added (usually due to already being adminned)
/// make_admin(ckey) is then called to handle the actual adding
/datum/permissions_controller/proc/add_admin()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	var/ckey = ckey(input("New admin's key","Admin key") as text|null)
	if(!ckey)
		return FALSE

	if(!should_add_admin(ckey))
		to_chat(usr, span_warning("Unable to admin [ckey]. Do they already hold a rank?"), confidential = TRUE)
		return FALSE
	
	return make_admin(ckey)

/datum/permissions_controller/proc/should_add_admin(ckey)
	return !(ckey in legacy_admins)

/// Returns true if the rank was changed
/datum/permissions_controller/proc/set_legacy_rank(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	var/list/rank_names = list()
	var/usr_rights = get_rights_for(usr.client)

	rank_names += "*New Rank*"
	for(var/R in legacy_ranks)
		if((usr_rights & legacy_ranks[R]) == legacy_ranks[R]) // Cannot grant permissions you do not have
			rank_names += R
	var/new_rank = input("Please select a rank", "New rank") as null|anything in rank_names
	if(new_rank == "*New Rank*")
		new_rank = trim(input("Please input a new rank", "New custom rank") as text|null)
	if(!new_rank)
		return FALSE
	var/old_rights = 0
	if(ckey in legacy_admins)
		if(legacy_admins[ckey] in legacy_ranks)
			old_rights = legacy_ranks[legacy_admins[ckey]]
	if(!(new_rank in legacy_ranks))
		legacy_ranks[new_rank] = old_rights
	legacy_admins[ckey] = new_rank

	var/m = "edited the admin rank of [ckey] to [new_rank] temporarily"
	message_admins("[key_name_admin(usr)] [m]")
	log_admin("[key_name(usr)] [m]")

	if(ckey in admin_datums)
		var/datum/admins/holder = admin_datums[ckey]
		holder.deactivate()
		holder.activate()
		return TRUE
	if(ckey in deadmins)
		return TRUE
	if(ckey in GLOB.directory)
		new /datum/admins(ckey, legacy_ranks[new_rank])
		return TRUE
	return TRUE

/datum/permissions_controller/proc/make_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	set_legacy_rank(ckey)
	return TRUE

/datum/permissions_controller/proc/edit_rank(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(ckey in protected_admins)
		to_chat(usr, span_warning("Editing this admin blocked by config"), confidential = TRUE)
		return TRUE // Nothing was changed, but nothing should be changed
	
	if(!(ckey in legacy_admins))
		return FALSE
	
	set_legacy_rank(ckey)
	return TRUE

/datum/permissions_controller/proc/edit_perms(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(!(ckey in legacy_admins))
		return FALSE
	var/rank = legacy_admins[ckey]
	if(rank in protected_ranks)
		to_chat(usr, span_warning("Editing this rank blocked by config"), confidential = TRUE)
		return TRUE // Nothing was changed, but nothing should be changed
	
	if(alert("This will modify all admins with the same rank, are you sure you wish to continue?", "Confirmation", "Yes", "No") != "Yes")
		return TRUE

	var/new_flags = input_bitfield(usr, "Permission flags<br>This will affect all admins with rank [rank]", "admin_flags", legacy_ranks[rank], 350, 590)
	if(isnull(new_flags))
		return
	legacy_ranks[rank] = new_flags

	var/m = "edited the admin rank of [rank] temporarily"
	message_admins("[key_name_admin(usr)] [m]")
	log_admin("[key_name(usr)] [m]")

	for(var/admin in admin_datums)
		if((admin in legacy_admins) && legacy_admins[admin] == rank)
			var/datum/admins/holder = admin_datums[ckey]
			holder.deactivate()
			holder.activate()

/datum/permissions_controller/proc/remove_admin(ckey)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(!(ckey in legacy_admins))
		return FALSE
	if(ckey in protected_admins)
		to_chat(usr, span_warning("Editing this admin blocked by config"), confidential = TRUE)
		return TRUE // Nothing was changed, but nothing should be changed
	
	if(alert("This will remove all admin access for the rest of the round. Are you sure?", "Confirmation", "Yes", "No", "Cancel") != "Yes")
		return TRUE
	
	var/m = "removed [ckey] from the admin list temporarily"
	message_admins("[key_name_admin(usr)] [m]")
	log_admin("[key_name(usr)] [m]")

	legacy_admins[ckey] = null
	if(ckey in admin_datums)
		qdel(admin_datums[ckey])
	if(ckey in deadmins)
		qdel(deadmins[ckey])

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

/proc/admin_proc()
	if(!check_rights(R_ADMIN))
		return
	to_chat(world, "you have enough rights!")

NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
use check_rights_for
*/
/proc/check_rights(rights_required, show_msg=TRUE)
	if(usr && usr.client)
		if (check_rights_for(usr.client, rights_required))
			return TRUE
		else
			if(show_msg)
				to_chat(usr, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>", confidential=TRUE)
	return FALSE

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	return GLOB.permissions.check_for_rights(subject, rights_required)

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return TRUE
			return GLOB.permissions.compare_rights(usr.client, other) > 0
	return FALSE

/proc/admin_keyword_to_flag(word, previous_rights=0)
	var/flag = 0
	switch(ckey(word))
		if("buildmode","build")
			flag = R_BUILDMODE
		if("admin")
			flag = R_ADMIN
		if("ban")
			flag = R_BAN
		if("fun")
			flag = R_FUN
		if("server")
			flag = R_SERVER
		if("debug")
			flag = R_DEBUG
		if("permissions","rights")
			flag = R_PERMISSIONS
		if("possess")
			flag = R_POSSESS
		if("stealth")
			flag = R_STEALTH
		if("poll")
			flag = R_POLL
		if("varedit")
			flag = R_VAREDIT
		if("everything","host","all")
			flag = R_EVERYTHING
		if("sound","sounds")
			flag = R_SOUNDS
		if("spawn","create")
			flag = R_SPAWN
		if("autologin", "autoadmin")
			flag = R_AUTOLOGIN
		if("dev")
			flag = R_DEV
		if("dbranks", "persistperms")
			flag = R_PERSIST_PERMS
		if("@","prev")
			flag = previous_rights
	return flag
