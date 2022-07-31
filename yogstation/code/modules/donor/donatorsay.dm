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

	msg = "<b><font color ='#2e87a1'><span class='prefix'>DONATOR CHAT:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"

	if(CONFIG_GET(flag/everyone_is_donator))
		to_chat(GLOB.donators, msg, confidential=TRUE)
	else
		to_chat(GLOB.donators | GLOB.mentors | GLOB.admins | GLOB.deadmins, msg, confidential=TRUE)

/client/proc/get_donator_say()
	var/msg = input(src, null, "Donator Chat \"text\"") as text|null
	cmd_donator_say(msg)
