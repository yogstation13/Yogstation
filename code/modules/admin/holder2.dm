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


/datum/admins/New(ckey, rights, force_active = FALSE)
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
	name = "[ckey]'s admin datum"
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
	var/client/C = owner
	deactivate()
	if(GLOB.permissions.deadmins[target] == src)
		GLOB.permissions.deadmins[target] = null
	if(C)
		remove_verb(C, /client/proc/readmin)
	. = ..()

/datum/admins/proc/activate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.permissions.deadmins -= target
	GLOB.permissions.admin_datums[target] = src
	deadmined = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target])	//find the client for a ckey if they are connected and associate them with us


/datum/admins/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.permissions.deadmins[target] = src
	GLOB.permissions.admin_datums -= target
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
		GLOB.permissions.admins |= C
		return TRUE

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(owner)
		GLOB.permissions.admins -= owner
		owner.remove_admin_verbs()
		owner.init_verbs()
		owner.holder = null
		owner = null

/datum/admins/proc/rank_name()
	if(owner)
		return GLOB.permissions.get_rank_name(owner)
	return "Unknown"

/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE //nice try trialmin

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
