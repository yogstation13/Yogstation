// Port from NSV13 which is port from Eris.
// Of course the NSV13 version had comments that appeared as questionmarks
// because it was originally in Russian. I've fixed that though

/obj/structure/railing
	name = "railing"
	desc = "A standard steel railing. Prevents stupid people from falling to their doom. Drag yourself onto it to climb over, or click it with an open hand whilst pulling something to dump it over the edge."
	icon = 'icons/obj/railing.dmi'
	density = TRUE
	climbable = TRUE
	anchored = TRUE
	icon_state = "railing0"
	layer = ABOVE_OBJ_LAYER //Just above doors
	var/check = FALSE
	var/ini_dir
	flags_1 = ON_BORDER_1

/obj/structure/railing/attack_hand(mob/user)
	. = ..()
	if(user.pulling)
		to_chat(user, "<span class='warning'>You start to dump [user.pulling] over [src]!</span>")
		if(do_after(user, 50, target = src))
			if(!user.pulling || QDELETED(user.pulling))
				return
			visible_message("<span class='warning'>[user] dumps [user.pulling] over [src]!</span>")
			user.pulling.forceMove(get_step(src, user.loc == loc ? dir : 0))

/obj/structure/railing/can_zFall(turf/source, levels = 1, turf/target, direction)
	if(!..())
		return FALSE
	var/turf/other = get_step(source, ini_dir)
	var/turf/other_below = other.below()
	return other.can_zFall(src, levels, other, other_below)

/obj/structure/railing/built //Player constructed
	anchored = FALSE

/obj/structure/railing/attackby(obj/item/I,mob/user)
	if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(anchored)
			to_chat(user, "<span class='warning'>You need to unanchor [src] first!</span>")
		else
			I.play_tool_sound(src, 100)
			deconstruct()
	if(default_unfasten_wrench(user, I))
		update_icon()
		return TRUE
	. = ..()

/obj/structure/railing/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags_1&NODECONSTRUCT_1))
		var/obj/R = new /obj/item/stack/rods(drop_location(), 2)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/railing/can_be_unfasten_wrench(mob/user, silent)
	var/turf/other = get_step(src, dir)
	// require either a floor or catwalk on one of the two turfs we're straddling
	if(!(isfloorturf(loc) || isindestructiblefloor(loc) || (locate(/obj/structure/lattice/catwalk) in loc)) && !(isfloorturf(other) || isindestructiblefloor(other) || (locate(/obj/structure/lattice/catwalk) in other)) && !anchored)
		to_chat(user, "<span class='warning'>[src] needs to be on the floor to be secured!</span>")
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/structure/railing/Initialize(constructed=0)
	. = ..()
	if(anchored)
		update_icon(0)
	ini_dir = dir

/obj/structure/railing/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_FLIP | ROTATION_VERBS ,null,CALLBACK(src, .proc/can_be_rotated),CALLBACK(src,.proc/after_rotation))

/obj/structure/railing/Destroy()
	anchored = null
	broken = 1
	for(var/obj/structure/railing/R in oview(src, 1))
		R.update_icon()
	. = ..()

/obj/structure/railing/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && ((mover.pass_flags & PASSTABLE) || (mover.pass_flags & LETPASSTHROW)))
		return TRUE
	if(!mover)
		return TRUE
	if(get_dir(loc, target) == dir)
		return !density
	else
		return TRUE

/obj/structure/railing/Move()
	. = ..()
	setDir(ini_dir)

/obj/structure/railing/proc/NeighborsCheck(var/UpdateNeighbors = 1)
	check = 0
	//if (!anchored) return
	var/Rturn = turn(src.dir, -90)
	var/Lturn = turn(src.dir, 90)

	for(var/obj/structure/railing/R in src.loc)// Look at our tile
		if ((R.dir == Lturn) && R.anchored)// check left side
			//src.LeftSide[1] = 1
			check |= 32
			if (UpdateNeighbors)
				R.update_icon(0)
		if ((R.dir == Rturn) && R.anchored)// check right side
			//src.RightSide[1] = 1
			check |= 2
			if (UpdateNeighbors)
				R.update_icon(0)

	for (var/obj/structure/railing/R in get_step(src, Lturn))// Look at the tile on the left of us
		if ((R.dir == src.dir) && R.anchored)
			//src.LeftSide[2] = 1
			check |= 16
			if (UpdateNeighbors)
				R.update_icon(0)
	for (var/obj/structure/railing/R in get_step(src, Rturn))// Look at the tile on the right of us
		if ((R.dir == src.dir) && R.anchored)
			//src.RightSide[2] = 1
			check |= 1
			if (UpdateNeighbors)
				R.update_icon(0)

	for (var/obj/structure/railing/R in get_step(src, (Lturn + src.dir)))// Look at the front-left diagonal
		if ((R.dir == Rturn) && R.anchored)
			check |= 64
			if (UpdateNeighbors)
				R.update_icon(0)
	for (var/obj/structure/railing/R in get_step(src, (Rturn + src.dir)))// Look at the front-right diagonal
		if ((R.dir == Lturn) && R.anchored)
			check |= 4
			if (UpdateNeighbors)
				R.update_icon(0)

/obj/structure/railing/update_icon(var/UpdateNeighbors = 1)
	NeighborsCheck(UpdateNeighbors)
	overlays.Cut()
	if (!check || !anchored)//|| !anchored
		icon_state = "railing0"
	else
		icon_state = "railing1"
		// left side
		if (check & 32)
			overlays += image('icons/obj/railing.dmi', src, "corneroverlay")
		if ((check & 16) || !(check & 32) || (check & 64))
			overlays += image('icons/obj/railing.dmi', src, "frontoverlay_l")
		if (!(check & 2) || (check & 1) || (check & 4))
			overlays += image('icons/obj/railing.dmi', src, "frontoverlay_r")
			if(check & 4)
				switch (src.dir)
					if (NORTH)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_x = 32)
					if (SOUTH)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_x = -32)
					if (EAST)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_y = -32)
					if (WEST)
						overlays += image('icons/obj/railing.dmi', src, "mcorneroverlay", pixel_y = 32)

/obj/structure/railing/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE
	
	var/target_dir = turn(dir, rotation_type == ROTATION_FLIP ? 180 : (rotation_type == ROTATION_CLOCKWISE ? -90 : 90))

	if(!valid_window_location(loc, target_dir))
		to_chat(user, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE
	return TRUE

/obj/structure/railing/proc/after_rotation(mob/user,rotation_type)
	ini_dir = dir
	update_icon()

/obj/structure/railing/do_climb(var/mob/living/user)
	if(get_turf(user) == get_turf(src))
		usr.forceMove(get_step(src, src.dir))
	else
		usr.forceMove(get_turf(src))

/obj/structure/railing/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1