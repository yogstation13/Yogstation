/**
 * Used to restore the mob's transform when it is in an undefined state
 * If the mob's transform is not messed up just use update_transform()
 */
/mob/living/proc/rebuild_transform()
	var/matrix/ntransform = matrix()

	/**
	 * pixel x/y/w/z all discard values after the decimal separator.
	 * That, coupled with the rendered interpolation, may make the
	 * icons look awfuller than they already are, or not, whatever.
	 * The solution to this nit is translating the missing decimals.
	 * also flooring increases the distance from 0 for negative numbers.
	 */
	var/abs_pixel_y_offset = 0

	if(lying_angle && rotate_on_lying)
		ntransform.Turn(lying_angle)

	if(current_size != RESIZE_DEFAULT_SIZE)
		ntransform.Scale(current_size)

	//Update final_pixel_y so our mob doesn't go out of the southern bounds of the tile when standing
	if(!lying_angle || !rotate_on_lying) //But not if the mob has been rotated.
		//Make sure the body position y offset is also updated
		body_position_pixel_y_offset = get_pixel_y_offset_standing(current_size)
		abs_pixel_y_offset = abs(body_position_pixel_y_offset)
		var/new_translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(body_position_pixel_y_offset)
		if(new_translate)
			ntransform.Translate(0, new_translate)

	//Update the height of the maptext according to the size of the mob so they don't overlap.
	var/old_maptext_offset = body_maptext_height_offset
	body_maptext_height_offset = initial(maptext_height) * (current_size - 1) * 0.5
	maptext_height += body_maptext_height_offset - old_maptext_offset

	var/pixel_y = base_pixel_y + body_position_pixel_y_offset

	SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)
	animate(src, transform = ntransform, time = 0, pixel_y = pixel_y, dir = dir, easing = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_POST_UPDATE_TRANSFORM, TRUE, lying_angle, TRUE)
