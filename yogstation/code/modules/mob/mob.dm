/mob/proc/toggleafreeze(client/admin)
	if(client)
		to_chat(world, "hi")
		client.prefs.afreeze = !client.prefs.afreeze
		to_chat(client, "<span class='userdanger'>You have been [client.prefs.afreeze ? "frozen":"unfrozen"] by [key_name(admin)]</span>")
		log_admin("[key_name(admin)] [client.prefs.afreeze ? "froze":"unfroze"] [key_name(src)].")
		message_admins("[key_name(admin)] [client.prefs.afreeze ? "froze":"unfroze"] [key_name(src, src.client)].")

/mob/canface()
	if(client.prefs.afreeze)
		return FALSE
	..()
