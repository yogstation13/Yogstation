/proc/webhook_send(method, data)
	set waitfor = FALSE
	if(!CONFIG_GET(string/webhook_address) || !CONFIG_GET(string/webhook_key))
		return

	data["key"] = CONFIG_GET(string/webhook_key)
	var/url = "[CONFIG_GET(string/webhook_address)]/[method]"
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_POST, url, json_encode(data), list("Content-Type" = "application/json"))
	req.begin_async() //why would we ever want to track the results of the request, meme made by yogstation gang
	UNTIL(req.is_complete()) //what if we actually wanted to clean these up

/proc/webhook(ckey, message)
	return list("ckey" = ckey, "message" = message)

/proc/webhook_send_roundstatus(status, extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_asay(ckey, message)
	var/list/query = webhook(ckey, message)
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(ckey, message)
	var/list/query = webhook(ckey, message)
	webhook_send("oocmessage", query)

/proc/webhook_send_ticket_unclaimed(ckey, message, id)
	var/list/query = webhook(ckey, message)
	query.Add(list("id" = id, "round" = "[GLOB.round_id ? GLOB.round_id : "NULL"]"))
	webhook_send("ticket_unclaimed", query)

//////// Discord Tickets /////////
/proc/webhook_send_ticket_new(ckey, message, id)
	var/list/query = webhook(ckey, message)
	query.Add(list("id" = id, "round" = GLOB.round_id ? GLOB.round_id : 0))
	webhook_send("ticket_new", query)

/proc/webhook_send_ticket_administer(admin_ckey, id)
	webhook_send("ticket_administer", list("ckey" = admin_ckey, "id" = id))

/proc/webhook_send_ticket_interaction(ckey, message, id)
	var/list/query = webhook(ckey, message)
	query.Add(list("id" = id))
	webhook_send("ticket_interaction", query)

/proc/webhook_send_ticket_resolve(id, resolved)
	webhook_send("ticket_resolve", list("id" = id, "resolved" = resolved))

/proc/webhook_send_ticket_refresh()
	var/data = list()
	data["round_id"] = GLOB.round_id ? GLOB.round_id : 0
	data["tickets"] = list()
	for(var/I in GLOB.ahelp_tickets.tickets_list)
		var/datum/admin_help/AH = I
		var/list/ticket_data = list(
			"id" = AH.id,
			"title" = AH.name,
			"ckey" = AH.initiator_ckey,
			"admin" = AH.handling_admin_ckey ? AH.handling_admin_ckey : "Unclaimed",
			"resolved" = AH.state != AHELP_ACTIVE,
			"interactions" = list()
		)
		for(var/datum/ticket_log/TL as anything in AH._interactions)
			ticket_data["interactions"] += "[TL.user]: [TL.text]"
		
		data["tickets"] += list(ticket_data)
	webhook_send("ticket_refresh", data)

/////////////MENTORS/////////////
/proc/webhook_send_msay(ckey, message)
	var/list/query = webhook(ckey, message)
	webhook_send("msaymessage", query)

/proc/webhook_send_mhelp(ckey, message)
	var/list/query = webhook(ckey, message)
	webhook_send("mhelp", query)



/proc/webhook_send_mres(ckey, ckey2, message)
	var/query = list("to" = ckey, "from" = ckey2, "message" = message)
	webhook_send("mres", query)

/proc/webhook_send_mchange(ckey, ckey2, action)
	var/query = list("ckey" = ckey, "ckey2" = ckey2, "action" = action)
	webhook_send("mchange", query)

