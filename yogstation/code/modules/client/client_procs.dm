/world/proc/sync_logout_with_db(number)
	if(!number)
		return

	if(!SSdbcore.Connect())
		return

	var/datum/DBQuery/query_logout = SSdbcore.NewQuery("UPDATE [format_table_name("connection_log")] SET `left` = Now() WHERE id = [number]")
	query_logout.Execute(async = TRUE)
	qdel(query_logout)

/client/proc/sync_login_with_db()
	if(!SSdbcore.Connect())
		return

	var/sql_ckey = sanitizeSQL(ckey)
	var/sql_ip = sanitizeSQL(address)
	var/sql_computerid = sanitizeSQL(computer_id)
	var/serverip = "[world.internet_address]"

	var/datum/DBQuery/query_log_connection = SSdbcore.NewQuery("INSERT INTO `[format_table_name("connection_log")]` (`id`, `datetime`, `server_ip`, `server_port`, `round_id`, `ckey`, `ip`, `computerid`) VALUES(null, Now(), INET_ATON('[serverip]'), '[world.port]', '[GLOB.round_id]', '[sql_ckey]', INET_ATON('[sql_ip]'), '[sql_computerid]')")
	if(query_log_connection.Execute(async = TRUE))
		qdel(query_log_connection)
		var/datum/DBQuery/query_getid = SSdbcore.NewQuery("SELECT LAST_INSERT_ID();")
		query_getid.Execute(async = TRUE)
		if(query_getid.NextRow())
			connection_number = query_getid.item[1]
		qdel(query_getid)

/client/proc/yogs_client_procs(href_list)
	if(href_list["mentor_msg"])
		if(href_list["mentor_discord_id"])
			cmd_mentor_pm(href_list["mentor_msg"], null, href_list["mentor_discord_id"])
		else if(CONFIG_GET(flag/mentors_mobname_only))
			var/mob/M = locate(href_list["mentor_msg"])
			cmd_mentor_pm(M,null)
		else
			cmd_mentor_pm(href_list["mentor_msg"],null)
		return TRUE

	//Mentor Follow
	if(href_list["mentor_follow"])
		var/mob/living/M = locate(href_list["mentor_follow"])

		if(istype(M))
			mentor_follow(M)
		return TRUE

	//Mentor Ticket
	if(href_list["showmticket"])
		var/datum/mentorticket/T = SSYogs.mentortickets[href_list["showmticket"]]
		show_mentor_ticket(T)

	//Mentor Ticket Reply
	if(href_list["replymticket"])
		cmd_mentor_pm(href_list["replymticket"])

	if(href_list["pollidshow"])
		poll_results(href_list["pollidshow"])

/client/proc/mentor_datum_set(admin)
	var/found_datum = GLOB.mentor_datums[ckey]
	if(!found_datum) // admin with no mentor datum?let's fix that
		new /datum/mentors(ckey)

	if(mentor_datum)
		if(admin)
			GLOB.mentors |= src // don't add admins to this list too.

		mentor_datum.owner = src
		add_mentor_verbs()
		mentor_memo_output("Show")

/client/proc/is_mentor() // admins are mentors too.
	if(mentor_datum || check_rights_for(src, R_ADMIN,0))
		return TRUE
