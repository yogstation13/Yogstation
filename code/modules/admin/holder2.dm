GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(legacy_ranks)
GLOBAL_PROTECT(legacy_ranks)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

/datum/admins

	var/target
	var/name = "nobody's admin datum (no rank)" //Makes for better runtimes
	var/client/owner	= null
	var/fakekey			= null
	var/fakename		= null

	var/datum/marked_datum

	var/spamcooldown = 0

	var/admincaster_screen = 0	//TODO: remove all these 5 variables, they are completly unacceptable
	var/datum/newscaster/feed_message/admincaster_feed_message = new /datum/newscaster/feed_message
	var/datum/newscaster/wanted_message/admincaster_wanted_message = new /datum/newscaster/wanted_message
	var/datum/newscaster/feed_channel/admincaster_feed_channel = new /datum/newscaster/feed_channel
	var/admin_signature

	var/href_token

	var/deadmined

	var/ip_cache
	var/cid_cache

	var/rights = 0
	var/rank_name = "NoRank"


/datum/admins/New(new_rights, new_rank, ckey, force_active = FALSE)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if (!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a ckey")
	target = ckey
	name = "[ckey]'s admin datum ([new_rank])"
	rights = new_rights
	rank_name = new_rank
	admin_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	href_token = GenerateToken()
	if(rights & R_DEBUG) //grant profile access
		world.SetConfig("APP/admin", ckey, "role=admin")
	if (force_active || (rights & R_AUTOLOGIN))
		activate()
	else
		deactivate()

/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	. = ..()

/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins -= target
	GLOB.admin_datums[target] = src
	deadmined = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target])	//find the client for a ckey if they are connected and associate them with us


/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.deadmins[target] = src
	GLOB.admin_datums -= target
	deadmined = TRUE
	var/client/C
	if ((C = owner) || (C = GLOB.directory[target]))
		disassociate()
		add_verb(C, /client/proc/readmin)

/datum/admins/proc/associate(client/C, allow_mfa_query = TRUE)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return FALSE

	if(istype(C))
		if(C.ckey != target)
			var/msg = " has attempted to associate with [target]'s admin datum"
			message_admins("[key_name_admin(C)][msg]")
			log_admin("[key_name(C)][msg]")
			return FALSE

		if(!C.mfa_check(allow_mfa_query))
			if(!deadmined)
				deactivate()
			return FALSE

		if (deadmined)
			activate()
		owner = C
		ip_cache = C.address
		cid_cache = C.computer_id
		owner.holder = src
		owner.add_admin_verbs()	//TODO <--- todo what? the proc clearly exists and works since its the backbone to our entire admin system
		remove_verb(owner, /client/proc/readmin)
		owner.init_verbs() //re-initialize the verb list
		GLOB.admins |= C
		return TRUE

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(owner)
		GLOB.admins -= owner
		owner.remove_admin_verbs()
		owner.init_verbs()
		owner.holder = null
		owner = null

/datum/admins/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rights))
		return FALSE
	return TRUE


/datum/admins/proc/check_if_greater_rights_than_holder(datum/admins/other)
	if(!other)
		return 1 //they have no rights
	if(rights == R_EVERYTHING)
		return 1 //we have all the rights
	if(src == other)
		return 1 //you always have more rights than yourself
	if(rights != other.rights)
		if( (rights & other.rights) == other.rights )
			return TRUE //we have all the rights they have and more
	return FALSE

/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE //nice try trialmin

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
you will have to do something like if(client.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr && usr.client)
		if (check_rights_for(usr.client, rights_required))
			return 1
		else
			if(show_msg)
				to_chat(usr, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>", confidential=TRUE)
	return 0

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			return usr.client.holder.check_if_greater_rights_than_holder(other.holder)
	return 0

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject && subject.holder)
		return subject.holder.check_for_rights(rights_required)
	return 0

/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"

/proc/RawHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/admins/holder = C.holder
		if(holder)
			tok = holder.href_token
	return tok

/proc/HrefToken(forceGlobal = FALSE)
	return "admin_token=[RawHrefToken(forceGlobal)]"

/proc/HrefTokenFormField(forceGlobal = FALSE)
	return "<input type='hidden' name='admin_token' value='[RawHrefToken(forceGlobal)]'>"

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
		if("dbranks")
			flag = R_DBRANKS
		if("dev")
			flag = R_DEV
		if("@","prev")
			flag = previous_rights
	return flag

//load legacy rank - > rights associations
/proc/load_legacy_ranks(dbfail, no_update)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Reload blocked: Advanced ProcCall detected.</span>", confidential=TRUE)
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
		GLOB.legacy_ranks[rank_name] = rights

/proc/load_admins()
	//clear the datums references
	GLOB.admin_datums.Cut()
	for(var/client/C in GLOB.admins)
		C.remove_admin_verbs()
		C.holder = null
	GLOB.admins.Cut()
	GLOB.protected_admins.Cut()
	GLOB.deadmins.Cut()
	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)

	load_legacy_ranks()

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
		if(rank in GLOB.legacy_ranks)
			GLOB.protected_admins[ckey] = rank
	
	for(var/client/C in GLOB.clients)
		check_and_grant_admin_for(C)

/// Gets the permissions rank list for a given legacy rank, small helper
/proc/get_legacy_perms_list(var/rank_name)
	return list("admin" = TRUE, "rank" = rank_name, "flags" = GLOB.legacy_ranks[rank_name])

/// Finds the permissions for a given user, and grants them, if applicable
/// Also handles things such as the localhost rank and backup admin list
/// Returns true if they have a rank
/proc/check_and_grant_admin_for(var/client/C)
	var/list/permissions
	if(C.ckey in GLOB.protected_admins)
		permissions = get_legacy_perms_list(GLOB.protected_admins[C.ckey])
	else
		permissions = query_permissions_for(C)
	
	if(CONFIG_GET(flag/autoadmin))
		var/auto_rank = CONFIG_GET(string/autoadmin_rank)
		if(auto_rank in GLOB.legacy_ranks)
			permissions = get_legacy_perms_list(auto_rank)

	if(CONFIG_GET(flag/enable_localhost_rank) && !permissions["admin"])
		var/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(C.address) || (C.address in localhost_addresses))
			permissions["admin"] = TRUE
			permissions["rank"] = "!localhost!"
			permissions["flags"] = R_EVERYTHING
	
	if(permissions["admin"])
		new /datum/admins(permissions["flags"], permissions["rank"], C.ckey)

	return permissions["admin"]

/// Queries the backend auth system (forums in this case), and returns if the user should be adminned and with what permissions and rank name
/proc/query_permissions_for(var/client/C)
	. = list("admin" = FALSE, "rank" = "SomethingIsBroken", "flags" = 0)

	if(!CONFIG_GET(string/xenforo_key))
		return

	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/apiurl)]/linking/byond/[C.ckey]", "", list("XF-Api-Key" = CONFIG_GET(string/xenforo_key)))
	req.begin_async()

	UNTIL(req.is_complete() || QDELETED(C))
	if(QDELETED(C))
		return
	
	var/datum/http_response/response = req.into_response()
	var/list/body = json_decode(response.body)
	if(!body["success"])
		return
	
	.["flags"] = 0
	var/list/permissions = body["user"]["permissions"]
	for(var/permission in permissions)
		var/list/parts = splittext(permission, ".")
		if(parts[1] != "ingame")
			continue
		var/newflag = admin_keyword_to_flag(parts[2])
		if(!newflag)
			stack_trace("WARNING: Permission \"[parts[2]]\" not found.")
		.["flags"] |= newflag
	
	.["rank"] = "FORUMS"
	.["admin"] = !!.["flags"]


