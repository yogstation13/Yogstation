//2.5 minutes, gotta prevent DDoSing using SQL
#define ANTAG_TOKEN_COOLDOWN 1500

//List of all people using antag tokens this round
GLOBAL_LIST_EMPTY(antag_token_users)

/client/verb/antag_token_check()
	set name = "Check/Use Antag Token"
	set category = "Admin"
	set desc = "Check if you have an antag token, and if you do, use it."
	var/client/C = usr.client

	if(world.time < C.last_antag_token_check)
		to_chat(usr, span_userdanger("You cannot use this verb yet! Please wait."))
		return

	var/datum/DBQuery/query_antag_token_existing = SSdbcore.NewQuery({"SELECT ckey FROM [format_table_name("antag_tokens")] WHERE ckey = :ckey AND redeemed = 0"}, list("ckey" = ckey(ckey)))

	if(!query_antag_token_existing.warn_execute())
		qdel(query_antag_token_existing)
		return

	C.last_antag_token_check = world.time + ANTAG_TOKEN_COOLDOWN

	if(query_antag_token_existing.NextRow())
		if(SSticker.current_state > GAME_STATE_PREGAME)
			to_chat(usr, span_userdanger("You have an antag token. You can use this button in the pre-game lobby to use it!"))
			return
		if(alert("You have an antag token! Do you want to use it? YOU CAN GET ANTAG'S THAT YOU HAVE DISABLED IN YOUR PREFERENCES",, "Yes", "No") != "Yes")
			qdel(query_antag_token_existing)
			return
		to_chat(src, span_userdanger("You will be notified if your antag token is used"))
		C.antag_token_timer = addtimer(CALLBACK(src, .proc/deny_antag_token_request), 45 SECONDS, TIMER_STOPPABLE)
		to_chat(GLOB.admins, span_adminnotice("<b><font color=orange>ANTAG TOKEN REQUEST:</font></b>[ADMIN_LOOKUPFLW(usr)] wants to use their antag token! (will auto-DENY in [DisplayTimeText(45 SECONDS)]). (<A HREF='?_src_=holder;[HrefToken(TRUE)];approve_antag_token=[REF(C)]'>APPROVE</A>)"))
		for(var/client/A in GLOB.admins)
			if(check_rights_for(A, R_ADMIN) && (A.prefs.toggles & SOUND_ADMINHELP)) // Can't use check_rights here since it's dependent on $usr
				SEND_SOUND(A, sound('sound/effects/adminhelp.ogg'))
	else
		alert("You do not have an antag token.")
	qdel(query_antag_token_existing)

/client/proc/deny_antag_token_request()
	if(usr in GLOB.antag_token_users)
		return
	to_chat(usr, span_userdanger("Your request has been denied! Your antag token has NOT been used."))

/datum/admins/proc/accept_antag_token_usage(client/C)
	var/token = FALSE // Weather or not the token was used, changed slightly later in the code
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return

	if(!check_rights(R_ADMIN))
		return

	if(!istype(C))
		return

	
	if(C in GLOB.antag_token_users) // If they're in the list take them out
		if(alert("Someone already approved this antag token. Are you sure you want to reject it?", "Confirm", "Yes", "No") != "Yes")
			return
		GLOB.antag_token_users -= C
		token = FALSE // Redundency if you clowns figure out how to break it
	else
		GLOB.antag_token_users += C // Put person into list upon accepting
		token = TRUE

	message_admins("[C.ckey]'s antag token request has been [token ? "approved" : "rejected"] by [usr.ckey]")
	to_chat(C.mob, span_userdanger("An admin has [token ? "approved" : "rejected"] your antag token request! [token ? "Ready up!" : ""]"))
	deltimer(C.antag_token_timer)

/proc/antag_token_used(ckey, client/C)
	var/mob/player = C.mob

	// Mark the mind as having not been picked by a token
	player.mind.token_picked = FALSE

	if(!is_special_character(player))
		message_admins("Failed to make player [ckey] an antag. Their token has NOT been used!")
		return

	to_chat(C, span_userdanger("Your antag token has been used!"))
	var/datum/DBQuery/query_antag_token = SSdbcore.NewQuery({"SELECT id
		FROM [format_table_name("antag_tokens")] WHERE ckey = :ckey AND redeemed = 0
		ORDER BY granted_time DESC"}, list("ckey" = ckey(ckey)))

	if(!query_antag_token.warn_execute())
		message_admins("Failed to use antag token for player '[ckey]'! Please do this manually!")
		qdel(query_antag_token)
		return

	if(query_antag_token.NextRow())
		var/id = query_antag_token.item[1]
		var/datum/DBQuery/query_antag_token_redeem = SSdbcore.NewQuery({"UPDATE [format_table_name("antag_tokens")] SET redeemed = 1, denying_admin = 'AUTOMATICALLY REDEEMED'
		WHERE id = :id"}, list("id" = id))
		if(!query_antag_token_redeem.warn_execute())
			message_admins("Failed to use antag token for player '[ckey]'! Please do this manually!")
			qdel(query_antag_token_redeem)
			return
		qdel(query_antag_token_redeem)
		log_admin_private("Antag token automatically redeemed for [ckey]")
		message_admins("Antag token automatically redeemed for [ckey]")
	else
		message_admins("Failed to use antag token for player '[ckey]'! Please do this manually!")
	qdel(query_antag_token)

#undef ANTAG_TOKEN_COOLDOWN
