GLOBAL_VAR_INIT(waddling, FALSE)

/datum/admins/Secrets_topic()
	. = ..()

	if("waddling")
		if(!check_rights(R_FUN))
			return
		GLOB.waddling = !GLOB.waddling
		message_admins("<span class='danger'>[key_name_admin(usr)] toggled waddling [GLOB.waddling ? "ON" : "OFF"]</span>", 1)
		log_admin("[key_name_admin(usr)] toggled waddling [GLOB.waddling ? "ON" : "OFF"]")

/mob/living/proc/waddle()
	if(incapacitated() || lying)
		return
	animate(src, pixel_z = 4, time = 0)
	animate(pixel_z = 0, transform = turn(matrix(), pick(-12, 0, 12)), time=2)
	animate(pixel_z = 0, transform = matrix(), time = 0)

/mob/living/Move(NewLoc, direct)
	. = ..()
	if(GLOB.waddling)
		waddle()