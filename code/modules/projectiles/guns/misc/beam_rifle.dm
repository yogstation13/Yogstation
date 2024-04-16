
#define ZOOM_LOCK_AUTOZOOM_FREEMOVE 0
#define ZOOM_LOCK_AUTOZOOM_ANGLELOCK 1
#define ZOOM_LOCK_CENTER_VIEW 2
#define ZOOM_LOCK_OFF 3

#define AUTOZOOM_PIXEL_STEP_FACTOR 48

#define AIMING_BEAM_ANGLE_CHANGE_THRESHOLD 0.1

/obj/item/gun/energy/beam_rifle
	name = "particle acceleration rifle"
	desc = "An energy-based anti material marksman rifle that uses highly charged particle beams moving at extreme velocities to decimate whatever is unfortunate enough to be targeted by one. \
		<span class='boldnotice'>Hold down left click while scoped to aim, when weapon is fully aimed (Tracer goes from red to green as it charges), release to fire. Moving while aiming or \
		changing where you're pointing at while aiming will delay the aiming process depending on how much you changed.</span>"
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "esniper"
	item_state = "esniper"
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	slot_flags = ITEM_SLOT_BACK
	force = 15
	materials = list()
	recoil = 4
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan/piercing, /obj/item/ammo_casing/energy/beam_rifle/hitscan/impact)
	actions_types = list(/datum/action/item_action/zoom_lock_action)
	cell_type = /obj/item/stock_parts/cell/beam_rifle
	canMouseDown = TRUE
	pin = null
	var/aiming = FALSE
	var/aiming_time = 12
	var/aiming_time_fire_threshold = 5
	var/aiming_time_left = 12
	var/aiming_time_increase_user_movement = 3
	var/scoped_slow = 1
	var/aiming_time_increase_angle_multiplier = 0.3
	var/last_process = 0

	var/lastangle = 0
	var/aiming_lastangle = 0
	var/mob/current_user = null

	var/delay = 25
	var/lastfire = 0

	//ZOOMING
	var/zoom_current_view_increase = 0
	///The radius you want to zoom by
	var/zoom_target_view_increase = 9.5
	var/zooming = FALSE
	var/zoom_lock = ZOOM_LOCK_OFF
	var/zooming_angle
	var/current_zoom_x = 0
	var/current_zoom_y = 0

	var/static/image/charged_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_charged")
	var/static/image/drained_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_empty")

	var/mob/listeningTo

/obj/item/gun/energy/beam_rifle/debug
	delay = 0
	cell_type = /obj/item/stock_parts/cell/infinite
	aiming_time = 0
	recoil = 0
	pin = /obj/item/firing_pin

/obj/item/gun/energy/beam_rifle/equipped(mob/user)
	set_user(user)
	return ..()

/obj/item/gun/energy/beam_rifle/pickup(mob/user)
	set_user(user)
	return ..()

/obj/item/gun/energy/beam_rifle/dropped(mob/user)
	set_user()
	return ..()

/obj/item/gun/energy/beam_rifle/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/zoom_lock_action))
		zoom_lock++
		if(zoom_lock > 3)
			zoom_lock = 0
		switch(zoom_lock)
			if(ZOOM_LOCK_AUTOZOOM_FREEMOVE)
				to_chat(user, span_boldnotice("You switch [src]'s zooming processor to free directional."))
			if(ZOOM_LOCK_AUTOZOOM_ANGLELOCK)
				to_chat(user, span_boldnotice("You switch [src]'s zooming processor to locked directional."))
			if(ZOOM_LOCK_CENTER_VIEW)
				to_chat(user, span_boldnotice("You switch [src]'s zooming processor to center mode."))
			if(ZOOM_LOCK_OFF)
				to_chat(user, span_boldnotice("You disable [src]'s zooming system."))
		reset_zooming()
		return

	return ..()

/obj/item/gun/energy/beam_rifle/proc/set_autozoom_pixel_offsets_immediate(current_angle)
	if(zoom_lock == ZOOM_LOCK_CENTER_VIEW || zoom_lock == ZOOM_LOCK_OFF)
		return
	current_zoom_x = sin(current_angle) + sin(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase
	current_zoom_y = cos(current_angle) + cos(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase

/obj/item/gun/energy/beam_rifle/proc/handle_zooming()
	if(!zooming || !check_user())
		return
	current_user.client.view_size.setTo(zoom_target_view_increase)
	zoom_current_view_increase = zoom_target_view_increase
	set_autozoom_pixel_offsets_immediate(zooming_angle)

/obj/item/gun/energy/beam_rifle/proc/start_zooming()
	if(zoom_lock == ZOOM_LOCK_OFF)
		return
	zooming = TRUE

/obj/item/gun/energy/beam_rifle/proc/stop_zooming(mob/user)
	if(zooming)
		zooming = FALSE
		reset_zooming(user)

/obj/item/gun/energy/beam_rifle/proc/reset_zooming(mob/user)
	if(!user)
		user = current_user
	if(!user || !user.client)
		return FALSE
	user.client.view_size.zoomIn()
	zoom_current_view_increase = 0
	zooming_angle = 0
	current_zoom_x = 0
	current_zoom_y = 0

/obj/item/gun/energy/beam_rifle/update_overlays()
	. = ..()
	var/obj/item/ammo_casing/energy/primary_ammo = ammo_type[1]
	if(!QDELETED(cell) && (cell.charge >= primary_ammo.e_cost))
		. += charged_overlay
	else
		. += drained_overlay

/obj/item/gun/energy/beam_rifle/select_fire(mob/living/user)
	. = ..()
	aiming_beam()

/obj/item/gun/energy/beam_rifle/proc/update_slowdown()
	if(aiming)
		slowdown = scoped_slow
	else
		slowdown = initial(slowdown)

/obj/item/gun/energy/beam_rifle/Initialize(mapload)
	. = ..()
	fire_delay = delay
	START_PROCESSING(SSfastprocess, src)

/obj/item/gun/energy/beam_rifle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	set_user(null)
	QDEL_LIST(current_tracers)
	listeningTo = null
	return ..()

/obj/item/gun/energy/beam_rifle/proc/aiming_beam(force_update = FALSE)
	var/diff = abs(aiming_lastangle - lastangle)
	check_user()
	if(diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD && !force_update)
		return
	aiming_lastangle = lastangle
	var/obj/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.fired_from = src
	if(aiming_time)
		var/percent = ((100/aiming_time)*aiming_time_left)
		P.color = rgb(255 * percent,255 * ((100 - percent) / 100),0)
	else
		P.color = rgb(0, 255, 0)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(current_user.client.mouse_object_ref?.resolve())
	if(!istype(targloc))
		if(!istype(curloc))
			return
		targloc = get_turf_in_angle(lastangle, curloc, 10)
	P.preparePixelProjectile(targloc, current_user, current_user.client.mouseParams, 0)
	P.fire(lastangle)

/obj/item/gun/energy/beam_rifle/process()
	if(!aiming)
		last_process = world.time
		return
	check_user()
	handle_zooming()
	aiming_time_left = max(0, aiming_time_left - (world.time - last_process))
	aiming_beam(TRUE)
	last_process = world.time

/obj/item/gun/energy/beam_rifle/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		if(automatic_cleanup)
			stop_aiming()
			set_user(null)
		return FALSE
	return TRUE

/obj/item/gun/energy/beam_rifle/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
		var/angle = mouse_angle_from_client(current_user.client)
		current_user.setDir(angle2dir_cardinal(angle))
		var/difference = abs(closer_angle_difference(lastangle, angle))
		delay_penalty(difference * aiming_time_increase_angle_multiplier)
		lastangle = angle

/obj/item/gun/energy/beam_rifle/proc/on_mob_move()
	check_user()
	if(aiming)
		delay_penalty(aiming_time_increase_user_movement)
		process_aim()
		aiming_beam(TRUE)

/obj/item/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE
	process_aim()
	aiming_beam(TRUE)
	zooming_angle = lastangle
	start_zooming()

/obj/item/gun/energy/beam_rifle/proc/stop_aiming(mob/user)
	set waitfor = FALSE
	aiming_time_left = aiming_time
	aiming = FALSE
	QDEL_LIST(current_tracers)
	stop_zooming(user)

/obj/item/gun/energy/beam_rifle/proc/set_user(mob/user)
	if(user == current_user)
		return
	stop_aiming(current_user)
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null
	if(istype(current_user))
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
		current_user = null
	if(istype(user))
		current_user = user
		LAZYOR(current_user.mousemove_intercept_objects, src)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
		listeningTo = user

/obj/item/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	if(aiming)
		process_aim()
		aiming_beam()
		if(zoom_lock == ZOOM_LOCK_AUTOZOOM_FREEMOVE)
			zooming_angle = lastangle
			set_autozoom_pixel_offsets_immediate(zooming_angle)
	return ..()

/obj/item/gun/energy/beam_rifle/onMouseDown(object, location, params, mob/mob)
	if(istype(mob))
		set_user(mob)
	if(istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	start_aiming()
	return ..()

/obj/item/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	if(istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher))
		return
	process_aim()
	if(aiming_time_left <= aiming_time_fire_threshold && check_user())
		var/atom/target = M.client.mouse_object_ref?.resolve()
		if(target)
			afterattack(target, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()
	QDEL_LIST(current_tracers)
	return ..()

/obj/item/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != BODY_ZONE_PRECISE_MOUTH) //so we can't shoot ourselves (unless mouth selected)
			return
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	if(lastfire > world.time + delay)
		return
	lastfire = world.time
	. = ..()
	stop_aiming()

/obj/item/gun/energy/beam_rifle/proc/delay_penalty(amount)
	aiming_time_left = clamp(aiming_time_left + amount, 0, aiming_time)

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	select_name = "beam"
	e_cost = 10000
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/item/ammo_casing/energy/beam_rifle/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if(!istype(curloc) || !BB)
		return FALSE
	var/obj/item/gun/energy/beam_rifle/gun = loc
	if(!targloc && gun)
		targloc = get_turf_in_angle(gun.lastangle, curloc, 10)
	else if(!targloc)
		return FALSE
	var/firing_dir
	if(BB.firer)
		firing_dir = BB.firer.dir
	if(!BB.suppressed && firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)
	BB.preparePixelProjectile(target, user, params, spread)
	BB.fire(gun? gun.lastangle : null, null)
	BB = null
	return TRUE

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/projectile/beam/beam_rifle/hitscan

/obj/item/ammo_casing/energy/beam_rifle/hitscan/impact
	projectile_type = /obj/projectile/beam/beam_rifle/hitscan/impact
	select_name = "impact"

/obj/item/ammo_casing/energy/beam_rifle/hitscan/piercing
	projectile_type = /obj/projectile/beam/beam_rifle/hitscan/piercing
	select_name = "pierce"

/obj/projectile/beam/beam_rifle
	name = "particle beam"
	icon = null
	hitsound = 'sound/effects/explosion3.ogg'
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	range = 150
	jitter = 10
	demolition_mod = 4
	can_ricoshot = ALWAYS_RICOSHOT
	var/aoe_range = 0
	var/aoe_fire_chance = 0
	var/tracer_fire_chance = 0
	var/fire_color = "green"

/obj/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle
	var/constant_tracer = FALSE

/obj/projectile/beam/beam_rifle/hitscan/piercing
	damage = 60 // same as the impact version, but applied all at once
	aoe_range = 0 // no AOE, has piercing instead
	penetrations = 2
	tracer_fire_chance = 50
	penetration_flags = PENETRATE_OBJECTS | PENETRATE_MOBS

/obj/projectile/beam/beam_rifle/hitscan/impact
	damage = 30 // total of 60 on direct hit
	aoe_range = 2
	aoe_fire_chance = 50
	tracer_fire_chance = 20

/obj/projectile/beam/beam_rifle/Move(atom/newloc, dir)
	. = ..()
	if(prob(tracer_fire_chance))
		var/turf/new_turf = newloc
		new_turf.ignite_turf(rand(16, 22), fire_color) // FIRE IN THE HOLE!!!!

/obj/projectile/beam/beam_rifle/proc/do_area_damage(turf/epicenter)
	set waitfor = FALSE
	if(!epicenter)
		return
	new /obj/effect/temp_visual/explosion/fast(epicenter)
	for(var/turf/T in spiral_range_turfs(aoe_range, epicenter))
		var/modified_damage = damage / max(get_dist(epicenter, T), 1) // damage decreases with range
		if(prob(aoe_fire_chance))
			T.ignite_turf(rand(16, 22), fire_color)
		for(var/mob/living/L in T) //handle aoe mob damage
			L.apply_damage(modified_damage, BURN, null, L.getarmor(null, BOMB))
			to_chat(L, span_userdanger("\The [src] sears you!"))
		for(var/obj/O in T)
			O.take_damage(modified_damage, BURN, BOMB, FALSE)

/obj/projectile/beam/beam_rifle/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/turf/target_turf = (isclosedturf(target) && penetrations <= 0) ? get_turf(src) : get_turf(target)
	playsound(target_turf, 'sound/effects/explosion3.ogg', 100, 1)
	if(isclosedturf(target)) // if hitting a wall
		SSexplosions.lowturf += target
	target_turf.ignite_turf(rand(16, 22), fire_color)
	if(aoe_range)
		do_area_damage(target_turf)

/obj/projectile/beam/beam_rifle/hitscan/generate_hitscan_tracers(cleanup = TRUE, duration = 5, impacting = TRUE, highlander)
	set waitfor = FALSE
	if(isnull(highlander))
		highlander = constant_tracer

	if(highlander && istype(fired_from, /obj/item/gun))
		var/obj/item/gun/gun = fired_from
		QDEL_LIST(gun.current_tracers)
		for(var/datum/point/p in beam_segments)
			gun.current_tracers += generate_tracer_between_points(p, beam_segments[p], tracer_type, color, 0, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity)
	else
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity)

	if(cleanup)
		QDEL_LIST(beam_segments)
		beam_segments = null
		QDEL_NULL(beam_index)

/obj/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/projectile/tracer/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null
	nodamage = TRUE
	damage = 0
	aoe_range = 0
	constant_tracer = TRUE
	hitscan_light_range = 0
	hitscan_light_intensity = 0
	hitscan_light_color_override = "#99ff99"
	reflectable = REFLECT_FAKEPROJECTILE

/obj/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit(atom/target)
	qdel(src)
	return FALSE

/obj/projectile/beam/beam_rifle/hitscan/aiming_beam/on_hit()
	qdel(src)
	return BULLET_ACT_HIT
