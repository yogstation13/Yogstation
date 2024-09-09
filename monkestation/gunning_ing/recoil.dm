/obj/item/gun
	///a multiplier of the duration the recoil takes to go back to normal view, this is (recoil*recoil_backtime_multiplier)+1
	var/recoil_backtime_multiplier = 2
	///this is how much deviation the gun recoil can have, recoil pushes the screen towards the reverse angle you shot + some deviation which this is the max.
	var/recoil_deviation = 22.5

/obj/item/gun/ballistic
	recoil = 1
///Makes a recoil-like animation on the mob camera.
/proc/recoil_camera(mob/M, duration, backtime_duration, strength, angle)
	if(!M || !M.client)
		return
	var/client/sufferer = M.client
	strength *= world.icon_size
	var/oldx = sufferer.pixel_x
	var/oldy = sufferer.pixel_y

	//get pixels to move the camera in an angle
	var/mpx = sin(angle) * strength
	var/mpy = cos(angle) * strength
	animate(sufferer, pixel_x = oldx+mpx, pixel_y = oldy+mpy, time = duration, flags = ANIMATION_RELATIVE)
	animate(pixel_x = oldx, pixel_y = oldy, time = backtime_duration, easing = BACK_EASING)
