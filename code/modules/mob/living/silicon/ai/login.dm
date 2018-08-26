/mob/living/silicon/ai/Login()
	..()
	if(stat != DEAD)
<<<<<<< HEAD
		for(var/obj/machinery/ai_status_display/O in GLOB.ai_status_displays) //change status
=======
		for(var/each in GLOB.ai_status_displays) //change status
			var/obj/machinery/status_display/ai/O = each
>>>>>>> f470818923... Use faster loops for AI status displays
			O.mode = 1
			O.emotion = "Neutral"
	if(multicam_on)
		end_multicam()
	view_core()
