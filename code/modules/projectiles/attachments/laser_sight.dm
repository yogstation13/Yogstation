/obj/item/attachment/laser_sight
	name = "laser sight"
	desc = "A glorified laser pointer. Good for knowing what you're aiming at."
	icon_state = "laser_sight"
	var/lastangle = 0
	var/aiming_lastangle = 0
	var/aiming_time = 12
	var/aiming_time_left = 12
	var/laser_color = rgb(255,0,0)
	var/listeningTo = null
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/last_beam
	actions_list = list(/datum/action/item_action/toggle_laser_sight, /datum/action/item_action/change_laser_sight_color)

/obj/item/attachment/laser_sight/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>alt-click</b> it to change its color.")

/obj/item/attachment/laser_sight/AltClick(mob/user)
	. = ..()
	var/C = input(user, "Select Laser Color", "Select laser color", laser_color) as null|color
	if(!C || QDELETED(src))
		return
	laser_color = C

/obj/item/attachment/laser_sight/on_attach(obj/item/gun/G, mob/user = null)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	if(is_on)
		G.spread -= 6

/obj/item/attachment/laser_sight/on_detach(obj/item/gun/G, mob/living/user = null)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	if(is_on)
		G.spread += 6
		QDEL_LIST(attached_gun.current_tracers)

/obj/item/attachment/laser_sight/attack_self(mob/user)
	. = ..()
	toggle_on()

/obj/item/attachment/laser_sight/proc/toggle_on()
	is_on = !is_on
	playsound(get_turf(loc), is_on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, 1)
	if(attached_gun)
		if(is_on)
			attached_gun.spread -= 6
		else
			attached_gun.spread += 6
			QDEL_LIST(attached_gun.current_tracers)
	update_icon()

/obj/item/attachment/laser_sight/process()
	return aiming_beam(TRUE)

/obj/item/attachment/laser_sight/proc/aiming_beam(force_update = FALSE)
	if(!is_on)
		return
	if(!attached_gun)
		return PROCESS_KILL
	if(!check_user())
		// Doesn't need to be optimized, runs nothing if the list is already empty
		QDEL_LIST(attached_gun.current_tracers)
		return
	process_aim()
	var/diff = abs(aiming_lastangle - lastangle)
	if(diff < 0.1 && !force_update)
		return
	aiming_lastangle = lastangle
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.gun = attached_gun
	P.color = laser_color
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(current_user.client.mouseObject)
	if(!istype(targloc))
		if(!istype(curloc))
			return
		targloc = get_turf_in_angle(lastangle, curloc, 10)
	P.preparePixelProjectile(targloc, current_user, current_user.client.mouseParams, 0)
	P.fire(lastangle)
	last_beam = P

/obj/item/attachment/laser_sight/equipped(mob/user)
	set_user(user)
	return ..()

/obj/item/attachment/laser_sight/pickup(mob/user)
	set_user(user)
	return ..()

/obj/item/attachment/laser_sight/dropped(mob/user)
	set_user()
	return ..()

/obj/item/attachment/laser_sight/set_user(mob/user = null)
	if(user == current_user)
		return
	aiming_time_left = aiming_time
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null
	if(istype(current_user))
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
		current_user = null
	if(istype(user))
		current_user = user
		LAZYOR(current_user.mousemove_intercept_objects, src)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_mob_move)
		listeningTo = user

/obj/item/attachment/laser_sight/proc/on_mob_move()
	if(!check_user())
		return
	if(is_on)
		delay_penalty(3)
		aiming_beam(TRUE)

/obj/item/attachment/laser_sight/onMouseMove(object, location, control, params)
	. = ..()
	if(is_on)
		aiming_beam()

/obj/item/attachment/laser_sight/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
		var/angle = mouse_angle_from_client(current_user.client)
		current_user.setDir(angle2dir_cardinal(angle))
		var/difference = abs(closer_angle_difference(lastangle, angle))
		delay_penalty(difference * 0.3)
		lastangle = angle

/obj/item/attachment/laser_sight/proc/delay_penalty(amount)
	aiming_time_left = clamp(aiming_time_left + amount, 0, aiming_time)

/obj/item/attachment/laser_sight/Destroy()
	set_user(null)
	listeningTo = null
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_LIST(attached_gun?.current_tracers)
	return ..()
