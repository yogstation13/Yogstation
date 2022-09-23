/proc/webhook_send(var/method, var/data)
	if(!CONFIG_GET(string/webhook_address) || !CONFIG_GET(string/webhook_key))
		return

	data["key"] = CONFIG_GET(string/webhook_key)
	var/url = "[CONFIG_GET(string/webhook_address)]/[method]"
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_POST, url, json_encode(data), list("Content-Type" = "application/json"))
	req.begin_async() //why would we ever want to track the results of the request, meme made by yogstation gang

/proc/webhook(var/ckey, var/message)
	return list("ckey" = ckey, "message" = message)

/proc/webhook_send_roundstatus(var/status, var/extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_asay(var/ckey, var/message)
	var/list/query = webhook(ckey, message)
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(var/ckey, var/message)
	var/list/query = webhook(ckey, message)
	webhook_send("oocmessage", query)

/proc/webhook_send_ticket_unclaimed(var/ckey, var/message, var/id)
	var/list/query = webhook(ckey, message)
	query.Add(list("id" = id, "round" = "[GLOB.round_id ? GLOB.round_id : "NULL"]"))
	webhook_send("ticket_unclaimed", query)

/////////////MENTORS/////////////
/proc/webhook_send_msay(var/ckey, var/message)
	var/list/query = webhook(ckey, message)
	webhook_send("msaymessage", query)

/proc/webhook_send_mhelp(var/ckey, var/message)
	var/list/query = webhook(ckey, message)
	webhook_send("mhelp", query)



/proc/webhook_send_mres(var/ckey, var/ckey2, var/message)
	var/query = list("to" = ckey, "from" = ckey2, "message" = message)
	webhook_send("mres", query)

/proc/webhook_send_mchange(var/ckey, var/ckey2, var/action)
	var/query = list("ckey" = ckey, "ckey2" = ckey2, "action" = action)
	webhook_send("mchange", query)

