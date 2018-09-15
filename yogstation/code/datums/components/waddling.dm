/datum/component/waddling
	var/waddle_min = -12
	var/waddle_max = 12
	var/z_change = 4
	var/anim_time = 2

/datum/component/waddling/Waddle()
	var/mob/living/L = parent
	if (!L)
		return
	if (L.incapacitated() || L.lying)
		return
	animate(L, pixel_z = z_change, time = 0)
	animate(pixel_z = 0, transform = turn(matrix(), pick(waddle_min, 0, waddle_max)), time = anim_time)
	animate(pixel_z = 0, transform = matrix(), time = 0)