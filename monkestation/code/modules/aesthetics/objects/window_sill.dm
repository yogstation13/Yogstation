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
	. = ..()
	if(!isstack(attacking_item))
		return FALSE
	var/obj/item/stack/stack_item = attacking_item
	if(istype(attacking_item, /obj/item/stack/sheet/glass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/rglass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/reinforced/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/plasmarglass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/reinforced/plasma/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/plasmaglass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/rods))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/grille/window_sill(get_turf(src))
			stack_item.amount -= 2
			return TRUE

//merges adjacent full-tile windows into one
/obj/structure/window_sill/update_overlays(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)
