/client/proc/cmd_donator_say(msg as text)
	set category = "Donator"
	set name = "Donator Chat"
	if(!is_donator(usr))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	msg = pretty_filter(msg)
	msg = emoji_parse(msg)
	log_donator("MSAY: [key_name(src)] : [msg]")

	msg = "<b><font color ='#2e87a1'><span class='prefix donator'>DONATOR CHAT:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message donator'>[msg]</span></font></b>"

	for(var/client/C in GLOB.clients)
		if(is_donator(C))
			to_chat(C, msg, confidential=TRUE, type=MESSAGE_TYPE_DONATOR)
	return

/client/proc/get_donator_say()
	var/msg = input(src, null, "Donator Chat \"text\"") as text|null
	cmd_donator_say(msg)
