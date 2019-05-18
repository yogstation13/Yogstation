/mob/living/silicon/pai/ClickOn(var/atom/A, params)
	if(aicamera.in_camera_mode)
		aicamera.camera_mode_off()
<<<<<<< HEAD
		aicamera.captureimage(A, usr)
		return
=======
		aicamera.captureimage(A, usr, null, aicamera.picture_size_x, aicamera.picture_size_y)
		return
>>>>>>> ade1a97e7c... [READY] pAI HUD Overhaul (#43741)
