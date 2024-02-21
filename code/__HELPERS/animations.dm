/**
 * Causes the passed atom / image to appear floating,
 * playing a simple animation where they move up and down by 2 pixels (looping)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define DO_FLOATING_ANIM(target) \
	animate(target, pixel_y = 2, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE); \
	animate(pixel_y = -2, time = 1 SECONDS, flags = ANIMATION_RELATIVE)

/**
 * Stops the passed atom / image from appearing floating
 * (Living mobs also have a 'body_position_pixel_y_offset' variable that has to be taken into account here)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define STOP_FLOATING_ANIM(target) \
	var/final_pixel_y = 0; \
	if(ismovable(target)) { \
		var/atom/movable/movable_target = target; \
		final_pixel_y = movable_target.base_pixel_y; \
	}; \
	if(isliving(target)) { \
		var/mob/living/living_target = target; \
		final_pixel_y += living_target.body_position_pixel_y_offset; \
	}; \
	animate(target, pixel_y = final_pixel_y, time = 1 SECONDS)

/// The duration of the animate call in mob/living/update_transform
#define UPDATE_TRANSFORM_ANIMATION_TIME (0.2 SECONDS)

///Animates source spinning around itself. For docmentation on the args, check atom/proc/SpinAnimation()
/atom/proc/do_spin_animation(speed = 1 SECONDS, loops = -1, segments = 3, angle = 120, parallel = TRUE)
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/segment_matrix = matrix(transform)
		segment_matrix.Turn(angle*i)
		matrices += segment_matrix
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loops , flags = ANIMATION_PARALLEL)
	else
		animate(src, transform = matrices[1], time = speed, loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional

/// Similar to shake but more spasm-y and jerk-y
/atom/proc/spasm_animation(loops = -1)
	var/list/transforms = list(
		matrix(transform).Translate(-1, 0),
		matrix(transform).Translate(0, 1),
		matrix(transform).Translate(1, 0),
		matrix(transform).Translate(0, -1),
	)

	animate(src, transform = transforms[1], time = 0.2, loop = loops)
	animate(transform = transforms[2], time = 0.1)
	animate(transform = transforms[3], time = 0.2)
	animate(transform = transforms[4], time = 0.3)


/**
 * Proc called when you want the atom to spin around the center of its icon (or where it would be if its transform var is translated)
 * By default, it makes the atom spin forever and ever at a speed of 60 rpm.
 *
 * Arguments:
 * * speed: how much it takes for the atom to complete one 360° rotation
 * * loops: how many times do we want the atom to rotate
 * * clockwise: whether the atom ought to spin clockwise or counter-clockwise
 * * segments: in how many animate calls the rotation is split. Probably unnecessary, but you shouldn't set it lower than 3 anyway.
 * * parallel: whether the animation calls have the ANIMATION_PARALLEL flag, necessary for it to run alongside concurrent animations.
 */
/atom/proc/SpinAnimation(speed = 1 SECONDS, loops = -1, clockwise = TRUE, segments = 3, parallel = TRUE)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	SEND_SIGNAL(src, COMSIG_ATOM_SPIN_ANIMATION, speed, loops, segments, segment)
	do_spin_animation(speed, loops, segments, segment, parallel)

/atom/proc/DabAnimation(speed = 1, loops = 1, direction = 1 , hold_seconds = 0  , angle = 1 , stay = FALSE) // Hopek 2019  
	// By making this in atom/proc everything in the game can potentially dab. You have been warned.
	if(hold_seconds > 9999) // if you need to hold a dab for more than 2 hours intentionally let me know.
		return
	if(hold_seconds > 0)
		hold_seconds = hold_seconds * 10 // Converts seconds to deciseconds 
	if(angle == 1) //if angle is 1: random angle. Else take angle
		angle = rand(25,50)
	if(direction == 1) // direciton:: 1 for random pick, 2 for clockwise , 3 for anti-clockwise
		direction = pick(2,3)
	if(direction == 3) // if 3 then counter clockwise
		angle = angle * -1
	if(speed == 1) // if speed is 1 choose random speed from list
		speed = rand(3,5)

	// dab matrix here
	var/matrix/DAB_COMMENCE = matrix(transform)
	var/matrix/DAB_RETURN = matrix(transform)
	DAB_COMMENCE.Turn(angle) // dab angle to matrix

	// Dab animation 
	animate(src, transform = DAB_COMMENCE, time = speed, loops ) // dab to hold angle
	if(hold_seconds > 0)
		sleep(hold_seconds) // time to hold the dab before going back
	if(!stay) // if stay param is true dab doesn't return
		animate(transform = DAB_RETURN, time = speed * 1.5, loops ) // reverse dab to starting position , slower
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional
