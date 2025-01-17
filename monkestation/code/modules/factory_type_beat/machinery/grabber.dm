/// Manipulator Core. Main part of the mechanism that carries out the entire process.
/obj/machinery/big_manipulator
	name = "Big Manipulator"
	desc = "Take and drop objects. Innovation..."
	icon = 'monkestation/code/modules/factory_type_beat/icons/big_manipulator_core.dmi'
	icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator
	/// How many time manipulator need to take and drop item.
	var/working_speed = 2 SECONDS
	/// Using high tier manipulators speeds up big manipulator and requires more energy.
	var/power_use_lvl = 0.2
	/// When manipulator already working with item inside he don't take any new items.
	var/on_work = FALSE
	/// Activate mechanism.
	var/on = FALSE
	/// Dir to get turf where we take items.
	var/take_here = NORTH
	/// Dir to get turf where we drop items.
	var/drop_here = SOUTH
	/// Turf where we take items.
	var/turf/take_turf
	/// Turf where we drop items.
	var/turf/drop_turf
	/// Obj inside manipulator.
	var/datum/weakref/containment_obj
	/// Other manipulator component.
	var/obj/effect/big_manipulator_hand/manipulator_hand
	///are we hacked?
	var/hacked = FALSE
	///our installed filter
	var/obj/item/manipulator_filter/filter
	///our failed attempts
	var/failed_attempts = 0
	var/atom/movable/failed_item

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	take_turf = get_step(src, take_here)
	drop_turf = get_step(src, drop_here)
	create_manipulator_hand()
	RegisterSignal(manipulator_hand, COMSIG_QDELETING, PROC_REF(on_hand_qdel))
	manipulator_lvl()

/obj/machinery/big_manipulator/Destroy(force)
	. = ..()
	failed_item = null
	if(filter)
		filter.forceMove(get_turf(src))
		filter = null
	qdel(manipulator_hand)
	if(isnull(containment_obj))
		return
	var/obj/obj_resolve = containment_obj?.resolve()
	if(isnull(obj_resolve))
		return
	obj_resolve.forceMove(get_turf(obj_resolve))


/obj/machinery/big_manipulator/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	take_and_drop_turfs_check()
	if(isnull(get_turf(src)))
		qdel(manipulator_hand)
		return
	if(!manipulator_hand)
		create_manipulator_hand()
	manipulator_hand.forceMove(get_turf(src))

/obj/machinery/big_manipulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return TRUE

/obj/machinery/big_manipulator/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(on_work || on)
		to_chat(user, span_warning("[src] is activated!"))
		return
	rotate_big_hand()
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return TRUE

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(on_work || on)
		to_chat(user, span_warning("[src] is activated!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/big_manipulator/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		take_and_drop_turfs_check()

/obj/machinery/big_manipulator/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return TRUE
	return TRUE

/obj/machinery/big_manipulator/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return TRUE
	return TRUE

/obj/machinery/big_manipulator/RefreshParts()
	. = ..()

	manipulator_lvl()

/// Creat manipulator hand effect on manipulator core.
/obj/machinery/big_manipulator/proc/create_manipulator_hand()
	manipulator_hand = new/obj/effect/big_manipulator_hand(get_turf(src))
	manipulator_hand.dir = take_here

/// Check servo tier and change manipulator speed, power_use and colour.
/obj/machinery/big_manipulator/proc/manipulator_lvl()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	if(!locate_servo)
		return
	switch(locate_servo.tier)
		if(1)
			working_speed = 2 SECONDS
			power_use_lvl = 0.02
			set_greyscale(COLOR_YELLOW)
			manipulator_hand?.set_greyscale(COLOR_YELLOW)
		if(2)
			working_speed = 1.4 SECONDS
			power_use_lvl = 0.04
			set_greyscale(COLOR_ORANGE)
			manipulator_hand?.set_greyscale(COLOR_ORANGE)
		if(3)
			working_speed = 0.8 SECONDS
			power_use_lvl = 0.06
			set_greyscale(COLOR_RED)
			manipulator_hand?.set_greyscale(COLOR_RED)
		if(4)
			working_speed = 0.2 SECONDS
			power_use_lvl = 0.08
			set_greyscale(COLOR_PURPLE)
			manipulator_hand?.set_greyscale(COLOR_PURPLE)

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * power_use_lvl

/// Changing take and drop turf tiles when we anchore manipulator or if manipulator not in turf.
/obj/machinery/big_manipulator/proc/take_and_drop_turfs_check()
	if(anchored && isturf(src.loc))
		take_turf = get_step(src, take_here)
		drop_turf = get_step(src, drop_here)
	else
		take_turf = null
		drop_turf = null

/// Changing take and drop turf dirs and also changing manipulator hand sprite dir.
/obj/machinery/big_manipulator/proc/rotate_big_hand()
	switch(take_here)
		if(NORTH)
			manipulator_hand.item_x = 64
			manipulator_hand.item_y = 32
			take_here = EAST
			drop_here = WEST
		if(EAST)
			manipulator_hand.item_x = 32
			manipulator_hand.item_y = 0
			take_here = SOUTH
			drop_here = NORTH
		if(SOUTH)
			manipulator_hand.item_x = 0
			manipulator_hand.item_y = 32
			take_here = WEST
			drop_here = EAST
		if(WEST)
			manipulator_hand.item_x = -32
			manipulator_hand.item_y = 0
			take_here = NORTH
			drop_here = SOUTH
	manipulator_hand.dir = take_here
	take_and_drop_turfs_check()

/// Deliting hand will destroy our manipulator core.
/obj/machinery/big_manipulator/proc/on_hand_qdel()
	SIGNAL_HANDLER

	deconstruct(TRUE)

/// Pre take and drop proc from [take and drop procs loop]:
/// Check if we have item on take_turf to start take and drop loop
/obj/machinery/big_manipulator/proc/is_work_check()
	if(filter)
		var/atom/movable = filter_return()
		if(movable)
			try_take_thing(take_turf, movable)
		return

	if(hacked)
		for(var/mob/living/take_item in take_turf.contents)
			try_take_thing(take_turf, take_item)
			break
	for(var/obj/take_item in take_turf.contents)
		if(take_item.anchored)
			continue
		try_take_thing(take_turf, take_item)
		break

/obj/machinery/big_manipulator/proc/filter_return()
	if(!filter)
		return null
	for(var/atom/movable/listed in take_turf.contents)
		if(filter.check_filter(listed))
			return listed

/// First take and drop proc from [take and drop procs loop]:
/// Check if we can take item from take_turf to work with him. This proc also calling from ATOM_ENTERED signal.
/obj/machinery/big_manipulator/proc/try_take_thing(datum/source, atom/movable/target)
	SIGNAL_HANDLER
	if(target == failed_item)
		failed_item = null
		return

	if(!on)
		return
	if(!anchored)
		return
	if(QDELETED(source) || QDELETED(target))
		return
	if(on_work)
		return
	if(!directly_use_power(active_power_usage))
		on = FALSE
		say("Not enough energy!")
		return
	failed_item = null

	if(filter)
		if(passes_filter(target))
			start_work(target)
		return

	if(isitem(target) || (isliving(target) && hacked) || (isobj(target) && !target.anchored))
		start_work(target)

/obj/machinery/big_manipulator/proc/passes_filter(atom/movable/target)
	if(!filter)
		return FALSE
	return filter.check_filter(target)

/// Second take and drop proc from [take and drop procs loop]:
/// Taking our item and start manipulator hand rotate animation.
/obj/machinery/big_manipulator/proc/start_work(atom/movable/target)
	target.forceMove(src)
	containment_obj = WEAKREF(target)
	manipulator_hand.picked = target
	manipulator_hand.update_appearance()
	on_work = TRUE
	do_rotate_animation(1)
	addtimer(CALLBACK(src, PROC_REF(drop_thing), target), working_speed)

/// Third take and drop proc from [take and drop procs loop]:
/// Drop our item and start manipulator hand backward animation.
/obj/machinery/big_manipulator/proc/drop_thing(atom/movable/target)
	if(!drop_turf.can_drop_off(target))
		failed_attempts++
		if(failed_attempts >= 10)
			do_rotate_animation(0)
			addtimer(CALLBACK(src, PROC_REF(end_work_failed), target), working_speed)
			return
		addtimer(CALLBACK(src, PROC_REF(drop_thing), target), working_speed)
		return
	failed_attempts = 0
	target.forceMove(drop_turf)
	manipulator_hand.picked = null
	manipulator_hand.update_appearance()
	do_rotate_animation(0)
	addtimer(CALLBACK(src, PROC_REF(end_work)), working_speed)

/// Fourth and last take and drop proc from take and drop procs loop:
/// Finishes work and begins to look for a new item for [take and drop procs loop].
/obj/machinery/big_manipulator/proc/end_work()
	on_work = FALSE
	is_work_check()

/obj/machinery/big_manipulator/proc/end_work_failed(atom/movable/target)
	target.forceMove(take_turf)
	failed_item = target
	manipulator_hand.picked = null
	manipulator_hand.update_appearance()
	on_work = FALSE
	failed_attempts = 0
	is_work_check()

/// Rotates manipulator hand 90 degrees.
/obj/machinery/big_manipulator/proc/do_rotate_animation(backward)
	animate(manipulator_hand, transform = matrix(90, MATRIX_ROTATE), working_speed*0.5)
	addtimer(CALLBACK(src, PROC_REF(finish_rotate_animation), backward), working_speed*0.5)

/// Rotates manipulator hand from 90 degrees to 180 or 0 if backward.
/obj/machinery/big_manipulator/proc/finish_rotate_animation(backward)
	animate(manipulator_hand, transform = matrix(180 * backward, MATRIX_ROTATE), working_speed*0.5)

/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
	if(!anchored)
		to_chat(user, span_warning("[src] isn't attached to the ground!"))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigManipulator")
		ui.open()

/obj/machinery/big_manipulator/AltClick(mob/user)
	. = ..()
	if(!filter)
		return
	filter.forceMove(get_turf(src))
	filter = null

/obj/machinery/big_manipulator/ui_data(mob/user)
	var/list/data = list()
	data["active"] = on
	return data

/obj/machinery/big_manipulator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("on")
			on = !on
			if(on)
				RegisterSignal(take_turf, COMSIG_ATOM_ENTERED, PROC_REF(try_take_thing))
			else
				UnregisterSignal(take_turf, COMSIG_ATOM_ENTERED)
			is_work_check()
			return TRUE

/// Manipulator hand. Effect we animate to show that the manipulator is working and moving something.
/obj/effect/big_manipulator_hand
	name = "Manipulator claw"
	desc = "Take and drop objects. Innovation..."
	icon = 'monkestation/code/modules/factory_type_beat/icons/big_manipulator_hand.dmi'
	icon_state = "hand"
	layer = LOW_ITEM_LAYER
	anchored = TRUE
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | TILE_BOUND | PIXEL_SCALE
	greyscale_config = /datum/greyscale_config/manipulator_hand
	pixel_x = -32
	pixel_y = -32

	///item offset x
	var/item_x = 32
	var/item_y = 64
	var/atom/movable/picked

/obj/effect/big_manipulator_hand/update_overlays()
	. = ..()
	if(picked)
		var/mutable_appearance/ma = mutable_appearance(picked.icon, picked.icon_state, picked.layer, src, appearance_flags = KEEP_TOGETHER)
		ma.color = picked.color
		ma.appearance = picked.appearance
		ma.appearance_flags = appearance_flags
		ma.plane = plane
		ma.pixel_x = item_x
		ma.pixel_y = item_y
		. += ma

/turf/proc/can_drop_off(atom/movable/target)
	if(isclosedturf(src))
		return FALSE
	for(var/obj/structure/listed in contents)
		if(!listed.can_drop_off(target))
			return FALSE
	for(var/obj/machinery/listed in contents)
		if(!listed.can_drop_off(target))
			return FALSE

	return TRUE

/obj/structure/proc/can_drop_off(atom/movable/target)
	return TRUE

/obj/machinery/proc/can_drop_off(atom/movable/target)
	return TRUE


/obj/item/manipulator_filter
	name = "manipulator filter"
	desc = "A filter specifically designed to work inside of a manipulator."

	icon = 'monkestation/code/modules/factory_type_beat/icons/items.dmi'
	icon_state = "filter"

	var/list/filtered_items = list()
	var/max_filtered_items = 5


/obj/item/manipulator_filter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/machinery/big_manipulator))
		try_attach(target)
		return

	if(target == src)
		return ..()
	if(!proximity_flag)
		return ..()
	if(!ismovable(target))
		return ..()
	if(istype(target, /obj/effect/decal/conveyor_sorter))
		return
	if(is_type_in_list(target, filtered_items))
		to_chat(user, span_warning("[target] is already in [src]'s sorting list!"))
		return
	if(length(filtered_items) >= max_filtered_items)
		to_chat(user, span_warning("[src] already has [max_filtered_items] things within the sorting list!"))
		return
	filtered_items += target.type
	to_chat(user, span_notice("[target] has been added to [src]'s sorting list."))

/obj/item/manipulator_filter/examine(mob/user)
	. = ..()
	. += span_notice("This sorter can sort up to <b>[max_filtered_items]</b> Items.")
	. += span_notice("Use Alt-Click to reset the sorting list.")
	. += span_notice("Attack things to attempt to add to the sorting list.")

/obj/item/manipulator_filter/AltClick(mob/user)
	visible_message("[src] pings, resetting its sorting list!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	filtered_items = list()

/obj/item/manipulator_filter/proc/try_attach(obj/machinery/big_manipulator/target)
	if(target.filter)
		return FALSE
	target.filter = src
	src.forceMove(target)
	return TRUE

/obj/item/manipulator_filter/proc/check_filter(atom/movable/target)
	if(target.type in filtered_items)
		return TRUE
	return FALSE


/obj/item/manipulator_filter/cargo
	name = "manipulator filter"
	desc = "A filter specifically designed to work inside of a manipulator."

/obj/item/manipulator_filter/cargo/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/machinery/big_manipulator))
		try_attach(target)
		return

/obj/item/manipulator_filter/attack_self(mob/user, modifiers)
	. = ..()
	var/choice = tgui_input_list(user, "Add a destination to check", name, GLOB.TAGGERLOCATIONS - filtered_items)
	if(!choice)
		return

	if(length(filtered_items) >= max_filtered_items)
		return

	filtered_items |= choice

/obj/item/manipulator_filter/cargo/check_filter(atom/movable/target)
	if(istype(target, /obj/item/delivery))
		var/obj/item/delivery/item = target
		var/name_tag = GLOB.TAGGERLOCATIONS[item.sort_tag]
		if(name_tag in filtered_items)
			return TRUE

	if(istype(target, /obj/item/mail))
		var/obj/item/mail/item = target
		var/name_tag = GLOB.TAGGERLOCATIONS[item.sort_tag]
		if(name_tag in filtered_items)
			return TRUE

	if(SEND_SIGNAL(target, COMSIG_FILTER_CHECK, filtered_items))
		return TRUE

	return FALSE


/obj/item/manipulator_filter/internal_filter
	name = "internal filter"
	desc = "Checks the contents inside of an object and if it matches any of the filters grabs the object"

/obj/item/manipulator_filter/internal_filter/check_filter(atom/movable/target)
	for(var/atom/movable/listed in target.contents)
		if(listed.type in filtered_items)
			return TRUE
	return FALSE


/proc/departmental_destination_to_tag(destination)
	switch(destination)
		if(/area/station/engineering/main)
			return "Engineering"
		if(/area/station/science/research)
			return "Research"
		if(/area/station/hallway/secondary/service)
			return  "Hydroponics"
		if(/area/station/service/bar/atrium)
			return "Bar"
		if(/area/station/security/office, /area/station/security/brig, /area/station/security/brig/upper)
			return "Security"
		if(/area/station/medical/medbay/central, /area/station/medical/medbay, /area/station/medical/treatment_center, /area/station/medical/storage)
			return "Medbay"
