// This is like paradise spacepods but with a few differences:
// - no spacepod fabricator, parts are made in techfabs and frames are made using metal rods.
// - not tile based, instead has velocity and acceleration. why? so I can put all this math to use.
// - damages shit if you run into it too fast instead of just stopping. You have to have a huge running start to do that though and damages the spacepod as well.
// - doesn't explode

GLOBAL_LIST_INIT(spacepods_list, list())

/obj/spacepod
	name = "space pod"
	desc = "A frame for a spacepod."
	icon = 'goon/icons/obj/spacepods/construction_2x2.dmi'
	icon_state = "pod_1"
	density = 1
	opacity = 0
	dir = NORTH // always points north because why not
	layer = SPACEPOD_LAYER
	bound_width = 64
	bound_height = 64
	animate_movement = NO_STEPS // we do our own gliding here

	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // it floats above lava or something, I dunno

	max_integrity = 50
	integrity_failure = 50

	var/list/equipment = list()
	var/list/equipment_slot_limits = list(
		SPACEPOD_SLOT_MISC = 1,
		SPACEPOD_SLOT_CARGO = 2,
		SPACEPOD_SLOT_WEAPON = 1,
		SPACEPOD_SLOT_LOCK = 1)
	var/obj/item/spacepod_equipment/lock/lock
	var/obj/item/spacepod_equipment/weaponry/weapon
	var/next_firetime = 0
	var/locked = FALSE
	var/hatch_open = FALSE
	var/construction_state = SPACEPOD_EMPTY
	var/obj/item/pod_parts/armor/pod_armor = null
	var/obj/item/stock_parts/cell/cell = null
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/last_slowprocess = 0

	var/mob/living/pilot
	var/list/passengers = list()
	var/max_passengers = 0

	var/velocity_x = 0 // tiles per second.
	var/velocity_y = 0
	var/offset_x = 0 // like pixel_x/y but in tiles
	var/offset_y = 0
	var/angle = 0 // degrees, clockwise
	var/desired_angle = null // set by pilot moving his mouse
	var/angular_velocity = 0 // degrees per second
	var/max_angular_acceleration = 360 // in degrees per second per second
	var/last_thrust_forward = 0
	var/last_thrust_right = 0
	var/last_rotate = 0

	var/brakes = TRUE
	var/user_thrust_dir = 0
	var/forward_maxthrust = 6
	var/backward_maxthrust = 3
	var/side_maxthrust = 1

	var/lights = 0
	var/lights_power = 6
	var/static/list/icon_light_color = list("pod_civ" = LIGHT_COLOR_WHITE, \
									 "pod_mil" = "#BBF093", \
									 "pod_synd" = LIGHT_COLOR_RED, \
									 "pod_gold" = LIGHT_COLOR_WHITE, \
									 "pod_black" = "#3B8FE5", \
									 "pod_industrial" = "#CCCC00")

	var/bump_impulse = 0.6
	var/bounce_factor = 0.2 // how much of our velocity to keep on collision
	var/lateral_bounce_factor = 0.95 // mostly there to slow you down when you drive (pilot?) down a 2x2 corridor

/obj/spacepod/Initialize()
	. = ..()
	GLOB.spacepods_list += src
	START_PROCESSING(SSfastprocess, src)
	cabin_air = new
	cabin_air.set_temperature(T20C)
	cabin_air.set_volume(200)
	/*cabin_air.assert_gas(/datum/gas/oxygen)
	cabin_air.assert_gas(/datum/gas/nitrogen)
	cabin_air.gases[/datum/gas/oxygen][MOLES] = ONE_ATMOSPHERE*O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gases[/datum/gas/nitrogen][MOLES] = ONE_ATMOSPHERE*N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)*/

/obj/spacepod/Destroy()
	GLOB.spacepods_list -= src
	QDEL_NULL(pilot)
	QDEL_LIST(passengers)
	QDEL_LIST(equipment)
	QDEL_NULL(cabin_air)
	QDEL_NULL(cell)
	return ..()

/obj/spacepod/attackby(obj/item/W, mob/living/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	else if(construction_state != SPACEPOD_ARMOR_WELDED)
		. = handle_spacepod_construction(W, user)
		if(.)
			return
		else
			return ..()
	// and now for the real stuff
	else
		if(W.tool_behaviour == TOOL_CROWBAR)
			if(hatch_open || !locked)
				hatch_open = !hatch_open
				W.play_tool_sound(src)
				to_chat(user, span_notice("You [hatch_open ? "open" : "close"] the maintenance hatch."))
			else
				to_chat(user, span_warning("The hatch is locked shut!"))
			return TRUE
		if(istype(W, /obj/item/stock_parts/cell))
			if(!hatch_open)
				to_chat(user, span_warning("The maintenance hatch is closed!"))
				return TRUE
			if(cell)
				to_chat(user, span_notice("The pod already has a battery."))
				return TRUE
			if(user.transferItemToLoc(W, src))
				to_chat(user, span_notice("You insert [W] into the pod."))
				cell = W
			return TRUE
		if(istype(W, /obj/item/spacepod_equipment))
			if(!hatch_open)
				to_chat(user, span_warning("The maintenance hatch is closed!"))
				return TRUE
			var/obj/item/spacepod_equipment/SE = W
			if(SE.can_install(src, user) && user.temporarilyRemoveItemFromInventory(SE))
				SE.forceMove(src)
				SE.on_install(src)
			return TRUE
		if(lock && istype(W, /obj/item/device/lock_buster))
			var/obj/item/device/lock_buster/L = W
			if(L.on)
				user.visible_message(user, span_warning("[user] is drilling through [src]'s lock!"),
					span_notice("You start drilling through [src]'s lock!"))
				if(do_after(user, 10 SECONDS * W.toolspeed, src))
					if(lock)
						var/obj/O = lock
						lock.on_uninstall()
						qdel(O)
						user.visible_message(user, span_warning("[user] has destroyed [src]'s lock!"),
							span_notice("You destroy [src]'s lock!"))
				else
					user.visible_message(user, span_warning("[user] fails to break through [src]'s lock!"),
					span_notice("You were unable to break through [src]'s lock!"))
				return TRUE
			to_chat(user, span_notice("Turn the [L] on first."))
			return TRUE
		if(W.tool_behaviour == TOOL_WELDER)
			var/repairing = cell || internal_tank || equipment.len || (obj_integrity < max_integrity) || pilot || passengers.len
			if(!hatch_open)
				to_chat(user, span_warning("You must open the maintenance hatch before [repairing ? "attempting repairs" : "unwelding the armor"]."))
				return TRUE
			if(repairing && obj_integrity >= max_integrity)
				to_chat(user, span_warning("[src] is fully repaired!"))
				return TRUE
			to_chat(user, span_notice("You start [repairing ? "repairing [src]" : "slicing off [src]'s armor'"]"))
			if(W.use_tool(src, user, 50, amount=3, volume = 50))
				if(repairing)
					obj_integrity = min(max_integrity, obj_integrity + 10)
					update_icon()
					to_chat(user, span_notice("You mend some [pick("dents","bumps","damage")] with [W]"))
				else if(!cell && !internal_tank && !equipment.len && !pilot && !passengers.len && construction_state == SPACEPOD_ARMOR_WELDED)
					user.visible_message("[user] slices off [src]'s armor.", span_notice("You slice off [src]'s armor."))
					construction_state = SPACEPOD_ARMOR_SECURED
					update_icon()
			return TRUE
	return ..()

/obj/spacepod/attack_hand(mob/user as mob)
	if(user.a_intent == INTENT_GRAB && !locked)
		var/mob/living/target
		if(pilot)
			target = pilot
		else if(passengers.len > 0)
			target = passengers[1]

		if(target && istype(target))
			src.visible_message(span_warning("[user] is trying to rip the door open and pull [target] out of [src]!"),
				span_warning("You see [user] outside the door trying to rip it open!"))
			if(do_after(user, 5 SECONDS, src) && construction_state == SPACEPOD_ARMOR_WELDED)
				if(remove_rider(target))
					target.Stun(20)
					target.visible_message(span_warning("[user] flings the door open and tears [target] out of [src]"),
						span_warning("The door flies open and you are thrown out of [src] and to the ground!"))
				return
			target.visible_message(span_warning("[user] was unable to get the door open!"),
					span_warning("You manage to keep [user] out of [src]!"))

	if(!hatch_open)
		//if(cargo_hold.storage_slots > 0)
		//	if(!locked)
		//		cargo_hold.open(user)
		//	else
		//		to_chat(user, span_notice("The storage compartment is locked"))
		return ..()
	var/list/items = list(cell, internal_tank)
	items += equipment
	var/list/item_map = list()
	var/list/used_key_list = list()
	for(var/obj/I in items)
		item_map[avoid_assoc_duplicate_keys(I.name, used_key_list)] = I
	var/selection = input(user, "Remove which equipment?", null, null) as null|anything in item_map
	var/obj/O = item_map[selection]
	if(O && istype(O) && (O in contents))
		// alrightey now to figure out what it is
		if(O == cell)
			cell = null
		else if(O == internal_tank)
			internal_tank = null
		else if(O in equipment)
			var/obj/item/spacepod_equipment/SE = O
			if(!SE.can_uninstall(user))
				return
			SE.on_uninstall()
		else
			return
		O.forceMove(loc)
		if(isitem(O))
			user.put_in_hands(O)


/obj/spacepod/proc/add_armor(obj/item/pod_parts/armor/armor)
	desc = armor.pod_desc
	max_integrity = armor.pod_integrity
	obj_integrity = max_integrity - integrity_failure + obj_integrity
	pod_armor = armor
	update_icon()

/obj/spacepod/proc/remove_armor()
	if(!pod_armor)
		obj_integrity = min(integrity_failure, obj_integrity)
		max_integrity = integrity_failure
		desc = initial(desc)
		pod_armor = null
		update_icon()


/obj/spacepod/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/params_list = params2list(params)
	if(target == src || istype(target, /obj/screen) || (target && (target in user.GetAllContents())) || user != pilot || params_list["shift"] || params_list["alt"] || params_list["ctrl"])
		return FALSE
	if(weapon)
		weapon.fire_weapons(target)
	return TRUE

/obj/spacepod/take_damage()
	..()
	update_icon()

/obj/spacepod/return_air()
	return cabin_air
/obj/spacepod/remove_air(amount)
	return cabin_air.remove(amount)

/obj/spacepod/proc/slowprocess()
	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.return_temperature() - T20C
		cabin_air.set_temperature(cabin_air.return_temperature() - max(-10, min(10, round(delta/4,0.1))))
	if(internal_tank && cabin_air)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()

		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/turf/T = get_turf(src)
			var/datum/gas_mixture/t_air = T.return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(T)
					T.assume_air(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)

/mob/get_status_tab_items()
	. = ..()
	if(isspacepod(loc))
		var/obj/spacepod/S = loc
		. += ""
		. += "Spacepod Charge: [S.cell ? "[round(S.cell.charge,0.1)]/[S.cell.maxcharge] KJ" : "NONE"]"
		. += "Spacepod Integrity: [round(S.obj_integrity,0.1)]/[S.max_integrity]"
		. += "Spacepod Velocity: [round(sqrt(S.velocity_x*S.velocity_x+S.velocity_y*S.velocity_y), 0.1)] m/s"
		. += ""

/obj/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			for(var/mob/living/M in contents)
				M.ex_act(severity+1)
			deconstruct()
		if(2)
			take_damage(100, BRUTE, BOMB, 0)
		if(3)
			if(prob(40))
				take_damage(40, BRUTE, BOMB, 0)

/obj/spacepod/obj_break()
	if(obj_integrity <= 0)
		return // nah we'll let the other boy handle it
	if(construction_state < SPACEPOD_ARMOR_LOOSE)
		return
	if(pod_armor)
		var/obj/A = pod_armor
		remove_armor()
		qdel(A)
		if(prob(40))
			new /obj/item/stack/sheet/metal/five(loc)
	if(prob(40))
		new /obj/item/stack/sheet/metal/five(loc)
	construction_state = SPACEPOD_CORE_SECURED
	if(cabin_air)
		var/datum/gas_mixture/GM = cabin_air.remove_ratio(1)
		var/turf/T = get_turf(src)
		if(GM && T)
			T.assume_air(GM)
	cell = null
	internal_tank = null
	for(var/atom/movable/AM in contents)
		if(AM in equipment)
			var/obj/item/spacepod_equipment/SE = AM
			if(istype(SE))
				SE.on_uninstall(src)
		if(ismob(AM))
			forceMove(AM, loc)
			remove_rider(AM)
		else if(prob(60))
			AM.forceMove(loc)
		else if(isitem(AM) || !isobj(AM))
			qdel(AM)
		else
			var/obj/O = AM
			O.forceMove(loc)
			O.deconstruct()

/obj/spacepod/deconstruct(disassembled = FALSE)
	if(!get_turf(src))
		qdel(src)
		return
	remove_rider(pilot)
	while(passengers.len)
		remove_rider(passengers[1])
	passengers.Cut()
	if(disassembled)
		// AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		// alright fine fine you can have the frame pieces back
		var/clamped_angle = (round(angle, 90) % 360 + 360) % 360
		var/target_dir = NORTH
		switch(clamped_angle)
			if(0)
				target_dir = NORTH
			if(90)
				target_dir = EAST
			if(180)
				target_dir = SOUTH
			if(270)
				target_dir = WEST

		var/list/frame_piece_types = list(/obj/item/pod_parts/pod_frame/aft_port, /obj/item/pod_parts/pod_frame/aft_starboard, /obj/item/pod_parts/pod_frame/fore_port, /obj/item/pod_parts/pod_frame/fore_starboard)
		var/obj/item/pod_parts/pod_frame/current_piece = null
		var/turf/CT = get_turf(src)
		var/list/frame_pieces = list()
		for(var/frame_type in frame_piece_types)
			var/obj/item/pod_parts/pod_frame/F = new frame_type
			F.dir = target_dir
			F.anchored = TRUE
			if(1 == turn(F.dir, -F.link_angle))
				current_piece = F
			frame_pieces += F
		while(current_piece && !current_piece.loc)
			if(!CT)
				break
			current_piece.forceMove(CT)
			CT = get_step(CT, turn(current_piece.dir, -current_piece.link_angle))
			current_piece = locate(current_piece.link_to) in frame_pieces
		// there here's your frame pieces back, happy?
	qdel(src)

/obj/spacepod/update_icon()
	cut_overlays()
	if(construction_state != SPACEPOD_ARMOR_WELDED)
		icon = 'goon/icons/obj/spacepods/construction_2x2.dmi'
		icon_state = "pod_[construction_state]"
		if(pod_armor && construction_state >= SPACEPOD_ARMOR_LOOSE)
			var/mutable_appearance/masked_armor = mutable_appearance(icon = 'goon/icons/obj/spacepods/construction_2x2.dmi', icon_state = "armor_mask")
			var/mutable_appearance/armor = mutable_appearance(pod_armor.pod_icon, pod_armor.pod_icon_state)
			armor.blend_mode = BLEND_MULTIPLY
			masked_armor.overlays = list(armor)
			masked_armor.appearance_flags = KEEP_TOGETHER
			add_overlay(masked_armor)
		return

	if(pod_armor)
		icon = pod_armor.pod_icon
		icon_state = pod_armor.pod_icon_state
	else
		icon = 'goon/icons/obj/spacepods/2x2.dmi'
		icon_state = initial(icon_state)

	if(obj_integrity <= max_integrity / 2)
		add_overlay(image(icon='goon/icons/obj/spacepods/2x2.dmi', icon_state="pod_damage"))
		if(obj_integrity <= max_integrity / 4)
			add_overlay(image(icon='goon/icons/obj/spacepods/2x2.dmi', icon_state="pod_fire"))

	if(weapon && weapon.overlay_icon_state)
		add_overlay(image(icon=weapon.overlay_icon,icon_state=weapon.overlay_icon_state))

	light_color = icon_light_color[icon_state] || LIGHT_COLOR_WHITE

	// Thrust!
	var/list/left_thrusts = list()
	left_thrusts.len = 8
	var/list/right_thrusts = list()
	right_thrusts.len = 8
	for(var/cdir in GLOB.cardinals)
		left_thrusts[cdir] = 0
		right_thrusts[cdir] = 0
	var/back_thrust = 0
	if(last_thrust_right != 0)
		var/tdir = last_thrust_right > 0 ? WEST : EAST
		left_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
		right_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
	if(last_thrust_forward > 0)
		back_thrust = last_thrust_forward / forward_maxthrust
	if(last_thrust_forward < 0)
		left_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
		right_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
	if(last_rotate != 0)
		var/frac = abs(last_rotate) / max_angular_acceleration
		for(var/cdir in GLOB.cardinals)
			if(last_rotate > 0)
				right_thrusts[cdir] += frac
			else
				left_thrusts[cdir] += frac
	for(var/cdir in GLOB.cardinals)
		var/left_thrust = left_thrusts[cdir]
		var/right_thrust = right_thrusts[cdir]
		if(left_thrust)
			add_overlay(image(icon = 'yogstation/icons/obj/spacepods/2x2.dmi', icon_state = "rcs_left", dir = cdir))
		if(right_thrust)
			add_overlay(image(icon = 'yogstation/icons/obj/spacepods/2x2.dmi', icon_state = "rcs_right", dir = cdir))
	if(back_thrust)
		var/image/I = image(icon = 'yogstation/icons/obj/spacepods/2x2.dmi', icon_state = "thrust")
		I.transform = matrix(1, 0, 0, 0, 1, -32)
		add_overlay(I)

/obj/spacepod/MouseDrop_T(atom/movable/A, mob/living/user)
	if(user == pilot || (user in passengers) || construction_state != SPACEPOD_ARMOR_WELDED)
		return

	if(istype(A, /obj/machinery/portable_atmospherics/canister))
		if(internal_tank)
			to_chat(user, span_warning("[src] already has an internal_tank!"))
			return
		if(!A.Adjacent(src))
			to_chat(user, span_warning("The canister is not close enough!"))
			return
		if(hatch_open)
			to_chat(user, span_warning("The hatch is shut!"))
		to_chat(user, span_notice("You begin inserting the canister into [src]"))
		if(do_after_mob(user, list(A, src), 50) && construction_state == SPACEPOD_ARMOR_WELDED)
			to_chat(user, span_notice("You insert the canister into [src]"))
			A.forceMove(src)
			internal_tank = A
		return

	if(isliving(A))
		var/mob/living/M = A
		if(M != user && !locked)
			if(passengers.len >= max_passengers && !pilot)
				to_chat(user, span_danger("<b>[A.p_they()] can't fly the pod!</b>"))
				return
			if(passengers.len < max_passengers)
				visible_message(span_danger("[user] starts loading [M] into [src]!"))
				if(do_after_mob(user, list(M, src), 50) && construction_state == SPACEPOD_ARMOR_WELDED)
					add_rider(M, FALSE)
			return
		if(M == user)
			enter_pod(user)
			return

	return ..()

/obj/spacepod/proc/enter_pod(mob/living/user)
	if(user.stat != CONSCIOUS)
		return FALSE

	if(locked)
		to_chat(user, span_warning("[src]'s doors are locked!"))
		return FALSE

	if(!istype(user))
		return FALSE

	if(user.incapacitated())
		return FALSE
	if(!ishuman(user))
		return FALSE

	if(passengers.len <= max_passengers || !pilot)
		visible_message(span_notice("[user] starts to climb into [src]."))
		if(do_after(user, 4 SECONDS, src) && construction_state == SPACEPOD_ARMOR_WELDED)
			var/success = add_rider(user)
			if(!success)
				to_chat(user, span_notice("You were too slow. Try better next time, loser."))
			return success
		else
			to_chat(user, span_notice("You stop entering [src]."))
	else
		to_chat(user, span_danger("You can't fit in [src], it's full!"))
	return FALSE

/obj/spacepod/proc/verb_check(require_pilot = TRUE, mob/user = null)
	if(!user)
		user = usr
	if(require_pilot && user != pilot)
		to_chat(user, span_notice("You can't reach the controls from your chair"))
		return FALSE
	return !user.incapacitated() && isliving(user)

/obj/spacepod/verb/exit_pod()
	set name = "Exit pod"
	set category = "Spacepod"
	set src = usr.loc

	if(!isliving(usr) || usr.stat > CONSCIOUS)
		return

	if(usr.restrained())
		to_chat(usr, span_notice("You attempt to stumble out of [src]. This will take two minutes."))
		if(pilot)
			to_chat(pilot, span_warning("[usr] is trying to escape [src]."))
		if(!do_after(usr, 2 MINUTES, src))
			return

	if(remove_rider(usr))
		to_chat(usr, span_notice("You climb out of [src]."))

/obj/spacepod/verb/lock_pod()
	set name = "Lock Doors"
	set category = "Spacepod"
	set src = usr.loc

	if(!verb_check(FALSE))
		return

	if(!lock)
		to_chat(usr, span_warning("[src] has no locking mechanism."))
		locked = FALSE //Should never be false without a lock, but if it somehow happens, that will force an unlock.
	else
		locked = !locked
		to_chat(usr, span_warning("You [locked ? "lock" : "unlock"] the doors."))

/obj/spacepod/verb/toggle_brakes()
	set name = "Toggle Brakes"
	set category = "Spacepod"
	set src = usr.loc

	if(!verb_check())
		return
	brakes = !brakes
	to_chat(usr, span_notice("You toggle the brakes [brakes ? "on" : "off"]."))

/obj/spacepod/AltClick(user)
	if(!verb_check(user = user))
		return
	brakes = !brakes
	to_chat(usr, span_notice("You toggle the brakes [brakes ? "on" : "off"]."))

/obj/spacepod/verb/toggleLights()
	set name = "Toggle Lights"
	set category = "Spacepod"
	set src = usr.loc

	if(!verb_check())
		return

	lights = !lights
	if(lights)
		set_light(lights_power)
	else
		set_light(0)
	to_chat(usr, "Lights toggled [lights ? "on" : "off"].")
	for(var/mob/M in passengers)
		to_chat(M, "Lights toggled [lights ? "on" : "off"].")

/obj/spacepod/verb/toggleDoors()
	set name = "Toggle Nearby Pod Doors"
	set category = "Spacepod"
	set src = usr.loc

	if(!verb_check())
		return

	for(var/obj/machinery/door/poddoor/multi_tile/P in orange(3,src))
		for(var/mob/living/carbon/human/O in contents)
			if(P.check_access(O.get_active_held_item()) || P.check_access(O.wear_id))
				if(P.density)
					P.open()
					return TRUE
				else
					P.close()
					return TRUE
		to_chat(usr, span_warning("Access denied."))
		return

	to_chat(usr, span_warning("You are not close to any pod doors."))

/obj/spacepod/proc/add_rider(mob/living/M, allow_pilot = TRUE)
	if(M == pilot || (M in passengers))
		return FALSE
	if(!pilot && allow_pilot)
		pilot = M
		LAZYOR(M.mousemove_intercept_objects, src)
		M.click_intercept = src
		addverbs(M)
	else if(passengers.len < max_passengers)
		passengers += M
	else
		return FALSE
	M.stop_pulling()
	M.forceMove(src)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	return TRUE

/obj/spacepod/proc/remove_rider(mob/living/M)
	if(!M)
		return
	if(M == pilot)
		pilot = null
		removeverbs(M)
		LAZYREMOVE(M.mousemove_intercept_objects, src)
		if(M.click_intercept == src)
			M.click_intercept = null
		desired_angle = null // since there's no pilot there's no one aiming it.
	else if(M in passengers)
		passengers -= M
	else
		return FALSE
	if(M.loc == src)
		M.forceMove(loc)
	if(M.client)
		M.client.pixel_x = 0
		M.client.pixel_y = 0
	return TRUE

/obj/spacepod/onMouseMove(object,location,control,params)
	if(!pilot || !pilot.client || pilot.incapacitated())
		return // I don't know what's going on.
	var/list/params_list = params2list(params)
	var/sl_list = splittext(params_list["screen-loc"],",")
	var/sl_x_list = splittext(sl_list[1], ":")
	var/sl_y_list = splittext(sl_list[2], ":")
	var/view_list = isnum(pilot.client.view) ? list("[pilot.client.view*2+1]","[pilot.client.view*2+1]") : splittext(pilot.client.view, "x")
	var/dx = text2num(sl_x_list[1]) + (text2num(sl_x_list[2]) / world.icon_size) - 1 - text2num(view_list[1]) / 2
	var/dy = text2num(sl_y_list[1]) + (text2num(sl_y_list[2]) / world.icon_size) - 1 - text2num(view_list[2]) / 2
	if(sqrt(dx*dx+dy*dy) > 1)
		desired_angle = 90 - ATAN2(dx, dy)
	else
		desired_angle = null

/obj/spacepod/relaymove(mob/user, direction)
	if(user != pilot || pilot.incapacitated())
		return
	user_thrust_dir = direction

/obj/spacepod/Entered()
	. = ..()
/obj/spacepod/Exited()
	. = ..()

/obj/spacepod/proc/addverbs(mob/user)
	add_verb(user, /obj/spacepod/verb/toggleDoors)
	add_verb(user, /obj/spacepod/verb/toggleLights)
	add_verb(user, /obj/spacepod/verb/toggle_brakes)
	add_verb(user, /obj/spacepod/verb/lock_pod)
	add_verb(user, /obj/spacepod/verb/exit_pod)

/obj/spacepod/proc/removeverbs(mob/user)
	remove_verb(user, /obj/spacepod/verb/toggleDoors)
	remove_verb(user, /obj/spacepod/verb/toggleLights)
	remove_verb(user, /obj/spacepod/verb/toggle_brakes)
	remove_verb(user, /obj/spacepod/verb/lock_pod)
	remove_verb(user, /obj/spacepod/verb/exit_pod)
