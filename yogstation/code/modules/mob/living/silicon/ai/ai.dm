/mob/camera/aiEye/pic_in_pic
	telegraph_cameras = FALSE

/mob/living/silicon/ai/proc/set_core_display_icon_yogs(input)
	var/datum/ai_skin/S = input
	
	for (var/each in GLOB.ai_core_displays) //change status of displays
		var/obj/machinery/status_display/ai_core/M = each
		M.set_ai(S.icon_state, S.icon)
		M.update()
