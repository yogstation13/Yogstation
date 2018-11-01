/proc/webhook_send_roundstatus(var/status, var/extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_asay(var/ckey, var/message)
	var/list/query = list("ckey" = url_encode(ckey), "message" = url_encode(message))
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(var/ckey, var/message)
	var/list/query = list("ckey" = url_encode(ckey), "message" = url_encode(message))
	webhook_send("oocmessage", query)

/proc/webhook_send(var/method, var/data)
	if(!CONFIG_GET(string/webhook_address) || !CONFIG_GET(string/webhook_key))
		return

	var/query = "[CONFIG_GET(string/webhook_address)]?key=[CONFIG_GET(string/webhook_key)]&method=[method]&data=[json_encode(data)]"
	spawn(-1)
		world.Export(query)