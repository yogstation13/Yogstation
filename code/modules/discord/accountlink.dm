// Verb to link discord accounts to BYOND accounts
/client/verb/linkdiscord()
	set category = "Admin"
	set name = "Link Discord Account"
	set desc = "Link your discord account to your BYOND account."

	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, "<span class='warning'>This feature requires the SQL backend to be running.</span>")
		return

	if(!SSdiscord) // SS is still starting
		to_chat(src, "<span class='notice'>The server is still starting up. Please wait before attempting to link your account </span>")
		return

	var/stored_id = SSdiscord.lookup_id(usr.ckey)
	if(!stored_id) // Account is not linked
		var/know_how = alert("Get your Discord ID ready, you can get this by typing !myid in any channel!","Question","OK","Cancel Linking")
		if(know_how == "Cancel Linking")
			return
		var/entered_id = input("Please enter your Discord ID (18-ish digits)", "Enter Discord ID", null, null) as text|null
		SSdiscord.account_link_cache[replacetext(lowertext(usr.ckey), " ", "")] = "[entered_id]" // Prepares for TGS-side verification, also fuck spaces
		alert(usr, "Account link started. Please type the following in any channel '!verify yourckey' (Example: !verify nichlas0010)")
	else // Account is already linked
		alert("You already have the Discord Account [stored_id] linked to [usr.ckey]. If you need to have this reset, please contact an admin!","Already Linked","OK")
		return

// Verb to link forum accounts to BYOND accounts
/client/verb/linkforum()
	set category = "Admin"
	set name = "Link Forum Account"
	set desc = "Link your Forum account to your BYOND account."

	if(!CONFIG_GET(string/xenforo_key))
		to_chat(src, "<span class='warning'>Error: Please contact your system administrator</span>")
		return

	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/apiurl)]/linking/byond/[ckey]", "", list("XF-Api-Key" = CONFIG_GET(string/xenforo_key)))
	req.begin_async()
	addtimer(CALLBACK(src, /client/proc/givelinkforum), 15 MINUTES, TIMER_STOPPABLE)
	verbs -= /client/verb/linkforum

	UNTIL(req.is_complete())
	var/datum/http_response/response = req.into_response()
	var/list/body = json_decode(response.body)
	to_chat(src, "<a href='[body["url"]]'>Verify your account here!</a> Link will expire in 15 minutes.", confidential = TRUE)


/client/proc/givelinkforum()
	verbs += /client/verb/linkforum
	to_chat(src, "<span class='notice'>Your forum verification link has expired, and the verb has been returned to you. You can ignore this if you have already linked your accounts.</span>")
