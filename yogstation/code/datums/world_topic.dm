/datum/world_topic/asay
	keyword = "asay"
	require_comms_key = TRUE

/datum/world_topic/asay/Run(list/input)
	to_chat(GLOB.admins, "<span class='adminsay'><span class='prefix'>DISCORD:</span> <EM>[input["admin"]]</EM>: <span class='message'>[input["asay"]]</span></span>")

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
	var/link = "https://github.com/yogstation13/Yogstation-TG/pull/[id]"

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
	to_chat(GLOB.admins | GLOB.mentors, "<b><font color ='#8A2BE2'><span class='prefix'>MENTOR:</span>DISCORD MENTOR:</span> <EM>[input["admin"]]</EM>: <span class='message'>[input["msay"]]</span></span>")

/datum/world_topic/mhelp
	keyword = "mhelp"
	require_comms_key = TRUE

/datum/world_topic/mhelp/Run(list/input)
	var/whom = input["whom"]
	var/msg = input["msg"]
	var/from = input["admin"]
	var/client/C = GLOB.directory[whom]
	if(!C)
		return

	to_chat(C, "<font color='purple'>Mentor PM from-<b>[from]</b>: [msg]</font>")
	var/show_char_recip = !C.is_mentor() && CONFIG_GET(flag/mentors_mobname_only)
	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(!X == C)
			to_chat(X, "<B><font color='green'>Mentor PM: [from]-&gt;[key_name_mentor(C, X, 0, 0, show_char_recip)]:</B> <font color ='blue'> [msg]</font>")