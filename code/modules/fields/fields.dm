#define FIELD_TURFS_KEY "field_turfs"
#define EDGE_TURFS_KEY "edge_turfs"

//Movable and easily code-modified fields! Allows for custom AOE effects that affect movement and anything inside of them, and can do custom turf effects!
//Supports automatic recalculation/reset on movement.
//If there's any way to make this less CPU intensive than I've managed, gimme a call or do it yourself! - kevinz000

//Field shapes
#define FIELD_NO_SHAPE 0		//Does not update turfs automatically
#define FIELD_SHAPE_RADIUS_SQUARE 1	//Uses current_range and square_depth_up/down
#define FIELD_SHAPE_CUSTOM_SQUARE 2	//Uses square_height and square_width and square_depth_up/down

//Proc to make fields. make_field(field_type, field_params_in_associative_list)
/proc/make_field(field_type, list/field_params, override_checks = FALSE, start_field = TRUE)
	var/datum/proximity_monitor/advanced/F = new field_type()
	if(!F.assume_params(field_params) && !override_checks)
		QDEL_NULL(F)
	if(!F.check_variables() && !override_checks)
		QDEL_NULL(F)
	if(start_field && (F || override_checks))
		F.Initialize()
	return F

/datum/proximity_monitor/advanced
	var/name = "\improper Energy Field"
	//Field setup specifications
	var/field_shape = FIELD_NO_SHAPE
	var/square_height = 0
	var/square_width = 0
	var/square_depth_up = 0
	var/square_depth_down = 0
	//Processing
	var/process_inner_turfs = FALSE	//Don't do this unless it's absolutely necessary
	var/process_edge_turfs = FALSE	//Don't do this either unless it's absolutely necessary, you can just track what things are inside manually or on the initial setup.
	var/requires_processing = FALSE
	var/setup_edge_turfs = FALSE	//Setup edge turfs/all field turfs. Set either or both to ON when you need it, it's defaulting to off unless you do to save CPU.
	var/setup_field_turfs = FALSE
	var/use_host_turf = FALSE		//For fields from items carried on mobs to check turf instead of loc...
		/// If TRUE, edge turfs will be included as "in the field" for effects
	/// Can be used in certain situations where you may have effects that trigger only at the edge,
	/// while also wanting the field effect to trigger at edge turfs as well
	var/edge_is_a_field = FALSE

	var/list/turf/field_turfs = list()
	var/list/turf/edge_turfs = list()
	var/list/turf/field_turfs_new = list()
	var/list/turf/edge_turfs_new = list()

/datum/proximity_monitor/advanced/on_entered(turf/source, atom/movable/entered)
	. = ..()
	if(get_dist(source, host) == current_range)
		field_edge_crossed(entered, source)
	else
		field_turf_crossed(entered, source)

/datum/proximity_monitor/advanced/Destroy()
	full_cleanup()
	STOP_PROCESSING(SSfields, src)
	return ..()

/datum/proximity_monitor/advanced/proc/assume_params(list/field_params)
	var/pass_check = TRUE
	for(var/param in field_params)
		if(vars[param] || isnull(vars[param]) || (param in vars))
			vars[param] = field_params[param]
		else
			pass_check = FALSE
	return pass_check

/datum/proximity_monitor/advanced/proc/check_variables()
	var/pass = TRUE
	if(field_shape == FIELD_NO_SHAPE)	//If you're going to make a manually updated field you shouldn't be using automatic checks so don't.
		pass = FALSE
	if(current_range < 0 || square_height < 0 || square_width < 0 || square_depth_up < 0 || square_depth_down < 0)
		pass = FALSE
	if(!istype(host))
		pass = FALSE
	return pass

/datum/proximity_monitor/advanced/process()
	if(process_inner_turfs)
		for(var/turf/T in field_turfs)
			process_inner_turf(T)
			CHECK_TICK		//Really crappy lagchecks, needs improvement once someone starts using processed fields.
	if(process_edge_turfs)
		for(var/turf/T in edge_turfs)
			process_edge_turf(T)
			CHECK_TICK	//Same here.

/datum/proximity_monitor/advanced/proc/process_inner_turf(turf/T)

/datum/proximity_monitor/advanced/proc/process_edge_turf(turf/T)

/datum/proximity_monitor/advanced/New()
	if(requires_processing)
		START_PROCESSING(SSfields, src)

/datum/proximity_monitor/advanced/proc/Initialize()
	setup_field()
	post_setup_field()

/datum/proximity_monitor/advanced/proc/full_cleanup()	 //Full cleanup for when you change something that would require complete resetting.
	for(var/turf/T in edge_turfs)
		cleanup_edge_turf(T)
	for(var/turf/T in field_turfs)
		cleanup_field_turf(T)

/datum/proximity_monitor/advanced/proc/check_movement()
	if(!use_host_turf)
		if(host.loc != last_host_loc)
			last_host_loc = host.loc
			return TRUE
	else
		if(get_turf(host) != last_host_loc)
			last_host_loc = get_turf(host)
			return TRUE
	return FALSE

//Call every time the field moves (done automatically if you use update_center) or a setup specification is changed.
/datum/proximity_monitor/advanced/proc/recalculate_field()
	var/list/new_turfs = update_new_turfs()

	var/list/new_field_turfs = new_turfs[FIELD_TURFS_KEY]
	var/list/new_edge_turfs = new_turfs[EDGE_TURFS_KEY]

	for(var/turf/old_turf as anything in field_turfs)
		if(!(old_turf in new_field_turfs))
			cleanup_field_turf(old_turf)
	for(var/turf/old_turf as anything in edge_turfs)
		cleanup_edge_turf(old_turf)

	for(var/turf/new_turf as anything in new_field_turfs)
		field_turfs |= new_turf
		setup_field_turf(new_turf)
	for(var/turf/new_turf as anything in new_edge_turfs)
		edge_turfs |= new_turf
		setup_edge_turf(new_turf)


/datum/proximity_monitor/advanced/proc/field_turf_crossed(atom/movable/movable, turf/location)
	return

/datum/proximity_monitor/advanced/proc/field_turf_uncrossed(atom/movable/movable, turf/location)
	return

/datum/proximity_monitor/advanced/proc/field_edge_crossed(atom/movable/movable, turf/location)
	if(edge_is_a_field) // If the edge is considered a field, pass crossed to that
		field_turf_crossed(movable, location)

/datum/proximity_monitor/advanced/proc/field_edge_uncrossed(atom/movable/movable, turf/location)
	if(edge_is_a_field) // If the edge is considered a field, pass uncrossed to that
		field_turf_uncrossed(movable, location)

/datum/proximity_monitor/advanced/proc/field_turf_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F, turf/entering)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_turf_uncross(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F)
	return TRUE

	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F, turf/entering)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_uncross(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F)
	return TRUE

	return TRUE

/datum/proximity_monitor/advanced/HandleMove()
	var/atom/_host = host
	var/atom/new_host_loc = _host.loc
	if(last_host_loc != new_host_loc)
		recalculate_field()

/datum/proximity_monitor/advanced/proc/post_setup_field()

/datum/proximity_monitor/advanced/proc/setup_field()
	update_new_turfs()
	if(setup_field_turfs)
		for(var/turf/T in field_turfs_new)
			setup_field_turf(T)
			CHECK_TICK
	if(setup_edge_turfs)
		for(var/turf/T in edge_turfs_new)
			setup_edge_turf(T)
			CHECK_TICK

/datum/proximity_monitor/advanced/proc/cleanup_field_turf(turf/T)
	qdel(field_turfs[T])
	field_turfs -= T

/datum/proximity_monitor/advanced/proc/cleanup_edge_turf(turf/T)
	qdel(edge_turfs[T])
	edge_turfs -= T

/datum/proximity_monitor/advanced/proc/setup_field_turf(turf/T)
	field_turfs[T] = new /obj/effect/abstract/proximity_checker/advanced/field_turf(T, src)

/datum/proximity_monitor/advanced/proc/setup_edge_turf(turf/T)
	edge_turfs[T] = new /obj/effect/abstract/proximity_checker/advanced/field_edge(T, src)

/datum/proximity_monitor/advanced/proc/update_new_turfs()
	if(!istype(host))
		return FALSE
	var/turf/center = get_turf(host)
	field_turfs_new = list()
	edge_turfs_new = list()
	switch(field_shape)
		if(FIELD_NO_SHAPE)
			return FALSE
		if(FIELD_SHAPE_RADIUS_SQUARE)
			for(var/turf/T in block(locate(center.x-current_range,center.y-current_range,center.z-square_depth_down),locate(center.x+current_range, center.y+current_range,center.z+square_depth_up)))
				field_turfs_new += T
			edge_turfs_new = field_turfs_new.Copy()
			if(current_range >= 1)
				var/list/turf/center_turfs = list()
				for(var/turf/T in block(locate(center.x-current_range+1,center.y-current_range+1,center.z-square_depth_down),locate(center.x+current_range-1, center.y+current_range-1,center.z+square_depth_up)))
					center_turfs += T
				for(var/turf/T in center_turfs)
					edge_turfs_new -= T
		if(FIELD_SHAPE_CUSTOM_SQUARE)
			for(var/turf/T in block(locate(center.x-square_width,center.y-square_height,center.z-square_depth_down),locate(center.x+square_width, center.y+square_height,center.z+square_depth_up)))
				field_turfs_new += T
			edge_turfs_new = field_turfs_new.Copy()
			if(square_height >= 1 && square_width >= 1)
				var/list/turf/center_turfs = list()
				for(var/turf/T in block(locate(center.x-square_width+1,center.y-square_height+1,center.z-square_depth_down),locate(center.x+square_width-1, center.y+square_height-1,center.z+square_depth_up)))
					center_turfs += T
				for(var/turf/T in center_turfs)
					edge_turfs_new -= T

//Gets edge direction/corner, only works with square radius/WDH fields!
/datum/proximity_monitor/advanced/proc/get_edgeturf_direction(turf/T, turf/center_override = null)
	var/turf/checking_from = get_turf(host)
	if(istype(center_override))
		checking_from = center_override
	if(field_shape != FIELD_SHAPE_RADIUS_SQUARE && field_shape != FIELD_SHAPE_CUSTOM_SQUARE)
		return
	if(!(T in edge_turfs))
		return
	switch(field_shape)
		if(FIELD_SHAPE_RADIUS_SQUARE)
			if(((T.x == (checking_from.x + current_range)) || (T.x == (checking_from.x - current_range))) && ((T.y == (checking_from.y + current_range)) || (T.y == (checking_from.y - current_range))))
				return get_dir(checking_from, T)
			if(T.x == (checking_from.x + current_range))
				return EAST
			if(T.x == (checking_from.x - current_range))
				return WEST
			if(T.y == (checking_from.y - current_range))
				return SOUTH
			if(T.y == (checking_from.y + current_range))
				return NORTH
		if(FIELD_SHAPE_CUSTOM_SQUARE)
			if(((T.x == (checking_from.x + square_width)) || (T.x == (checking_from.x - square_width))) && ((T.y == (checking_from.y + square_height)) || (T.y == (checking_from.y - square_height))))
				return get_dir(checking_from, T)
			if(T.x == (checking_from.x + square_width))
				return EAST
			if(T.x == (checking_from.x - square_width))
				return WEST
			if(T.y == (checking_from.y - square_height))
				return SOUTH
			if(T.y == (checking_from.y + square_height))
				return NORTH

//DEBUG FIELDS
/datum/proximity_monitor/advanced/debug
	name = "\improper Color Matrix Field"
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	current_range = 5
	var/set_fieldturf_color = "#aaffff"
	var/set_edgeturf_color = "#ffaaff"
	setup_field_turfs = TRUE
	setup_edge_turfs = TRUE


/datum/proximity_monitor/advanced/debug/setup_edge_turf(turf/T)
	T.color = set_edgeturf_color
	..()

/datum/proximity_monitor/advanced/debug/cleanup_edge_turf(turf/T)
	T.color = initial(T.color)
	..()
	if(T in field_turfs)
		T.color = set_fieldturf_color

/datum/proximity_monitor/advanced/debug/setup_field_turf(turf/T)
	T.color = set_fieldturf_color
	..()

/datum/proximity_monitor/advanced/debug/cleanup_field_turf(turf/T)
	T.color = initial(T.color)
	..()

//DEBUG FIELD ITEM
/obj/item/multitool/field_debug
	name = "strange multitool"
	desc = "Seems to project a colored field!"
	var/list/field_params = list("field_shape" = FIELD_SHAPE_RADIUS_SQUARE, "current_range" = 5, "set_fieldturf_color" = "#aaffff", "set_edgeturf_color" = "#ffaaff")
	var/field_type = /datum/proximity_monitor/advanced/debug
	var/operating = FALSE
	var/datum/proximity_monitor/advanced/current = null
	var/mob/listeningTo

/obj/item/multitool/field_debug/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/multitool/field_debug/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(current)
	listeningTo = null
	return ..()

/obj/item/multitool/field_debug/proc/setup_debug_field()
	var/list/new_params = field_params.Copy()
	new_params["host"] = src
	current = make_field(field_type, new_params)

/obj/item/multitool/field_debug/attack_self(mob/user)
	operating = !operating
	to_chat(user, "You turn [src] [operating? "on":"off"].")
	UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	listeningTo = null
	if(!istype(current) && operating)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
		listeningTo = user
		setup_debug_field()
	else if(!operating)
		QDEL_NULL(current)

/obj/item/multitool/field_debug/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/multitool/field_debug/proc/on_mob_move()
	check_turf(get_turf(src))

/obj/item/multitool/field_debug/process()
	check_turf(get_turf(src))

/obj/item/multitool/field_debug/proc/check_turf(turf/T)
	current.HandleMove()

#undef FIELD_TURFS_KEY
#undef EDGE_TURFS_KEY
