GLOBAL_LIST_INIT(sheets_to_window_types, zebra_typecacheof(list(
	/obj/item/stack/sheet/glass = /obj/structure/window/fulltile,
	/obj/item/stack/sheet/rglass = /obj/structure/window/reinforced/fulltile,
	/obj/item/stack/sheet/plasmaglass = /obj/structure/window/plasma/fulltile,
	/obj/item/stack/sheet/plasmarglass = /obj/structure/window/reinforced/plasma/fulltile,
	/obj/item/stack/sheet/plastitaniumglass = /obj/structure/window/reinforced/plasma/plastitanium,
	/obj/item/stack/sheet/bronze = /obj/structure/window/bronze/fulltile,
	/obj/item/stack/rods = /obj/structure/grille/window_sill,
)))

/obj/structure/window_sill
	icon = 'monkestation/icons/obj/structures/window/window_sill.dmi'
	base_icon_state = "window_sill"
	icon_state = "window_sill-0"
	layer = ABOVE_OBJ_LAYER - 0.02
	canSmoothWith =  SMOOTH_GROUP_WINDOW_SILL + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WALLS
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_WINDOW_SILL
	smooth_adapters = SMOOTH_ADAPTERS_WALLS
	pass_flags_self = PASSTABLE | LETPASSTHROW
	density = TRUE
	anchored = TRUE

/obj/structure/window_sill/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

/obj/structure/window_sill/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src, 100)
	deconstruct()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/window_sill/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	new /obj/item/stack/sheet/iron(drop_location())
	qdel(src)

/obj/structure/window_sill/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!isturf(loc) || the_rcd.mode != RCD_WINDOWGRILLE)
		return FALSE
	var/obj/structure/grille/existing_grille = locate() in loc
	if(existing_grille)
		return existing_grille.rcd_vals(user, the_rcd)
	return rcd_result_with_memory(
		list("mode" = RCD_WINDOWGRILLE, "delay" = 1 SECONDS, "cost" = 4),
		loc, RCD_MEMORY_WINDOWGRILLE,
	)

/obj/structure/window_sill/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(!isturf(loc) || passed_mode != RCD_WINDOWGRILLE)
		return FALSE
	var/obj/structure/window/window_path = the_rcd.window_type
	if(!ispath(window_path))
		CRASH("Invalid window path type in RCD: [window_path]")
	if(!window_path::fulltile)
		return FALSE
	var/obj/structure/grille/existing_grille = locate() in loc
	if(!existing_grille)
		var/obj/structure/grille/window_sill/new_grille = new(loc)
		new_grille.set_anchored(TRUE)
		return TRUE
	return existing_grille.rcd_act(user, the_rcd, passed_mode)

/obj/structure/window_sill/attackby(obj/item/attacking_item, mob/user, params)
	var/obj/item/stack/stack = attacking_item
	if((user.istate & ISTATE_HARM) || !isstack(stack))
		return ..()
	var/obj/structure/window_type = GLOB.sheets_to_window_types[stack.type]
	if(!window_type)
		return ..()
	var/turf/our_turf = get_turf(src)
	if(our_turf.is_blocked_turf(
		exclude_mobs = TRUE,
		source_atom = src,
		ignore_atoms = ispath(window_type, /obj/structure/grille) ? null : typesof(/obj/structure/grille),
		type_list = TRUE,
	))
		balloon_alert(user, "blocked!")
		return
	if(stack.amount < 2)
		balloon_alert(user, "need at least 2 of \the [stack]!")
		return
	balloon_alert_to_viewers("building [window_type::name]...")
	if(!do_after(user, 2 SECONDS, src, extra_checks = CALLBACK(src, PROC_REF(window_build_check), stack, 2)))
		return
	if(!stack.use(2))
		balloon_alert(user, "need at least 2 of \the [stack]!")
		return
	balloon_alert_to_viewers("built [window_type::name]")
	new window_type(our_turf)

//merges adjacent full-tile windows into one
/obj/structure/window_sill/update_overlays(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)

/obj/structure/window_sill/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return TRUE
	if(mover.movement_type & (FLYING | FLOATING))
		return TRUE
	if(locate(/obj/structure/window_sill) in get_turf(mover))
		return TRUE

/obj/structure/window_sill/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.movement_type & (FLYING | FLOATING))
		return TRUE
	if(pass_info.pass_flags & PASSTABLE)
		return TRUE
	return FALSE

/obj/structure/window_sill/proc/window_build_check(obj/item/stack/stack, min_amt)
	return !QDELETED(src) && !QDELETED(stack) && stack.amount >= min_amt
