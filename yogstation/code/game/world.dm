GLOBAL_LIST_EMPTY(donators)
/world/proc/load_yogs_stuff()
	load_donators()
	load_mentors()

/world/proc/load_donators()
	var/list/donatorskeys = list()
	if(!SSdbcore.IsConnected())
		message_admins("Failed to connect to database in load_donators().")
		log_sql("Failed to connect to database in load_donators().")
		return

	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("donors")] WHERE expiration_time > Now() AND revoked IS NULL AND valid = 1")
	if(!query.Execute())
		message_admins("Error loading donators from database.")
		log_sql("Error loading donators from database.")
		qdel(query)
		return

	var/ckey
	while(query.NextRow())
		ckey = query.item[1]
		if(ckey)
			donatorskeys |= ckey

	qdel(query)

	var/datum/preferences/P
	for(var/key in donatorskeys)
		ckey = ckey(key)
		GLOB.donators |= ckey
		P = GLOB.preferences_datums[ckey]
		if(P)
			P.unlock_content |= DONOR_YOGS


/world/update_status()

	//BASIC SHIT
	var/s = ""
	var/server_name = CONFIG_GET(string/servername)
	if (server_name)
		s += "<b>[server_name]</b>\] &#8212; Dive in Now: Perfect for Beginners!"
	s += "<br>99% Lag-Free | Regular Events | Active Community"
	s += "<br>Time: <b>[gameTimestamp("hh:mm")]</b> | Map: <b>[SSmapping?.config?.map_name || "Unknown"]</b> | Alert: <b>[capitalize(SSsecurity_level.get_current_level_as_text())]</b>"
	s += "<br>\[<a href=\"https://yogstation.net/\">Website</a>" // link to our website so they can join forums + discord from here

	//As of October 27th, 2023 taglines.txt is no longer used in the status because we never had the characters to spare it, so it would put 2-3 random characters at the end and look bad.

	//PLAYER COUNT

	var/players = GLOB.clients.len
	/*
	var/popcaptext = ""
	if(players)
		popcaptext = "~[players] player\s"
	var/queuetext = ""
	if(SSticker && SSticker.queued_players.len)
		queuetext = ", [SSticker.queued_players.len] in queue"

	s += "\[[popcaptext][queuetext]"

	*/

	/*

	//HOST
	var/hostedby = CONFIG_GET(string/hostedby)
	if (!host && hostedby)
		s += " hosted by <b>[hostedby]</b>"

	*/

	//RETURN
	status = s
	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full
	return s
