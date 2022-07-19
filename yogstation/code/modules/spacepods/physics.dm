/obj/spacepod/process(time)
	time /= 10 // fuck off with your deciseconds // uh oh

	if(world.time > last_slowprocess + 15)
		last_slowprocess = world.time
		slowprocess()

	var/last_offset_x = offset_x
	var/last_offset_y = offset_y
	var/last_angle = angle
	var/desired_angular_velocity = 0
	if(isnum(desired_angle))
		// do some finagling to make sure that our angles end up rotating the short way
		while(angle > desired_angle + 180)
			angle -= 360
			last_angle -= 360
		while(angle < desired_angle - 180)
			angle += 360
			last_angle += 360
		if(abs(desired_angle - angle) < (max_angular_acceleration * time))
			desired_angular_velocity = (desired_angle - angle) / time
		else if(desired_angle > angle)
			desired_angular_velocity = 2 * sqrt((desired_angle - angle) * max_angular_acceleration * 0.25)
		else
			desired_angular_velocity = -2 * sqrt((angle - desired_angle) * max_angular_acceleration * 0.25)
	var/angular_velocity_adjustment = clamp(desired_angular_velocity - angular_velocity, -max_angular_acceleration*time, max_angular_acceleration*time)
	if(angular_velocity_adjustment && cell && cell.use(abs(angular_velocity_adjustment) * 0.05))
		last_rotate = angular_velocity_adjustment / time
		angular_velocity += angular_velocity_adjustment
	else
		last_rotate = 0
	angle += angular_velocity * time

	// calculate drag and shit

	var/velocity_mag = sqrt(velocity_x*velocity_x+velocity_y*velocity_y) // magnitude
	if(velocity_mag || angular_velocity)
		var/drag = 0
		for(var/turf/T in locs)
			if(isspaceturf(T))
				continue
			drag += 0.001
			var/floating = FALSE
			if(T.has_gravity() && !brakes && velocity_mag > 0.1 && cell && cell.use((is_mining_level(z) ? 3 : 15) * time))
				floating = TRUE // want to fly this shit on the station? Have fun draining your battery.
			if((!floating && T.has_gravity()) || brakes) // brakes are a kind of magboots okay?
				drag += is_mining_level(z) ? 0.1 : 0.5 // some serious drag. Damn. Except lavaland, it has less gravity or something
				if(velocity_mag > 5 && prob(velocity_mag * 4) && istype(T, /turf/open/floor))
					var/turf/open/floor/TF = T
					TF.make_plating() // pull up some floor tiles. Stop going so fast, ree.
					take_damage(3, BRUTE, MELEE, FALSE)
			var/datum/gas_mixture/env = T.return_air()
			if(env)
				var/pressure = env.return_pressure()
				drag += velocity_mag * pressure * 0.0001 // 1 atmosphere should shave off 1% of velocity per tile
		if(velocity_mag > 20)
			drag = max(drag, (velocity_mag - 20) / time)
		if(drag)
			if(velocity_mag)
				var/drag_factor = 1 - clamp(drag * time / velocity_mag, 0, 1)
				velocity_x *= drag_factor
				velocity_y *= drag_factor
			if(angular_velocity != 0)
				var/drag_factor_spin = 1 - clamp(drag * 30 * time / abs(angular_velocity), 0, 1)
				angular_velocity *= drag_factor_spin

	// Alright now calculate the THRUST
	var/thrust_x
	var/thrust_y
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle)
	var/sx = fy
	var/sy = -fx
	last_thrust_forward = 0
	last_thrust_right = 0
	if(brakes)
		if(user_thrust_dir)
			to_chat(pilot, span_warning("Your brakes are on!"))
		// basically calculates how much we can brake using the thrust
		var/forward_thrust = -((fx * velocity_x) + (fy * velocity_y)) / time
		var/right_thrust = -((sx * velocity_x) + (sy * velocity_y)) / time
		forward_thrust = clamp(forward_thrust, -backward_maxthrust, forward_maxthrust)
		right_thrust = clamp(right_thrust, -side_maxthrust, side_maxthrust)
		thrust_x += forward_thrust * fx + right_thrust * sx;
		thrust_y += forward_thrust * fy + right_thrust * sy;
		last_thrust_forward = forward_thrust
		last_thrust_right = right_thrust
	else // want some sort of help piloting the ship? Haha no fuck you do it yourself
		if(user_thrust_dir & NORTH)
			thrust_x += fx * forward_maxthrust
			thrust_y += fy * forward_maxthrust
			last_thrust_forward = forward_maxthrust
		if(user_thrust_dir & SOUTH)
			thrust_x -= fx * backward_maxthrust
			thrust_y -= fy * backward_maxthrust
			last_thrust_forward = -backward_maxthrust
		if(user_thrust_dir & EAST)
			thrust_x += sx * side_maxthrust
			thrust_y += sy * side_maxthrust
			last_thrust_right = side_maxthrust
		if(user_thrust_dir & WEST)
			thrust_x -= sx * side_maxthrust
			thrust_y -= sy * side_maxthrust
			last_thrust_right = -side_maxthrust

	if(cell && cell.use(10 * sqrt((thrust_x*thrust_x)+(thrust_y*thrust_y)) * time))
		velocity_x += thrust_x * time
		velocity_y += thrust_y * time
	else
		last_thrust_forward = 0
		last_thrust_right = 0
		if(!brakes && user_thrust_dir)
			to_chat(pilot, span_warning("You are out of power!"))

	offset_x += velocity_x * time
	offset_y += velocity_y * time
	// alright so now we reconcile the offsets with the in-world position.
	while((offset_x > 0 && velocity_x > 0) || (offset_y > 0 && velocity_y > 0) || (offset_x < 0 && velocity_x < 0) || (offset_y < 0 && velocity_y < 0))
		var/failed_x = FALSE
		var/failed_y = FALSE
		if(offset_x > 0 && velocity_x > 0)
			dir = EAST
			if(!Move(get_step(src, EAST)))
				offset_x = 0
				failed_x = TRUE
				velocity_x *= -bounce_factor
				velocity_y *= lateral_bounce_factor
			else
				offset_x--
				last_offset_x--
		else if(offset_x < 0 && velocity_x < 0)
			dir = WEST
			if(!Move(get_step(src, WEST)))
				offset_x = 0
				failed_x = TRUE
				velocity_x *= -bounce_factor
				velocity_y *= lateral_bounce_factor
			else
				offset_x++
				last_offset_x++
		else
			failed_x = TRUE
		if(offset_y > 0 && velocity_y > 0)
			dir = NORTH
			if(!Move(get_step(src, NORTH)))
				offset_y = 0
				failed_y = TRUE
				velocity_y *= -bounce_factor
				velocity_x *= lateral_bounce_factor
			else
				offset_y--
				last_offset_y--
		else if(offset_y < 0 && velocity_y < 0)
			dir = SOUTH
			if(!Move(get_step(src, SOUTH)))
				offset_y = 0
				failed_y = TRUE
				velocity_y *= -bounce_factor
				velocity_x *= lateral_bounce_factor
			else
				offset_y++
				last_offset_y++
		else
			failed_y = TRUE
		if(failed_x && failed_y)
			break
	// prevents situations where you go "wtf I'm clearly right next to it" as you enter a stationary spacepod
	if(velocity_x == 0)
		if(offset_x > 0.5)
			if(Move(get_step(src, EAST)))
				offset_x--
				last_offset_x--
			else
				offset_x = 0
		if(offset_x < -0.5)
			if(Move(get_step(src, WEST)))
				offset_x++
				last_offset_x++
			else
				offset_x = 0
	if(velocity_y == 0)
		if(offset_y > 0.5)
			if(Move(get_step(src, NORTH)))
				offset_y--
				last_offset_y--
			else
				offset_y = 0
		if(offset_y < -0.5)
			if(Move(get_step(src, SOUTH)))
				offset_y++
				last_offset_y++
			else
				offset_y = 0
	dir = NORTH
	var/matrix/mat_from = new()
	mat_from.Turn(last_angle)
	var/matrix/mat_to = new()
	mat_to.Turn(angle)
	transform = mat_from
	pixel_x = last_offset_x*32
	pixel_y = last_offset_y*32
	animate(src, transform=mat_to, pixel_x = offset_x*32, pixel_y = offset_y*32, time = time SECONDS, flags=ANIMATION_END_NOW)
	for(var/mob/living/M in contents)
		var/client/C = M.client
		if(!C)
			continue
		C.pixel_x = last_offset_x*32
		C.pixel_y = last_offset_y*32
		animate(C, pixel_x = offset_x*32, pixel_y = offset_y*32, time = time SECONDS, flags=ANIMATION_END_NOW)
	user_thrust_dir = 0
	update_icon()

/obj/spacepod/Bumped(atom/movable/A)
	if(A.dir & NORTH)
		velocity_y += bump_impulse
	if(A.dir & SOUTH)
		velocity_y -= bump_impulse
	if(A.dir & EAST)
		velocity_x += bump_impulse
	if(A.dir & WEST)
		velocity_x -= bump_impulse
	return ..()

/obj/spacepod/Bump(atom/A)
	var/bump_velocity = 0
	if(dir & (NORTH|SOUTH))
		bump_velocity = abs(velocity_y) + (abs(velocity_x) / 15)
	else
		bump_velocity = abs(velocity_x) + (abs(velocity_y) / 15)
	if(istype(A, /obj/machinery/door/airlock)) // try to open doors
		var/obj/machinery/door/D = A
		if(!D.operating)
			if(D.allowed(D.requiresID() ? pilot : null))
				spawn(0)
					D.open()
			else
				D.do_animate("deny")
	var/atom/movable/AM = A
	if(istype(AM) && !AM.anchored && bump_velocity > 1)
		step(AM, dir)
	// if a bump is that fast then it's not a bump. It's a collision.
	if(bump_velocity > 10 && !ismob(A))
		var/strength = bump_velocity / 10
		strength = strength * strength
		strength = min(strength, 5) // don't want the explosions *too* big
		// wew lad, might wanna slow down there
		explosion(A, -1, round((strength - 1) / 2), round(strength))
		message_admins("[key_name_admin(pilot)] has impacted a spacepod into [A] with velocity [bump_velocity]")
		take_damage(strength*10, BRUTE, MELEE, TRUE)
		log_game("[key_name(pilot)] has impacted a spacepod into [A] with velocity [bump_velocity]")
		visible_message(span_danger("The force of the impact causes a shockwave"))
	else if(isliving(A) && bump_velocity > 5)
		var/mob/living/M = A
		M.apply_damage(bump_velocity * 2)
		take_damage(bump_velocity, BRUTE, MELEE, FALSE)
		playsound(M.loc, "swing_hit", 1000, 1, -1)
		M.Knockdown(bump_velocity * 2)
		M.visible_message(span_warning("The force of the impact knocks [M] down!"),span_userdanger("The force of the impact knocks you down!"))
		log_combat(pilot, M, "impacted", src, "with velocity of [bump_velocity]")
	return ..()

/obj/spacepod/proc/fire_projectiles(proj_type, target) // if spacepods of other sizes are added override this or something
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle)
	var/sx = fy
	var/sy = -fx
	var/ox = (offset_x * 32) + 16
	var/oy = (offset_y * 32) + 16
	var/list/origins = list(list(ox + fx*16 - sx*16, oy + fy*16 - sy*16), list(ox + fx*16 + sx*16, oy + fy*16 + sy*16))
	for(var/list/origin in origins)
		var/this_x = origin[1]
		var/this_y = origin[2]
		var/turf/T = get_turf(src)
		while(this_x > 16)
			T = get_step(T, EAST)
			this_x -= 32
		while(this_x < -16)
			T = get_step(T, WEST)
			this_x += 32
		while(this_y > 16)
			T = get_step(T, NORTH)
			this_y -= 32
		while(this_y < -16)
			T = get_step(T, SOUTH)
			this_y += 32
		if(!T)
			continue
		var/obj/item/projectile/proj = new proj_type(T)
		proj.starting = T
		proj.firer = usr
		proj.def_zone = "chest"
		proj.original = target
		proj.pixel_x = round(this_x)
		proj.pixel_y = round(this_y)
		spawn()
			proj.fire(angle)
