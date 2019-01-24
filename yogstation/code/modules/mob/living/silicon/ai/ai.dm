/mob/camera/aiEye/pic_in_pic
	telegraph_cameras = FALSE

/mob/living/silicon/ai/proc/set_core_display_icon_yogs(input)
	var/datum/ai_skin/S = input
	icon = S.icon
	icon_state = S.icon_state