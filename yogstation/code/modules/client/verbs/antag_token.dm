//2.5 minutes, gotta prevent DDoSing using SQL
#define AntagTokenCooldown 1500

//List of all people using antag tokens this round
GLOBAL_LIST_EMPTY(antag_token_users)

/client/verb/antag_token_check()
	set name = "Check/Use Antag Token"
	set category = "OOC"
	set desc = "Check if you have an antag token, and if you do, use it."
	var/client/C = usr.client

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "<span class='userdanger'>You must use this in the lobby!</span>")
		return

	if(world.time < C.last_antag_token_check)
		to_chat(usr, "<span class='userdanger'>You cannot use this verb yet! Please wait.</span>")
		return
		
	var/datum/DBQuery/query_antag_token_existing = SSdbcore.NewQuery({"SELECT ckey FROM [format_table_name("antag_tokens")] WHERE ckey = '[sanitizeSQL(ckey(ckey))]' AND redeemed = 0"})

	if(!query_antag_token_existing.warn_execute())
		qdel(query_antag_token_existing)
		return

	C.last_antag_token_check = world.time + AntagTokenCooldown

	if(query_antag_token_existing.NextRow())
		if(alert("You have an antag token! Do you want to use it? YOU CAN GET ANTAG'S THAT YOU HAVE DISABLED IN YOUR PREFERENCES",, "Yes", "No") != "Yes")
			qdel(query_antag_token_existing)
			return
		to_chat(src, "<span class='userdanger'>You will be notified if your antag token is used</span>")
		C.antag_token_timer = addtimer(CALLBACK(src, .proc/deny_antag_token_request), 45 SECONDS, TIMER_STOPPABLE)
		to_chat(GLOB.admins, "<span class='adminnotice'><b><font color=orange>ANTAG TOKEN REQUEST:</font></b>[ADMIN_LOOKUPFLW(usr)] wants to use their antag token! (will auto-DENY in [DisplayTimeText(45 SECONDS)]). (<A HREF='?_src_=holder;[HrefToken(TRUE)];approve_antag_token=[REF(C)]'>APPROVE</A>)</span>")
		for(var/client/A in GLOB.admins)
			if(check_rights_for(A, R_ADMIN) && (A.prefs.toggles & SOUND_ADMINHELP)) // Can't use check_rights here since it's dependent on $usr
				SEND_SOUND(A, sound('sound/effects/adminhelp.ogg'))
	else
		alert("You do not have an antag token.")
	qdel(query_antag_token_existing)

/client/proc/deny_antag_token_request()
	if(usr in GLOB.antag_token_users)
		return
	to_chat(usr, "<span class='userdanger'>Your request has been denied! Your antag token has NOT been used.</span>")

/datum/admins/proc/accept_antag_token_usage(client/C)
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return

	if(!check_rights(R_ADMIN))
		return
			
	if(!istype(C))
		return

	GLOB.antag_token_users += C
	to_chat(C.mob, "<span class='userdanger'>An admin has approved your antag token request! Ready up!</span>")
	message_admins("[C.ckey]'s antag token request has been approved by [usr.ckey]")
	deltimer(C.antag_token_timer)

/proc/antag_token_used(ckey, client/C)
	var/mob/player = C.mob
	if(!is_special_character(player))
		message_admins("Failed to make player [ckey] an antag. Their token has NOT been used!")
		return

	to_chat(C, "<span class='userdanger'>Your antag token has been used!</span>")
	var/datum/DBQuery/query_antag_token = SSdbcore.NewQuery({"SELECT id
		FROM [format_table_name("antag_tokens")] WHERE ckey = '[sanitizeSQL(ckey(ckey))]' AND redeemed = 0
		ORDER BY granted_time DESC"})

	if(!query_antag_token.warn_execute())
		message_admins("Failed to use antag token for player '[ckey]'! Please do this manually!")
		qdel(query_antag_token)
		return

	if(query_antag_token.NextRow())
		var/id = query_antag_token.item[1]
		var/datum/DBQuery/query_antag_token_redeem = SSdbcore.NewQuery({"UPDATE [format_table_name("antag_tokens")] SET redeemed = 1, denying_admin = 'AUTOMATICALLY REDEEMED'
		WHERE id = [id]"})
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
