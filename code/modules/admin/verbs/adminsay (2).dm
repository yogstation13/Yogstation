/client/proc/cmd_admin_say(msg as text)
	set category = "Misc.Unused"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(0))
		return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	webhook_send_asay(key_name(src), msg)

	msg = sanitize(msg)
	msg = to_utf8(msg)

	mob.log_talk(msg, LOG_ADMIN_PRIVATE)

	msg = emoji_parse(msg)
	msg = keywords_lookup(msg)
	if(check_rights(R_ADMIN,0))
		msg = "<span class='adminsay'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(mob)]: <span class='message'>[msg]</span></span>"
		to_chat(GLOB.admins, msg, confidential=TRUE)
	else
		msg = "<span class='adminsay'><span class='prefix'>OBSERVER:</span> <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(mob)]: <span class='message'>[msg]</span></span>"
		to_chat(GLOB.admins, msg, confidential=TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Asay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_admin_say()
	var/msg = input(src, null, "asay \"text\"") as text|null
	msg = to_utf8(msg)
	cmd_admin_say(msg)
