/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/railing.dmi'
	icon_state = "railing"
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW|PASSSTRUCTURE
	layer = ABOVE_MOB_LAYER
	pixel_y = -16

	///Boolean on whether the railing should be cimable.
	var/climbable = TRUE
	///Initial direction of the railing.
	var/ini_dir

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE

	climbable = FALSE

/obj/structure/railing/Initialize(mapload)
	. = ..()
	ini_dir = dir
	if(climbable)
		AddElement(/datum/element/climbable)
	
	if(density && flags_1 & ON_BORDER_1) // blocks normal movement from and to the direction it's facing.
		var/static/list/loc_connections = list(
			COMSIG_ATOM_EXIT = PROC_REF(on_exit),
		)
		AddElement(/datum/element/connect_loc, loc_connections)
	
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS ,null,CALLBACK(src, PROC_REF(can_be_rotated)),CALLBACK(src, PROC_REF(after_rotation)))

/obj/structure/railing/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume=50))
				update_integrity(max_integrity)
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

/obj/structure/railing/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!anchored)
		to_chat(user, span_warning("You cut apart the railing."))
		I.play_tool_sound(src, 100)
		deconstruct()
		return TRUE

/obj/structure/railing/deconstruct(disassembled)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/stack/rods/rod = new /obj/item/stack/rods(drop_location(), 3)
		transfer_fingerprints_to(rod)
		. = ..()
///Implements behaviour that makes it possible to unanchor the railing.
/obj/structure/railing/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(flags_1&NODECONSTRUCT_1)
		return
	to_chat(user, span_notice("You begin to [anchored ? "unfasten the railing from":"fasten the railing to"] the floor..."))
	if(I.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		setAnchored(!anchored)
		to_chat(user, span_notice("You [anchored ? "fasten the railing to":"unfasten the railing from"] the floor."))
	return TRUE

/obj/structure/railing/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(get_dir(loc, target) & dir)
		var/checking = FLYING | FLOATING
		return . || mover.throwing || mover.movement_type & checking
	return TRUE

/obj/structure/railing/corner/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return TRUE

/obj/structure/railing/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return // Let's not block ourselves.

	if(!(direction & dir))
		return

	if (!density)
		return

	if (leaving.throwing)
		return

	if (leaving.movement_type & (PHASING|MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/railing/proc/can_be_rotated(mob/user, rotation_type)
	var/silent = FALSE
	if(!Adjacent(user))
		silent = TRUE

	if(anchored)
		if (!silent)
			to_chat(user, span_warning("[src] cannot be rotated while it is fastened to the floor!"))
		return FALSE

	var/target_dir = turn(dir, rotation_type == ROTATION_CLOCKWISE ? -90 : 90)

	if(!valid_window_location(loc, target_dir)) //Expanded to include rails, as well!
		if (!silent)
			to_chat(user, span_warning("[src] cannot be rotated in that direction!"))
		return FALSE

	return TRUE

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/proc/after_rotation(mob/user,rotation_type)
	ini_dir = dir
	add_fingerprint(user)
