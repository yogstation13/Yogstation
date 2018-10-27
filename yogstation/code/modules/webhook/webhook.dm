/proc/webhook_send(var/method, var/data)
	if(!CONFIG_GET(string/webhook_address) || !CONFIG_GET(string/webhook_key))
		return

	var/query = "[CONFIG_GET(string/webhook_address)]?key=[CONFIG_GET(string/webhook_key)]&method=[method]&data=[json_encode(data)]"
	spawn(-1)
		world.Export(query)

/proc/webhook(var/ckey, var/message)
	return list("ckey" = url_encode(ckey), "message" = url_encode(message))

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


/////////////MENTORS/////////////
/proc/webhook_send_msay(var/ckey, var/message)
	var/list/query = webhook(ckey, message)
	webhook_send("msaymessage", query)

/proc/webhook_send_mhelp(var/ckey, var/message)
	var/list/query = webhook(ckey, message)
	webhook_send("msay", query)



/proc/webhook_send_mres(var/ckey, var/ckey2, var/message)
	var/query = list("to" = url_encode(ckey), "from" = url_encode(ckey2), "message" = url_encode(message))
	webhook_send("mres", query)

/proc/webhook_send_mchange(var/ckey, var/ckey2, var/action)
	var/query = list("ckey" = url_encode(ckey), "ckey2" = url_encode(ckey2), "action" = url_encode(action))
	webhook_send("mchange", query)