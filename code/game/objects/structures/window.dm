/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1 | RAD_PROTECT_CONTENTS_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY
	max_integrity = 25
	can_be_unanchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = -50, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100)
	can_atmos_pass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	var/ini_dir = null
	var/state = WINDOW_SCREWED_TO_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = 30
	var/wtype = "glass"
	var/fulltile = FALSE
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/real_explosion_block	//ignore this, just use explosion_block
	var/break_sound = SFX_SHATTER
	var/knock_sound = 'sound/effects/glassknock.ogg'
	var/bash_sound = 'sound/effects/glassbash.ogg'
	var/hit_sound = 'sound/effects/glasshit.ogg'	
	/// If some inconsiderate jerk has had their blood spilled on this window, thus making it cleanable
	var/bloodied = FALSE

/obj/structure/window/examine(mob/user)
	. = ..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += span_notice("The window is <b>screwed</b> to the frame.")
		else if(anchored && state == WINDOW_IN_FRAME)
			. += span_notice("The window is <i>unscrewed</i> but <b>pried</b> into the frame.")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += span_notice("The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.")
		else if(!anchored)
			. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")
	else
		if(anchored)
			. += span_notice("The window is <b>screwed</b> to the floor.")
		else
			. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = RWINDOW_SECURE

	ini_dir = dir
	air_update_turf()

	if(fulltile)
		setDir()
		obj_flags &= ~BLOCKS_CONSTRUCTION_DIR
		obj_flags &= ~IGNORE_DENSITY

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, PROC_REF(can_be_rotated)), CALLBACK(src, PROC_REF(after_rotation)))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	if (flags_1 & ON_BORDER_1)
		AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.construction_mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/obj/structure/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	if (resistance_flags & INDESTRUCTIBLE)
		return FALSE

	switch(the_rcd.construction_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the window."))
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
	qdel(src)

/obj/structure/window/honk_act()
	if(fulltile)
		new/obj/structure/window/bananium/fulltile(get_turf(src))
	else
		return
	qdel(src)

/obj/structure/window/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/setDir(direct)
	if(!fulltile)
		..()
	else
		..(FULLTILE_WINDOW_DIR)

/obj/structure/window/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE
	if(dir == FULLTILE_WINDOW_DIR)
		return FALSE	//full tile window, you can't move into it!
	var/attempted_dir = get_dir(loc, target)
	if(attempted_dir == dir)
		return
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	else if(attempted_dir != dir)
		return TRUE

/obj/structure/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if (leaving.pass_flags & PASSGLASS)
		return

	if (fulltile)
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("Something knocks on [src]."))
	add_fingerprint(user)
	playsound(src, knock_sound, 50, TRUE)

/obj/structure/window/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return 1
	. = ..()

/obj/structure/window/attack_hand(mob/living/user, modifiers)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	
	if(!user.combat_mode)
		user.visible_message(span_notice("[user] knocks on [src]."), \
			span_notice("You knock on [src]."))
		playsound(src, knock_sound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] bashes [src]!"), \
			span_warning("You bash [src]!"))
		playsound(src, bash_sound, 100, TRUE)

/obj/structure/window/attack_paw(mob/user, modifiers)
	return attack_hand(user, modifiers)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	return ..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1 //skip the afterattack

	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume=50))
				update_integrity(max_integrity)
				update_nearby_icons()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

	if(!(flags_1&NODECONSTRUCT_1) && !(reinf && state >= RWINDOW_FRAME_BOLTED))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			I.play_tool_sound(src, 75)
			to_chat(user, span_notice("You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor..."))
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
				setAnchored(!anchored)
				to_chat(user, span_notice("You [anchored ? "fasten the window to":"unfasten the window from"] the floor."))
			return

		else if(I.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME))
			to_chat(user, span_notice("You begin to lever the window into the frame..."))
			I.play_tool_sound(src, 75)
			if(I.use_tool(src, user, 100, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = RWINDOW_SECURE
				to_chat(user, span_notice("You pry the window into the frame."))
			return

		else if(I.tool_behaviour == TOOL_WRENCH && !anchored)
			I.play_tool_sound(src, 75)
			to_chat(user, span_notice(" You begin to disassemble [src]..."))
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, span_notice("You successfully disassemble [src]."))
				qdel(src)
			return
	return ..()

/obj/structure/window/setAnchored(anchorvalue)
	..()
	air_update_turf()
	update_nearby_icons()

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/mech_melee_attack(obj/mecha/M, punch_force, equip_allowed = TRUE)
	if(!can_be_reached())
		return
	return ..()

/obj/structure/window/proc/can_be_reached(mob/user)
	if(!fulltile)
		if(get_dir(user,src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1))
					return 0
	return 1

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hit_sound, 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)


/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, break_sound, 70, 1)
		if(!(flags_1 & NODECONSTRUCT_1))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()))
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	. += new /obj/item/shard(location)
	. += new /obj/effect/decal/cleanable/glass(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard(location)

/obj/structure/window/proc/can_be_rotated(mob/user, rotation_type)
	var/silent = FALSE
	if(!Adjacent(user))
		silent = TRUE

	if(anchored)
		if (!silent)
			to_chat(user, span_warning("[src] cannot be rotated while it is fastened to the floor!"))
		return FALSE

	var/target_dir = turn(dir, rotation_type == ROTATION_CLOCKWISE ? -90 : 90)

	if(!valid_window_location(loc, target_dir))
		if (!silent)
			to_chat(user, span_warning("[src] cannot be rotated in that direction!"))
		return FALSE

	return TRUE

/obj/structure/window/proc/after_rotation(mob/user,rotation_type)
	air_update_turf()
	ini_dir = dir
	add_fingerprint(user)

/obj/structure/window/Destroy()
	density = FALSE
	air_update_turf()
	update_nearby_icons()
	return ..()

/obj/structure/window/Move()
	var/turf/T = loc
	. = ..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/window/can_atmos_pass(turf/target_turf, vertical = FALSE)
	if(!anchored || !density)
		return TRUE
	return !(fulltile || dir == get_dir(loc, target_turf) || FULLTILE_WINDOW_DIR == dir)

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_overlays(updates=ALL)
	. = ..()
	if(QDELETED(src) || !fulltile)
		return

	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)

	var/ratio = atom_integrity / max_integrity
	ratio = CEILING(ratio*4, 1) * 25
	if(ratio > 75)
		return
	. += mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer+0.1))

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	if(exposed_temperature > (T0C + heat_resistance))
		take_damage(round(exposed_volume / 100), BURN, 0, 0)
	..()

/obj/structure/window/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/structure/window/CanAStarPass(ID, to_dir)
	if(!density)
		return 1
	if((dir == FULLTILE_WINDOW_DIR) || (dir == to_dir))
		return 0

	return 1

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/spawner/east
	dir = EAST

/obj/structure/window/spawner/west
	dir = WEST

/obj/structure/window/spawner/north
	dir = NORTH

/obj/structure/window/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with metal rods."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 60, BULLET = -50, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	max_integrity = 75
	explosion_block = 1
	damage_deflection = 11
	state = RWINDOW_SECURE
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_HEAVY_INSULATION

/obj/structure/window/reinforced/bronze
	name = "bronze window"
	desc = "A paper-thin pane of translucent yet reinforced bronze."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	glass_type = /obj/item/stack/tile/bronze

//this is shitcode but all of construction is shitcode and needs a refactor, it works for now
//If you find this like 4 years later and construction still hasn't been refactored, I'm so sorry for this

//Found this 4 years later, still hasn't been refactored -S
/obj/structure/window/reinforced/attackby(obj/item/I, mob/living/user, params)
	var/list/modifiers = params2list(params)
	switch(state)
		if(RWINDOW_SECURE)
			if(I.tool_behaviour == TOOL_WELDER && modifiers && modifiers[RIGHT_CLICK])
				user.visible_message(span_notice("[user] holds \the [I] to the security screws on \the [src]..."),
										span_notice("You begin heating the security screws on \the [src]..."))
				if(I.use_tool(src, user, 8 SECONDS, volume = 100))
					to_chat(user, span_notice("The security bolts are glowing white hot and look ready to be removed."))
					state = RWINDOW_BOLTS_HEATED
					addtimer(CALLBACK(src, PROC_REF(cool_bolts)), 300)
				return
		if(RWINDOW_BOLTS_HEATED)
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] digs into the heated security screws and starts removing them..."),
										span_notice("You dig into the heated screws hard and they start turning..."))
				if(I.use_tool(src, user, 4 SECONDS, volume = 50))
					state = RWINDOW_BOLTS_OUT
					to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the pane."))
				return
		if(RWINDOW_BOLTS_OUT)
			if(I.tool_behaviour == TOOL_CROWBAR)
				user.visible_message(span_notice("[user] wedges \the [I] into the gap in the frame and starts prying..."),
										span_notice("You wedge \the [I] into the gap in the frame and start prying..."))
				if(I.use_tool(src, user, 5 SECONDS, volume = 50))
					state = RWINDOW_POPPED
					to_chat(user, span_notice("The panel pops out of the frame, exposing some thin metal bars that looks like they can be cut."))
				return
		if(RWINDOW_POPPED)
			if(I.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(span_notice("[user] starts cutting the exposed bars on \the [src]..."),
										span_notice("You start cutting the exposed bars on \the [src]"))
				if(I.use_tool(src, user, 3 SECONDS, volume = 50))
					state = RWINDOW_BARS_CUT
					to_chat(user, span_notice("The panels falls out of the way exposing the frame bolts."))
				return
		if(RWINDOW_BARS_CUT)
			if(I.tool_behaviour == TOOL_WRENCH)
				user.visible_message(span_notice("[user] starts unfastening \the [src] from the frame..."),
					span_notice("You start unfastening the bolts from the frame..."))
				if(I.use_tool(src, user, 5 SECONDS, volume = 50))
					to_chat(user, span_notice("You unscrew the bolts from the frame and the window pops loose."))
					state = WINDOW_OUT_OF_FRAME
					setAnchored(FALSE)
				return
	return ..()

/obj/structure/window/proc/cool_bolts()
	if(state == RWINDOW_BOLTS_HEATED)
		state = RWINDOW_SECURE
		visible_message(span_notice("The bolts on \the [src] look like they've cooled off..."))

/obj/structure/window/reinforced/examine(mob/user)
	. = ..()
	switch(state)
		if(RWINDOW_SECURE)
			. += "It's been screwed in with one way screws, you'd need to <b>heat them</b> to have any chance of backing them out."
		if(RWINDOW_BOLTS_HEATED)
			. += "The screws are glowing white hot, and you'll likely be able to <b>unscrew them</b> now."
		if(RWINDOW_BOLTS_OUT)
			. += "The screws have been removed, revealing a small gap you could fit a <b>prying tool</b> in."
		if(RWINDOW_POPPED)
			. += "The main plate of the window has popped out of the frame, exposing some bars that look like they can be <b>cut</b>."
		if(RWINDOW_BARS_CUT)
			. += "The main pane can be easily moved out of the way to reveal some <b>bolts</b> holding the frame in."


/obj/structure/window/reinforced/spawner/east
	dir = EAST

/obj/structure/window/reinforced/spawner/west
	dir = WEST

/obj/structure/window/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/reinforced/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	reinf = FALSE
	heat_resistance = 25000
	armor = list(MELEE = 60, BULLET = -45, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, ELECTRIC = 100)
	max_integrity = 150
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/plasmaglass
	rad_insulation = RAD_FULL_INSULATION

/obj/structure/window/plasma/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /obj/projectile/energy/nuclear_particle))
		return FALSE

/obj/structure/window/plasma/spawnDebris(location)
	. = list()
	. += new /obj/item/shard/plasma(location)
	. += new /obj/effect/decal/cleanable/glass/plasma(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard/plasma(location)

/obj/structure/window/plasma/BlockThermalConductivity(opp_dir)
	if(!anchored || !density)
		return FALSE
	return FULLTILE_WINDOW_DIR == dir || dir == opp_dir

/obj/structure/window/plasma/spawner/east
	dir = EAST

/obj/structure/window/plasma/spawner/west
	dir = WEST

/obj/structure/window/plasma/spawner/north
	dir = NORTH

/obj/structure/window/plasma/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plasma/reinforced
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor = list(MELEE = 80, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, ELECTRIC = 100)
	max_integrity = 500
	damage_deflection = 21
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass

//entirely copypasted code
//take this out when construction is made a component or otherwise modularized in some way
/obj/structure/window/plasma/reinforced/attackby(obj/item/I, mob/living/user, params)
	var/list/modifiers = params2list(params)
	switch(state)
		if(RWINDOW_SECURE)
			if(I.tool_behaviour == TOOL_WELDER && modifiers && modifiers[RIGHT_CLICK])
				user.visible_message(span_notice("[user] holds \the [I] to the security screws on \the [src]..."),
										span_notice("You begin heating the security screws on \the [src]..."))
				if(I.use_tool(src, user, 180, volume = 100))
					to_chat(user, span_notice("The security screws are glowing white hot and look ready to be removed."))
					state = RWINDOW_BOLTS_HEATED
					addtimer(CALLBACK(src, PROC_REF(cool_bolts)), 300)
				return
		if(RWINDOW_BOLTS_HEATED)
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] digs into the heated security screws and starts removing them..."),
										span_notice("You dig into the heated screws hard and they start turning..."))
				if(I.use_tool(src, user, 80, volume = 50))
					state = RWINDOW_BOLTS_OUT
					to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the pane."))
				return
		if(RWINDOW_BOLTS_OUT)
			if(I.tool_behaviour == TOOL_CROWBAR)
				user.visible_message(span_notice("[user] wedges \the [I] into the gap in the frame and starts prying..."),
										span_notice("You wedge \the [I] into the gap in the frame and start prying..."))
				if(I.use_tool(src, user, 50, volume = 50))
					state = RWINDOW_POPPED
					to_chat(user, span_notice("The panel pops out of the frame, exposing some thin metal bars that looks like they can be cut."))
				return
		if(RWINDOW_POPPED)
			if(I.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(span_notice("[user] starts cutting the exposed bars on \the [src]..."),
										span_notice("You start cutting the exposed bars on \the [src]"))
				if(I.use_tool(src, user, 30, volume = 50))
					state = RWINDOW_BARS_CUT
					to_chat(user, span_notice("The panels falls out of the way exposing the frame bolts."))
				return
		if(RWINDOW_BARS_CUT)
			if(I.tool_behaviour == TOOL_WRENCH)
				user.visible_message(span_notice("[user] starts unfastening \the [src] from the frame..."),
					span_notice("You start unfastening the bolts from the frame..."))
				if(I.use_tool(src, user, 50, volume = 50))
					to_chat(user, span_notice("You unfasten the bolts from the frame and the window pops loose."))
					state = WINDOW_OUT_OF_FRAME
					setAnchored(FALSE)
				return
	return ..()

/obj/structure/window/plasma/reinforced/examine(mob/user)
	. = ..()
	switch(state)
		if(RWINDOW_SECURE)
			. += "It's been screwed in with one way screws, you'd need to <b>heat them</b> to have any chance of backing them out."
		if(RWINDOW_BOLTS_HEATED)
			. += "The screws are glowing white hot, and you'll likely be able to <b>unscrew them</b> now."
		if(RWINDOW_BOLTS_OUT)
			. += "The screws have been removed, revealing a small gap you could fit a <b>prying tool</b> in."
		if(RWINDOW_POPPED)
			. += "The main plate of the window has popped out of the frame, exposing some bars that look like they can be <b>cut</b>."
		if(RWINDOW_BARS_CUT)
			. += "The main pane can be easily moved out of the way to reveal some <b>bolts</b> holding the frame in."

/obj/structure/window/plasma/reinforced/spawner/east
	dir = EAST

/obj/structure/window/plasma/reinforced/spawner/west
	dir = WEST

/obj/structure/window/plasma/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/plasma/reinforced/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = TRUE

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"

/* Full Tile Windows (more atom_integrity) */

/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/window.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 50
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plasma/fulltile
	icon = 'icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "plasma_window"
	base_icon_state = "plasma_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 300
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/plasma/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plasma/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
	icon_state = "rplasma_window-0"
	base_icon_state = "rplasma_window"
	dir = FULLTILE_WINDOW_DIR
	state = RWINDOW_SECURE
	max_integrity = 1000
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/plasma/reinforced/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 150
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	state = RWINDOW_SECURE
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window-0"
	base_icon_state = "tinted_window"
	dir = FULLTILE_WINDOW_DIR
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "rice_window-0"
	base_icon_state = "rice_window"
	max_integrity = 150
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/bronze
	name = "bronze window"
	desc = "A pane of translucent yet reinforced bronze."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	glass_type = /obj/item/stack/tile/bronze

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 100
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2

/obj/structure/window/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/shuttle/tinted
	opacity = TRUE

/obj/structure/window/shuttle/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of of plasma and titanium."
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 1200
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 40, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, ELECTRIC = 100)
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	explosion_block = 3
	damage_deflection = 21 //The same as reinforced plasma windows.
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2
	rad_insulation = RAD_FULL_INSULATION

/obj/structure/window/plastitanium/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /obj/projectile/energy/nuclear_particle))
		return FALSE

/obj/structure/window/plastitanium/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 150
	armor = list(MELEE = 80, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	explosion_block = 2 //fancy AND hard to destroy. the most useful combination.
	decon_speed = 40
	glass_type = /obj/item/stack/tile/brass
	glass_amount = 1
	reinf = FALSE
	var/made_glow = FALSE

/obj/structure/window/reinforced/clockwork/Initialize(mapload, direct)
	. = ..()
	change_construction_value(fulltile ? 2 : 1)

/obj/structure/window/reinforced/clockwork/spawnDebris(location)
	. = list()
	var/gearcount = fulltile ? 4 : 2
	for(var/i in 1 to gearcount)
		. += new /obj/item/clockwork/alloy_shards/medium/gear_bit(location)

/obj/structure/window/reinforced/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/window/single(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/structure/window/reinforced/clockwork/Destroy()
	change_construction_value(fulltile ? -2 : -1)
	return ..()

/obj/structure/window/reinforced/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		update_integrity(max_integrity)
		update_appearance()

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(!QDELETED(src))
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 0.8 SECONDS)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 0.8 SECONDS)

/obj/structure/window/reinforced/clockwork/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE + SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 600
	glass_amount = 2

/obj/structure/window/reinforced/clockwork/spawnDebris(location)
	. = list()
	for(var/i in 1 to 4)
		. += new /obj/item/clockwork/alloy_shards/medium/gear_bit(location)

/obj/structure/window/reinforced/clockwork/Initialize(mapload, direct)
	made_glow = TRUE
	new /obj/effect/temp_visual/ratvar/window(get_turf(src))
	return ..()


/obj/structure/window/reinforced/clockwork/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/paperframe
	name = "paper frame"
	desc = "A fragile separator made of thin wood and paper."
	icon = 'icons/obj/smooth_structures/paperframes.dmi'
	icon_state = "paperframes-0"
	base_icon_state = "paperframes"
	dir = FULLTILE_WINDOW_DIR
	opacity = TRUE
	max_integrity = 15
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PAPERFRAME
	canSmoothWith = SMOOTH_GROUP_PAPERFRAME
	glass_amount = 2
	glass_type = /obj/item/stack/sheet/paperframes
	heat_resistance = 233
	decon_speed = 10
	can_atmos_pass = ATMOS_PASS_YES
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	knock_sound = SFX_PAGE_TURN
	bash_sound = 'sound/weapons/slashmiss.ogg'
	break_sound = 'sound/items/poster_ripped.ogg'
	hit_sound = 'sound/weapons/slashmiss.ogg'
	var/static/mutable_appearance/torn = mutable_appearance('icons/obj/smooth_structures/structure_variations.dmi',icon_state = "paper-torn", layer = ABOVE_OBJ_LAYER - 0.1)
	var/static/mutable_appearance/paper = mutable_appearance('icons/obj/smooth_structures/structure_variations.dmi',icon_state = "paper-whole", layer = ABOVE_OBJ_LAYER - 0.1)

/obj/structure/window/paperframe/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/window/paperframe/examine(mob/user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_info("It looks a bit damaged, you may be able to fix it with some <b>paper</b>.")

/obj/structure/window/paperframe/spawnDebris(location)
	. = list(new /obj/item/stack/sheet/mineral/wood(location))
	for (var/i in 1 to rand(1,4))
		. += new /obj/item/paper/natural(location)

/obj/structure/window/paperframe/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(user.combat_mode)
		take_damage(4,BRUTE,MELEE, 0)
		if(!QDELETED(src))
			user.visible_message(span_danger("[user] tears a hole in [src]."))
			update_appearance()

/obj/structure/window/paperframe/update_appearance(updates)
	. = ..()
	set_opacity(atom_integrity >= max_integrity)

/obj/structure/window/paperframe/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)

/obj/structure/window/paperframe/update_overlays()
	. = ..()
	. += (atom_integrity < max_integrity) ? torn : paper

/obj/structure/window/paperframe/attackby(obj/item/W, mob/living/user)
	if(W.is_hot())
		fire_act(W.is_hot())
		return
	if(user.combat_mode)
		return ..()
	if(istype(W, /obj/item/paper) && atom_integrity < max_integrity)
		user.visible_message("[user] starts to patch the holes in \the [src].")
		if(do_after(user, 2 SECONDS, src))
			update_integrity(min(atom_integrity + 4, max_integrity))
			qdel(W)
			user.visible_message("[user] patches some of the holes in \the [src].")
			if(atom_integrity == max_integrity)
				update_appearance()
			return
	..()
	update_appearance()

/obj/structure/cloth_curtain
	name = "curtain"
	desc = "Beta brand soft sheets"
	icon = 'icons/obj/structures.dmi'
	icon_state = "curtain_open"
	color = "#af439d" //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	var/open = TRUE

/obj/structure/cloth_curtain/proc/toggle()
	open = !open
	update_appearance(UPDATE_ICON)

/obj/structure/cloth_curtain/update_icon(updates=ALL)
	. = ..()
	if(!open)
		icon_state = "curtain_closed"
		layer = WALL_OBJ_LAYER
		density = TRUE
		open = FALSE
		opacity = TRUE
	else
		icon_state = "curtain_open"
		layer = SIGN_LAYER
		density = FALSE
		open = TRUE
		opacity = FALSE

/obj/structure/cloth_curtain/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/toy/crayon))
		color = input(user,"","Choose Color",color) as color
		return TRUE
	else
		return ..()

/obj/structure/cloth_curtain/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 50)
	return TRUE

/obj/structure/cloth_curtain/wirecutter_act(mob/living/user, obj/item/I)
	if(anchored)
		return TRUE

	user.visible_message(span_warning("[user] starts cuttting apart [src]."),
		span_notice("You start to cut apart [src]."), "You hear cutting.")
	if(I.use_tool(src, user, 50, volume=100) && !anchored)
		to_chat(user, span_notice("You cut apart [src]."))
		deconstruct()

	return TRUE


/obj/structure/cloth_curtain/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	playsound(loc, 'sound/effects/curtain.ogg', 50, 1)
	toggle()

/obj/structure/cloth_curtain/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	new /obj/item/stack/sheet/cloth(loc, 2)
	new /obj/item/stack/rods(loc, 1)
	qdel(src)

/obj/structure/cloth_curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_amount)
		switch(damage_type)
			if(BRUTE)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
			if(BURN)
				playsound(loc, 'sound/items/welder.ogg', 80, 1)
	else
		playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
