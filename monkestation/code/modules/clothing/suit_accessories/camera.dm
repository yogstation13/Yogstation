/**
 * Bodycamera subtype of Camera
 * Meant to make sure AIs and such cannot use this as pure vision,
 * and can't be 'disabled' by roundstart, though that really shouldn't happen anyway.
 */
/obj/machinery/camera/bodycamera
	start_active = TRUE
	internal_light = FALSE
