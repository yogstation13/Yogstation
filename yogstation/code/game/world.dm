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

	//BASIC SHIT
	var/s = ""
	s += "<img src=\"https://i.imgur.com/gNgarRJ.gif\">" //Banner image
	var/server_name = CONFIG_GET(string/servername)
	if (server_name)
		s += "<br><b>[server_name]</b> &#8212; 99% Lag Free!!"
	s += "<br>(<a href=\"https://tinyurl.com/yogsfo\">Forums</a>|<a href=\"https://tinyurl.com/yogsdis\">Discord</a>)<br>" // The Forum & Discord links line
	s += "<br><i>[pick(world.file2list("yogstation/strings/taglines.txt"))]</i><br>"


	//PLAYER COUNT
	var/players = GLOB.clients.len
	var/popcaptext = ""
	if(players)
		popcaptext = "~[players] player\s"
	var/queuetext = ""
	if(SSticker && SSticker.queued_players.len)
		queuetext = ", [SSticker.queued_players.len] in queue"

	s += "\[[popcaptext][queuetext]"

	//HOST
	var/hostedby = CONFIG_GET(string/hostedby)
	if (!host && hostedby)
		s += " hosted by <b>[hostedby]</b>"

	//RETURN
	status = s
	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full
	return s
