GLOBAL_VAR_INIT(mentornoot, FALSE)

/datum/world_topic/asay
	keyword = "asay"
	require_comms_key = TRUE

/datum/world_topic/asay/Run(list/input)
	to_chat(GLOB.admins, "<span class='adminsay'><span class='prefix'>DISCORD:</span> <EM>[input["admin"]]</EM>: <span class='message'>[input["asay"]]</span></span>", confidential=TRUE)

/datum/world_topic/ooc
	keyword = "ooc"
	require_comms_key = TRUE

/datum/world_topic/ooc/Run(list/input)
	for(var/client/C in GLOB.clients)
		to_chat(C, "<font color='[GLOB.normal_ooc_colour]'><span class='ooc'><span class='prefix'>DISCORD OOC:</span> <EM>[input["admin"]]:</EM> <span class='message'>[input["ooc"]]</span></span></font>")

/datum/world_topic/toggleooc
	keyword = "toggleooc"
	require_comms_key = TRUE

/datum/world_topic/toggleooc/Run(list/input)
	toggle_ooc()
	return GLOB.ooc_allowed

/datum/world_topic/adminwho/Run(list/input)
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		if(input["adminchannel"])
			admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"
		else if(!C.holder.fakekey)
			admin_keys += "[C]"

	for(var/admin in admin_keys)
		if(LAZYLEN(message) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")

/datum/world_topic/pr_announce/Run(list/input)
	var/msgTitle = input["announce"]
	var/author = input["author"]
	var/id = input["id"]
	var/link = "https://github.com/yogstation13/Yogstation/pull/[id]"

	var/final_composed = "<span class='announce'>PR: <a href=[link]>[msgTitle]</a> by [author]</span>"
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/datum/world_topic/reboot
	keyword = "reboot"
	require_comms_key = TRUE

/datum/world_topic/reboot/Run(list/input)
	SSticker.Reboot("Initiated from discord")

/datum/world_topic/msay
	keyword = "msay"
	require_comms_key = TRUE

/datum/world_topic/msay/Run(list/input)
	to_chat(GLOB.admins | GLOB.mentors, "<b><font color ='#8A2BE2'><span class='prefix'>DISCORD MENTOR:</span></span> <EM>[input["admin"]]</EM>: <span class='message'>[input["msay"]]</span></span>")

/datum/world_topic/mhelp
	keyword = "mhelp"
	require_comms_key = TRUE

/datum/world_topic/mhelp/Run(list/input)
	var/whom = input["whom"]
	var/msg = input["msg"]
	var/from = input["admin"]
	var/from_id = input["admin_id"]
	var/client/C = GLOB.directory[ckey(whom)]
	if(!C)
		return 0
	if(GLOB.mentornoot)
		SEND_SOUND(C, sound('sound/misc/nootnoot.ogg'))
	else
		SEND_SOUND(C, sound('sound/items/bikehorn.ogg'))
	to_chat(C, "<font color='purple'>Mentor PM from-<b>[discord_mentor_link(from, from_id)]</b>: [msg]</font>")
	var/show_char_recip = !C.is_mentor() && CONFIG_GET(flag/mentors_mobname_only)
	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(X != C)
			to_chat(X, "<B><font color='green'>Mentor PM: [discord_mentor_link(from, from_id)]-&gt;[key_name_mentor(C, X, 0, 0, show_char_recip)]:</B> <font color ='blue'> [msg]</font>")
	return 1

/datum/world_topic/unlink
	keyword = "unlink"
	require_comms_key = TRUE

/datum/world_topic/unlink/Run(list/input)
	var/ckey = input["unlink"]
	var/returned_id = SSdiscord.lookup_id(ckey)
	if(returned_id)
		SSdiscord.unlink_account(ckey)
		return "[ckey] has been unlinked!"
	else
		return "Account not unlinked! Please contact a coder."

/datum/world_topic/discordlink
	keyword = "discordlink"

/datum/world_topic/discordlink/Run(list/input)
	//We can't run this without a usr
	if(!usr)
		return

	var/hash = input["discordlink"]

	if(!CONFIG_GET(flag/sql_enabled))
		alert("Discord account linking requires the SQL backend to be running.")
		return

	if(!SSdiscord)
		alert("The server is still starting, please try again later.")

	var/stored_id = SSdiscord.lookup_id(usr.ckey)
	if(stored_id)
		alert("You already have the Discord Account [stored_id] linked to [usr.ckey]. If you need to have this reset, please contact an admin!","Already Linked")

	//The hash is directly appended to the request URL, this is to prevent exploits in URL parsing with funny urls
	// such as http://localhost/stuff:user@google.com/ so we restrict the valid characters to all numbers and the letters from a to f
	if(regex(@"[^\da-fA-F]").Find(hash))
		return
		
	//Since this action is passive as in its executed as you login, we need to make sure the user didnt just click on some random link and he actually wants to link
	var/res = input("You are about to link your BYOND and Discord account. Do not proceed if you did not initiate the linking process. Input 'proceed' and press ok to proceed") as text|null
	if(lowertext(res) != "proceed")
		alert("Linking process aborted")
		//Reconnecting clears out the connection parameters, this is so the user doesn't get the prompt to link their account if they later click replay
		winset(usr, null, "command=.reconnect")
		return
		
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/webhook_address)]?key=[CONFIG_GET(string/webhook_key)]&method=verify&data=[json_encode(list("ckey" = usr.ckey, "hash" = hash))]")
	request.begin_async()
	UNTIL(request.is_complete() || !usr)
	if(!usr)
		return
	var/datum/http_response/response = request.into_response()
	var/data = json_decode(response.body)
	if(istext(data["response"]))
		alert("Internal Server Error")
		winset(usr, null, "command=.reconnect")
		return
	
	if(data["response"]["status"] == "err")
		alert("Could not link account: [data["response"]["message"]]")
	else
		alert("Linked to account [data["response"]["message"]]")
	winset(usr, null, "command=.reconnect")