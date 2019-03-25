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

	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("donors")] WHERE (expiration_time > Now()) AND (revoked IS NULL)")
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
			P.unlock_content |= 2

/world/update_status()

	var/list/features = list()

	if(GLOB.master_mode)
		features += GLOB.master_mode

	if (!GLOB.enter_allowed)
		features += "closed"

	var/s = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			s += "<b>[server_name]</b> &#8212; "
		if(!CONFIG_GET(flag/norespawn)) features += "<b>respawn</b>" // Bold it since it will be an amazing(ly questionable) event
		hostedby = CONFIG_GET(string/hostedby)

	s += "<b>[station_name()]</b>]<br>"; // The station & server name
	s += "(<a href=\"https://forums.yogstation.net/index.php\">Forums</a>|<a href=\"https://discord.gg/8hphvMe\">Discord</a>)<br>" // The Forum & Discord links
	s += "Mode: <b>[GLOB.master_mode]</b><br>" // The Gamemode
	
	var/players = GLOB.clients.len
	var/popcap = max(CONFIG_GET(number/extreme_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/soft_popcap))
	var/popcaptext = ""
	if (players > 1)
		popcaptext = "~[players][popcaptext] players"
	else if (players)
		popcaptext = "~[players][popcaptext] player"
	var/queuetext = ""
	if(SSticker && SSticker.queued_players.len)
		queuetext = " ([SSticker.queued_players.len] in queue)"
	s += "[popcaptext][queuetext]<br>"
	
	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full
	
	if (!host && hostedby)
		s += "hosted by <b>[hostedby]</b>"

	status = s
