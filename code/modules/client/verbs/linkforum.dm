/client/verb/linkforum()
	set category = "OOC"
	set name = "Link Forum Account"
	set desc = "Link your Forum account to your BYOND account."

	if(!CONFIG_GET(string/xenforo_key))
		to_chat(src, "<span class='warning'>Error: Please contact your system administrator</span>", confidential = TRUE)
		return

	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/apiurl)]/linking/byond/[ckey]", "", list("XF-Api-Key" = CONFIG_GET(string/xenforo_key)))
	req.begin_async()
	addtimer(CALLBACK(src, /client/proc/givelinkforum), 15 MINUTES, TIMER_STOPPABLE)
	remove_verb(src, /client/verb/linkforum)

	UNTIL(req.is_complete())
	var/datum/http_response/response = req.into_response()
	var/list/body = json_decode(response.body)
	to_chat(src, "<a href='[body["url"]]'>Verify your account here!</a> Link will expire in 15 minutes.", confidential = TRUE)

/client/proc/givelinkforum()
	add_verb(src, /client/verb/linkforum)
	to_chat(src, "<span class='notice'>Your forum verification link has expired, and the verb has been returned to you. You can ignore this if you have already linked your accounts.</span>", confidential = TRUE)
