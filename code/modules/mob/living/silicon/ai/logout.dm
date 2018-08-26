/mob/living/silicon/ai/Logout()
	..()
<<<<<<< HEAD
	for(var/obj/machinery/ai_status_display/O in GLOB.ai_status_displays) //change status
=======
	for(var/each in GLOB.ai_status_displays) //change status
		var/obj/machinery/status_display/ai/O = each
>>>>>>> f470818923... Use faster loops for AI status displays
		O.mode = 0
	view_core()
