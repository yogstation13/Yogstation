/client/proc/FireNuke()
	set name = "Tactical Nuke"
	set category = "Admin"
	set desc = "Launches a tactical nuke at the station."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(check_rights(R_ADMIN,1))
		var/our_badmin = usr
		var/areyouDrunk = input(our_badmin, "Please confirm action, this is highly destructive!", "Centcom Nuclear Failsafe") in list("YES","NO")
		switch(areyouDrunk)
			if("YES")
				log_admin("[key_name(usr)] launched a nuke at the station!", 1)
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] launched a nuke at the station!</span>")
				SSweather.run_weather("nuclear detonation",2)
				return TRUE
			if("NO")
				log_admin("[key_name(usr)] Resisted the temptation to press the nuclear launch button.", 1)
				return FALSE