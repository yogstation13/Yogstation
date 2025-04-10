/proc/create_message(type, target_key, admin_ckey, text, timestamp, server, secret, logged = 1, browse, expiry)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	if(!type)
		return
	var/target_ckey = ckey(target_key)
	if(!target_key && (type == "note" || type == "message" || type == "watchlist entry"))
		var/new_key = input(usr,"Who would you like to create a [type] for?","Enter a key or ckey",null) as null|text
		if(!new_key)
			return
		var/new_ckey = ckey(new_key)
		var/datum/DBQuery/query_find_ckey = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ckey = :new_ckey", list("new_ckey" = new_ckey))
		if(!query_find_ckey.warn_execute())
			qdel(query_find_ckey)
			return
		if(!query_find_ckey.NextRow())
			if(alert(usr, "[new_key]/([new_ckey]) has not been seen before, are you sure you want to create a [type] for them?", "Unknown ckey", "Yes", "No", "Cancel") != "Yes")
				qdel(query_find_ckey)
				return
		qdel(query_find_ckey)
		target_ckey = new_ckey
		target_key = new_key
	if(QDELETED(usr))
		return
	if(!target_key)
		target_key = target_ckey
	if(!admin_ckey)
		admin_ckey = usr.ckey
		if(!admin_ckey)
			return
	if(!target_ckey)
		target_ckey = admin_ckey
	if(!text)
		text = input(usr,"Write your [type]","Create [type]") as null|message
		if(!text)
			return
	if(!timestamp)
		timestamp = SQLtime()
	if(!server)
		var/ssqlname = CONFIG_GET(string/serversqlname)
		if (ssqlname)
			server = ssqlname
	if(isnull(secret))
		switch(alert("Hide note from being viewed by players?", "Secret note?","Yes","No","Cancel"))
			if("Yes")
				secret = 1
			if("No")
				secret = 0
			else
				return
	if(isnull(expiry))
		if(alert(usr, "Set an expiry time? Expired messages are hidden like deleted ones.", "Expiry time?", "Yes", "No", "Cancel") == "Yes")
			var/expire_time = input("Set expiry time for [type] as format YYYY-MM-DD HH:MM:SS. All times in server time. HH:MM:SS is optional and 24-hour. Must be later than current time for obvious reasons.", "Set expiry time", SQLtime()) as null|text
			if(!expire_time)
				return
			var/datum/DBQuery/query_validate_expire_time = SSdbcore.NewQuery("SELECT IF(STR_TO_DATE(:expire_time,'%Y-%c-%d %T') > NOW(), STR_TO_DATE(:expire_time,'%Y-%c-%d %T'), 0)", list("expire_time" = expire_time))
			if(!query_validate_expire_time.warn_execute())
				qdel(query_validate_expire_time)
				return
			if(query_validate_expire_time.NextRow())
				var/checktime = text2num(query_validate_expire_time.item[1])
				if(!checktime)
					to_chat(usr, "Datetime entered is improperly formatted or not later than current server time.", confidential=TRUE)
					qdel(query_validate_expire_time)
					return
				expiry = query_validate_expire_time.item[1]
			qdel(query_validate_expire_time)

	var/datum/DBQuery/query_create_message = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("messages")] (type, targetckey, adminckey, text, timestamp, server, server_ip, server_port, round_id, secret, expire_timestamp)
		VALUES (:type, :target_ckey, :admin_ckey, :text, :timestamp, :server, INET_ATON(:internet_address), :port, :round_id, :secret, :expiry)
	"}, list(
		"type" = type,
		"target_ckey" = target_ckey,
		"admin_ckey" = admin_ckey,
		"text" = text,
		"timestamp" = timestamp,
		"server" = server,
		"internet_address" = world.internet_address || "0",
		"port" = "[world.port]",
		"round_id" = GLOB.round_id,
		"secret" = secret,
		"expiry" = expiry || null,
	))

	var/pm = "[key_name(usr)] has created a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_key]" : ""]: [text]"
	var/header = "[key_name(usr)] has created a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_key]" : ""]" // yogs - Yog Tickets
	if(!query_create_message.warn_execute())
		qdel(query_create_message)
		return
	qdel(query_create_message)
	if(logged)
		log_admin_private(pm)
		message_admins("[header]:<br>[text]")
		admin_ticket_log(target_ckey, header) // yogs - Yog Tickets
		admin_ticket_log(target_ckey, text)
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = target_ckey, agegate = TRUE)

/proc/delete_message(message_id, logged = 1, browse)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/type
	var/target_key
	var/text
	var/user_key_name = key_name(usr)
	var/user_name_admin = key_name_admin(usr)
	var/datum/DBQuery/query_find_del_message = SSdbcore.NewQuery("SELECT type, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey), text FROM [format_table_name("messages")] WHERE id = :message_id AND deleted = 0", list("message_id" = message_id))
	if(!query_find_del_message.warn_execute())
		qdel(query_find_del_message)
		return
	if(query_find_del_message.NextRow())
		type = query_find_del_message.item[1]
		target_key = query_find_del_message.item[2]
		text = query_find_del_message.item[3]
	qdel(query_find_del_message)
	var/datum/DBQuery/query_del_message = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET deleted = 1 WHERE id = :message_id", list("message_id" = message_id))
	if(!query_del_message.warn_execute())
		qdel(query_del_message)
		return
	qdel(query_del_message)
	if(logged)
		var/m1 = "[user_key_name] has deleted a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for" : " made by"] [target_key]: [text]"
		var/m2 = "[user_name_admin] has deleted a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for" : " made by"] [target_key]:<br>[text]"
		log_admin_private(m1)
		message_admins(m2)
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = ckey(target_key), agegate = TRUE)

/proc/edit_message(message_id, browse)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/editor_ckey = usr.ckey
	var/editor_key = usr.key
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/datum/DBQuery/query_find_edit_message = SSdbcore.NewQuery("SELECT type, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey), (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), text FROM [format_table_name("messages")] WHERE id = :message_id AND deleted = 0", list("message_id" = message_id))
	if(!query_find_edit_message.warn_execute())
		qdel(query_find_edit_message)
		return
	if(query_find_edit_message.NextRow())
		var/type = query_find_edit_message.item[1]
		var/target_key = query_find_edit_message.item[2]
		var/admin_key = query_find_edit_message.item[3]
		var/old_text = query_find_edit_message.item[4]
		var/new_text = input("Input new [type]", "New [type]", "[old_text]") as null|message
		if(!new_text)
			qdel(query_find_edit_message)
			return
		var/edit_text = "Edited by [editor_key] on [SQLtime()] from<br>[old_text]<br>to<br>[new_text]<hr>"
		var/datum/DBQuery/query_edit_message = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET text = :new_text, lasteditor = :editor_ckey, edits = CONCAT(IFNULL(edits,''), :edit_text) WHERE id = :message_id AND deleted = 0", list("new_text" = new_text, "editor_ckey" = editor_ckey, "edit_text" = edit_text, "message_id" = message_id))
		if(!query_edit_message.warn_execute())
			qdel(query_edit_message)
			return
		qdel(query_edit_message)
		log_admin_private("[kn] has edited a [type] [(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_key]" : ""] made by [admin_key] from [old_text] to [new_text]")
		message_admins("[kna] has edited a [type] [(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_key]" : ""] made by [admin_key] from<br>[old_text]<br>to<br>[new_text]")
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = ckey(target_key), agegate = TRUE)
	qdel(query_find_edit_message)

/proc/edit_message_expiry(message_id, browse)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/editor_ckey = usr.ckey
	var/editor_key = usr.key
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/datum/DBQuery/query_find_edit_expiry_message = SSdbcore.NewQuery("SELECT type, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey), (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), expire_timestamp FROM [format_table_name("messages")] WHERE id = :message_id AND deleted = 0", list("message_id" = message_id))
	if(!query_find_edit_expiry_message.warn_execute())
		qdel(query_find_edit_expiry_message)
		return
	if(query_find_edit_expiry_message.NextRow())
		var/type = query_find_edit_expiry_message.item[1]
		var/target_key = query_find_edit_expiry_message.item[2]
		var/admin_key = query_find_edit_expiry_message.item[3]
		var/old_expiry = query_find_edit_expiry_message.item[4]
		var/new_expiry
		var/expire_time = input("Set expiry time for [type] as format YYYY-MM-DD HH:MM:SS. All times in server time. HH:MM:SS is optional and 24-hour. Must be later than current time for obvious reasons. Enter -1 to remove expiry time.", "Set expiry time", old_expiry) as null|text
		if(!expire_time)
			qdel(query_find_edit_expiry_message)
			return
		if(expire_time == "-1")
			new_expiry = "non-expiring"
		else
			var/datum/DBQuery/query_validate_expire_time_edit = SSdbcore.NewQuery("SELECT IF(STR_TO_DATE(:expire_time,'%Y-%c-%d %T') > NOW(), STR_TO_DATE(:expire_time,'%Y-%c-%d %T'), 0)", list("expire_time" = expire_time))
			if(!query_validate_expire_time_edit.warn_execute())
				qdel(query_validate_expire_time_edit)
				qdel(query_find_edit_expiry_message)
				return
			if(query_validate_expire_time_edit.NextRow())
				var/checktime = text2num(query_validate_expire_time_edit.item[1])
				if(!checktime)
					to_chat(usr, "Datetime entered is improperly formatted or not later than current server time.", confidential=TRUE)
					qdel(query_validate_expire_time_edit)
					qdel(query_find_edit_expiry_message)
					return
				new_expiry = query_validate_expire_time_edit.item[1]
			qdel(query_validate_expire_time_edit)
		var/edit_text = "Expiration time edited by [editor_key] on [SQLtime()] from [old_expiry] to [new_expiry]<hr>"
		var/expire_timestamp = "NULL"
		if(expire_time == "-1")
			expire_timestamp = "NULL"
		else
			expire_timestamp = new_expiry
		var/datum/DBQuery/query_edit_message_expiry = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET expire_timestamp = :expire_timestamp, lasteditor = :editor_ckey, edits = CONCAT(IFNULL(edits,''), :edit_text) WHERE id = :message_id AND deleted = 0", list("expire_timestamp" = expire_timestamp, "editor_ckey" = editor_ckey, "edit_text" = edit_text, "message_id" = message_id))
		if(!query_edit_message_expiry.warn_execute())
			qdel(query_edit_message_expiry)
			qdel(query_find_edit_expiry_message)
			return
		qdel(query_edit_message_expiry)
		log_admin_private("[kn] has edited the expiration time of a [type] [(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_key]" : ""] made by [admin_key] from [old_expiry] to [new_expiry]")
		message_admins("[kna] has edited the expiration time of a [type] [(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_key]" : ""] made by [admin_key] from [old_expiry] to [new_expiry]")
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = ckey(target_key), agegate = TRUE)
	qdel(query_find_edit_expiry_message)

/proc/toggle_message_secrecy(message_id)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/editor_ckey = usr.ckey
	var/editor_key = usr.key
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/datum/DBQuery/query_find_message_secret = SSdbcore.NewQuery("SELECT type, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey), (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), secret FROM [format_table_name("messages")] WHERE id = :message_id AND deleted = 0", list("message_id" = message_id))
	if(!query_find_message_secret.warn_execute())
		qdel(query_find_message_secret)
		return
	if(query_find_message_secret.NextRow())
		var/type = query_find_message_secret.item[1]
		var/target_key = query_find_message_secret.item[2]
		var/admin_key = query_find_message_secret.item[3]
		var/secret = text2num(query_find_message_secret.item[4])
		var/edit_text = "Made [secret ? "not secret" : "secret"] by [editor_key] on [SQLtime()]<hr>"
		var/datum/DBQuery/query_message_secret = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET secret = NOT secret, lasteditor = :editor_ckey, edits = CONCAT(IFNULL(edits,''), :edit_text) WHERE id = :message_id", list("editor_ckey" = editor_ckey, "edit_text" = edit_text, "message_id" = message_id))
		if(!query_message_secret.warn_execute())
			qdel(query_find_message_secret)
			qdel(query_message_secret)
			return
		qdel(query_message_secret)
		log_admin_private("[kn] has toggled [target_key]'s [type] made by [admin_key] to [secret ? "not secret" : "secret"]")
		message_admins("[kna] has toggled [target_key]'s [type] made by [admin_key] to [secret ? "not secret" : "secret"]")
		browse_messages(target_ckey = ckey(target_key), agegate = TRUE)
	qdel(query_find_message_secret)

/proc/browse_messages(type, target_ckey, index, linkless = FALSE, filter, agegate = FALSE)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	var/list/output = list()
	var/ruler = "<hr style='background:#000000; border:0; height:3px'>"
	var/list/navbar = list("<a href='byond://?_src_=holder;[HrefToken()];nonalpha=2'>\[#\]</a>")
	for(var/letter in GLOB.alphabet)
		navbar += "|<a href='byond://?_src_=holder;[HrefToken()];showmessages=[letter]'>\[[letter]\]</a>"
	navbar += "|<a href='byond://?_src_=holder;[HrefToken()];showmemo=1'>\[Memos\]</a>|<a href='byond://?_src_=holder;[HrefToken()];showwatch=1'>\[Watchlist\]</a>"
	navbar += "<br><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	[HrefTokenFormField()]\
	<input type='text' name='searchmessages' value='[index]'>\
	<input type='submit' value='Search'></form>"
	if(!linkless)
		output = navbar
	if(type == "memo" || type == "watchlist entry")
		if(type == "memo")
			output += "<h2><center>Admin memos</h2>"
			output += "<a href='byond://?_src_=holder;[HrefToken()];addmemo=1'>\[Add memo\]</a></center>"
		else if(type == "watchlist entry")
			output += "<h2><center>Watchlist entries</h2>"
			output += "<a href='byond://?_src_=holder;[HrefToken()];addwatchempty=1'>\[Add watchlist entry\]</a>"
			if(filter)
				output += "|<a href='byond://?_src_=holder;[HrefToken()];showwatch=1'>\[Unfilter clients\]</a></center>"
			else
				output += "|<a href='byond://?_src_=holder;[HrefToken()];showwatchfilter=1'>\[Filter offline clients\]</a></center>"
		output += ruler
		var/datum/DBQuery/query_get_type_messages = SSdbcore.NewQuery("SELECT id, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey), targetckey, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), text, timestamp, server, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = lasteditor), expire_timestamp FROM [format_table_name("messages")] WHERE type = :type AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)", list("type" = type))
		if(!query_get_type_messages.warn_execute())
			qdel(query_get_type_messages)
			return
		while(query_get_type_messages.NextRow())
			if(QDELETED(usr))
				return
			var/id = query_get_type_messages.item[1]
			var/t_key = query_get_type_messages.item[2]
			var/t_ckey = query_get_type_messages.item[3]
			if(type == "watchlist entry" && filter && !(t_ckey in GLOB.directory))
				continue
			var/admin_key = query_get_type_messages.item[4]
			var/text = query_get_type_messages.item[5]
			var/timestamp = query_get_type_messages.item[6]
			var/server = query_get_type_messages.item[7]
			var/editor_key = query_get_type_messages.item[8]
			var/expire_timestamp = query_get_type_messages.item[9]
			output += "<b>"
			if(type == "watchlist entry")
				output += "[t_key] | "
			output += "[timestamp] | [server] | [admin_key]"
			if(expire_timestamp)
				output += " | Expires [expire_timestamp]"
			output += "</b>"
			output += " <a href='byond://?_src_=holder;[HrefToken()];editmessageexpiryempty=[id]'>\[Change Expiry Time\]</a>"
			output += " <a href='byond://?_src_=holder;[HrefToken()];deletemessageempty=[id]'>\[Delete\]</a>"
			output += " <a href='byond://?_src_=holder;[HrefToken()];editmessageempty=[id]'>\[Edit\]</a>"
			if(editor_key)
				output += " <font size='2'>Last edit by [editor_key] <a href='byond://?_src_=holder;[HrefToken()];messageedits=[id]'>(Click here to see edit log)</a></font>"
			output += "<br>[text]<hr style='background:#000000; border:0; height:1px'>"
		qdel(query_get_type_messages)
	if(target_ckey)
		var/target_key
		var/datum/DBQuery/query_get_messages = SSdbcore.NewQuery("SELECT type, secret, id, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), text, timestamp, round_id, server, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = lasteditor), DATEDIFF(NOW(), timestamp), (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey), expire_timestamp, playtime FROM [format_table_name("messages")] WHERE type <> 'memo' AND targetckey = :target_ckey AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL) ORDER BY timestamp DESC", list("target_ckey" = target_ckey))
		if(!query_get_messages.warn_execute())
			qdel(query_get_messages)
			return
		var/list/messagedata = list()
		var/list/watchdata = list()
		var/list/notedata = list()
		var/skipped = 0
		while(query_get_messages.NextRow())
			if(QDELETED(usr))
				return
			type = query_get_messages.item[1]
			if(type == "memo")
				continue
			var/secret = text2num(query_get_messages.item[2])
			if(linkless && secret)
				continue
			var/id = query_get_messages.item[3]
			var/admin_key = query_get_messages.item[4]
			var/text = query_get_messages.item[5]
			var/timestamp = query_get_messages.item[6]
			var/roundnumber = query_get_messages.item[7]
			var/server = query_get_messages.item[8]
			var/editor_key = query_get_messages.item[9]
			var/age = text2num(query_get_messages.item[10])
			target_key = query_get_messages.item[11]
			var/expire_timestamp = query_get_messages.item[12]
			var/raw_playtime = query_get_messages.item[13]
			var/playtime = (isnull(raw_playtime) ? "" : " ([get_exp_format(text2num(raw_playtime))])")
			var/alphatext = ""
			var/nsd = CONFIG_GET(number/note_stale_days)
			var/nfd = CONFIG_GET(number/note_fresh_days)
			if (agegate && type == "note" && isnum(nsd) && isnum(nfd) && nsd > nfd)
				var/alpha = clamp(100 - (age - nfd) * (85 / (nsd - nfd)), 15, 100)
				if (alpha < 100)
					if (alpha <= 15)
						if (skipped)
							skipped++
							continue
						alpha = 10
						skipped = TRUE
					alphatext = "filter: alpha(opacity=[alpha]); opacity: [alpha/100];"
			var/list/data = list("<p style='margin:0px;[alphatext]'> <b>[timestamp][playtime] | [server] | [admin_key] | ")
			data += "Round: #<a href='byond://?_src_=holder;[HrefToken()];viewdemo=[roundnumber]'>[roundnumber]</a>"
			if(expire_timestamp)
				data += " | Expires [expire_timestamp]"
			data += "</b>"
			if(!linkless)
				data += " <a href='byond://?_src_=holder;[HrefToken()];editmessageexpiry=[id]'>\[Change Expiry Time\]</a>"
				data += " <a href='byond://?_src_=holder;[HrefToken()];deletemessage=[id]'>\[Delete\]</a>"
				if(type == "note")
					data += " <a href='byond://?_src_=holder;[HrefToken()];secretmessage=[id]'>[secret ? "<b>\[Secret\]</b>" : "\[Not secret\]"]</a>"
				if(type == "message sent")
					data += " <font size='2'>Message has been sent</font>"
					if(editor_key)
						data += "|"
				else
					data += " <a href='byond://?_src_=holder;[HrefToken()];editmessage=[id]'>\[Edit\]</a>"
				if(editor_key)
					data += " <font size='2'>Last edit by [editor_key] <a href='byond://?_src_=holder;[HrefToken()];messageedits=[id]'>(Click here to see edit log)</a></font>"
			data += "<br>[text]</p><hr style='background:#000000; border:0; height:1px; [alphatext]'>"
			switch(type)
				if("message")
					messagedata += data
				if("message sent")
					messagedata += data
				if("watchlist entry")
					watchdata += data
				if("note")
					notedata += data
		qdel(query_get_messages)
		if(!target_key)
			var/datum/DBQuery/query_get_message_key = SSdbcore.NewQuery("SELECT byond_key FROM [format_table_name("player")] WHERE ckey = :target_ckey", list("target_ckey" = target_ckey))
			if(!query_get_message_key.warn_execute())
				qdel(query_get_message_key)
				return
			if(query_get_message_key.NextRow())
				target_key = query_get_message_key.item[1]
			qdel(query_get_message_key)
		output += "<h2><center>[target_key]</center></h2><center>"
		if(!linkless)
			output += "<a href='byond://?_src_=holder;[HrefToken()];addnote=[target_key]'>\[Add note\]</a>"
			output += " <a href='byond://?_src_=holder;[HrefToken()];addmessage=[target_key]'>\[Add message\]</a>"
			output += " <a href='byond://?_src_=holder;[HrefToken()];addwatch=[target_key]'>\[Add to watchlist\]</a>"
			output += " <a href='byond://?_src_=holder;[HrefToken()];showmessageckey=[target_ckey]'>\[Refresh page\]</a></center>"
		else
			output += " <a href='byond://?_src_=holder;[HrefToken()];showmessageckeylinkless=[target_ckey]'>\[Refresh page\]</a></center>"
		output += ruler
		if(messagedata)
			output += "<h4>Messages</h4>"
			output += messagedata
		if(watchdata)
			output += "<h4>Watchlist</h4>"
			output += watchdata
		if(notedata)
			output += "<h4>Notes</h4>"
			output += notedata
			if(!linkless)
				if (agegate)
					if (skipped) //the first skipped message is still shown so that we can put this link over it.
						output += " <center><a href='byond://?_src_=holder;[HrefToken()];showmessageckey=[target_ckey];showall=1' style='position: relative; top: -3em;'>\[Show [skipped] hidden messages\]</center>"
					else
						output += " <center><a href='byond://?_src_=holder;[HrefToken()];showmessageckey=[target_ckey];showall=1'>\[Show All\]</center>"

				else
					output += " <center><a href='byond://?_src_=holder;[HrefToken()];showmessageckey=[target_ckey]'>\[Hide Old\]</center>"
	if(index)
		var/search
		output += "<center><a href='byond://?_src_=holder;[HrefToken()];addmessageempty=1'>\[Add message\]</a><a href='byond://?_src_=holder;[HrefToken()];addwatchempty=1'>\[Add watchlist entry\]</a><a href='byond://?_src_=holder;[HrefToken()];addnoteempty=1'>\[Add note\]</a></center>"
		output += ruler

		switch(index)
			if(1)
				search = "^."
			if(2)
				search = "^\[^\[:alpha:\]\]"
			else
				search = "^[index]"
		var/datum/DBQuery/query_list_messages = SSdbcore.NewQuery({"
			SELECT DISTINCT
				targetckey,
				(SELECT byond_key FROM [format_table_name("player")] WHERE ckey = targetckey)
			FROM [format_table_name("messages")]
			WHERE type <> 'memo'
				AND targetckey REGEXP :search
				AND deleted = 0
				AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)
			ORDER BY targetckey
		"}, list("search" = search))
		if(!query_list_messages.warn_execute())
			qdel(query_list_messages)
			return
		while(query_list_messages.NextRow())
			if(QDELETED(usr))
				return
			var/index_ckey = query_list_messages.item[1]
			var/index_key = query_list_messages.item[2]
			if(!index_key)
				index_key = index_ckey
			output += "<a href='byond://?_src_=holder;[HrefToken()];showmessageckey=[index_ckey]'>[index_key]</a><br>"
		qdel(query_list_messages)
	else if(!type && !target_ckey && !index)
		output += "<center></a> <a href='byond://?_src_=holder;[HrefToken()];addmessageempty=1'>\[Add message\]</a><a href='byond://?_src_=holder;[HrefToken()];addwatchempty=1'>\[Add watchlist entry\]</a><a href='byond://?_src_=holder;[HrefToken()];addnoteempty=1'>\[Add note\]</a></center>"
		output += ruler
	usr << browse({"<!DOCTYPE html><html><head><meta charset='UTF-8'><meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" /></head><body>[jointext(output, "")]</body></html>"}, "window=browse_messages;size=900x500")

/proc/get_message_output(type, target_ckey)
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential=TRUE)
		return
	if(!type)
		return
	var/output
	var/values = list("type" = type)
	var/query = "SELECT id, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = adminckey), text, timestamp, (SELECT byond_key FROM [format_table_name("player")] WHERE ckey = lasteditor) FROM [format_table_name("messages")] WHERE type = :type AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)"
	if(type == "message" || type == "watchlist entry")
		query += " AND targetckey = :target_ckey"
		values["target_ckey"] = target_ckey
	var/datum/DBQuery/query_get_message_output = SSdbcore.NewQuery(query, values)
	if(!query_get_message_output.warn_execute())
		qdel(query_get_message_output)
		return
	while(query_get_message_output.NextRow())
		var/message_id = query_get_message_output.item[1]
		var/admin_key = query_get_message_output.item[2]
		var/text = query_get_message_output.item[3]
		var/timestamp = query_get_message_output.item[4]
		var/editor_key = query_get_message_output.item[5]
		switch(type)
			if("message")
				output += "<font color='red' size='3'><b>Admin message left by [span_prefix("[admin_key]")] on [timestamp]</b></font>"
				output += "<br><font color='red'>[text]</font><br>"
				var/datum/DBQuery/query_message_read = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET type = 'message sent' WHERE id = :message_id", list("message_id" = message_id))
				if(!query_message_read.warn_execute())
					qdel(query_get_message_output)
					qdel(query_message_read)
					return
				qdel(query_message_read)
			if("watchlist entry")
				message_admins("<font color='red'><B>Notice: </B></font><font color='blue'>[key_name_admin(target_ckey)] has been on the watchlist since [timestamp] and has just connected - Reason: [text]</font>")
				send2irc_adminless_only("Watchlist", "[key_name(target_ckey)] is on the watchlist and has just connected - Reason: [text]")
			if("memo")
				output += "<span class='memo'>Memo by [span_prefix("[admin_key]")] on [timestamp]"
				if(editor_key)
					output += "<br><span class='memoedit'>Last edit by [editor_key] <A href='byond://?_src_=holder;[HrefToken()];messageedits=[message_id]'>(Click here to see edit log)</A></span>"
				output += "<br>[text]</span><br>"
	qdel(query_get_message_output)
	return output

#define NOTESFILE "data/player_notes.sav"
//if the AUTOCONVERT_NOTES is turned on, anytime a player connects this will be run to try and add all their notes to the databas
/proc/convert_notes_sql(ckey)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)
		log_game("Error: Cannot access [NOTESFILE]")
		return
	notesfile.cd = "/[ckey]"
	while(!notesfile.eof)
		var/notetext
		notesfile >> notetext
		var/server
		var/ssqlname = CONFIG_GET(string/serversqlname)
		if (ssqlname)
			server = ssqlname
		var/regex/note = new("^(\\d{2}-\\w{3}-\\d{4}) \\| (.+) ~(\\w+)$", "i")
		note.Find(notetext)
		var/timestamp = note.group[1]
		notetext = note.group[2]
		var/admin_ckey = note.group[3]
		var/datum/DBQuery/query_convert_time = SSdbcore.NewQuery("SELECT ADDTIME(STR_TO_DATE(:timestamp,'%d-%b-%Y'), '0')", list("timestamp" = timestamp))
		if(!query_convert_time.Execute())
			qdel(query_convert_time)
			return
		if(query_convert_time.NextRow())
			timestamp = query_convert_time.item[1]
		qdel(query_convert_time)
		if(ckey && notetext && timestamp && admin_ckey && server)
			create_message("note", ckey, admin_ckey, notetext, timestamp, server, 1, 0, null, 0)
	notesfile.cd = "/"
	notesfile.dir.Remove(ckey)

/*alternatively this proc can be run once to pass through every note and attempt to convert it before deleting the file, if done then AUTOCONVERT_NOTES should be turned off
this proc can take several minutes to execute fully if converting and cause DD to hang if converting a lot of notes; it's not advised to do so while a server is live
/proc/mass_convert_notes()
	to_chat(world, "Beginning mass note conversion")
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)
		log_game("Error: Cannot access [NOTESFILE]")
		return
	notesfile.cd = "/"
	for(var/ckey in notesfile.dir)
		convert_notes_sql(ckey)
	to_chat(world, "Deleting NOTESFILE")
	fdel(NOTESFILE)
	to_chat(world, "Finished mass note conversion, remember to turn off AUTOCONVERT_NOTES")*/
#undef NOTESFILE
