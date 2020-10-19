/client/proc/cmd_mentor_say(msg as text)
	set category = "Mentor"
	set name = "Msay" //Gave this shit a shorter name so you only have to time out "msay" rather than "mentor say" to use it --NeoFite

	if(!is_mentor())
		return
	
	if(msg)
		webhook_send_msay(src, msg)

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	msg = pretty_filter(msg)
	msg = emoji_parse(msg)
	log_mentor("MSAY: [key_name(src)] : [msg]")

	if(check_rights_for(src, R_ADMIN,0))
		msg = "<b><font color ='#8A2BE2'><span class='prefix'>MENTOR:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"
	else
		msg = "<b><font color ='#E236D8'><span class='prefix'>MENTOR:</span> <EM>[key_name(src, 0, 0)]</EM>: <span class='message'>[msg]</span></font></b>"

	to_chat((GLOB.admins - GLOB.deadmins) | GLOB.mentors, msg, confidential=TRUE)

/client/proc/get_mentor_say()
	var/msg = input(src, null, "msay \"text\"") as text
	cmd_mentor_say(msg)
