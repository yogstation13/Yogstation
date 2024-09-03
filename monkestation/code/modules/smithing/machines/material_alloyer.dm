/obj/machinery/material_alloyer
	name = "metal alloyer"
	desc = "A small machine that can create an alloy of basically any two materials;blending their stats."
	icon = 'monkestation/code/modules/smithing/icons/forge_structures.dmi'
	icon_state = "material_alloyer"
	bound_width = 32
	bound_height = 32
	anchored = TRUE
	max_integrity = 200
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 1500
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	circuit = /obj/item/circuitboard/machine/material_alloyer
	light_outer_range = 3
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE

	///the item in our first slot for merging
	var/atom/movable/slot_one_item
	///the item in our second slot for merging
	var/atom/movable/slot_two_item


/obj/machinery/material_alloyer/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/material_alloyer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item)
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_RMB] = "Open Maint. Panel"
		if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
			context[SCREENTIP_CONTEXT_RMB] = "Deconstruct."
	if((!slot_one_item || !slot_two_item) && (isstack(held_item) || istype(held_item, /obj/item/merged_material)))
		context[SCREENTIP_CONTEXT_LMB] = "Add material to alloy."
	if(slot_one_item && slot_two_item)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Alloy Materials."
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/material_alloyer/attackby(obj/item/attacking_item, mob/living/user, params)
	if(isstack(attacking_item))
		var/obj/item/stack/stack = attacking_item
		if(!stack.material_type)
			return
		if(stack.amount > 1)
			attacking_item = stack.split_stack(user, 1)

		if(try_add_to_buffer(attacking_item))
			visible_message(span_notice("[user] adds [attacking_item] into the [src]"))
			return
	if(istype(attacking_item, /obj/item/merged_material))
		if(try_add_to_buffer(attacking_item))
			visible_message(span_notice("[user] adds [attacking_item] into the [src]"))
			return
	return ..()
/obj/machinery/material_alloyer/attackby_secondary(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour == TOOL_SCREWDRIVER)
		default_deconstruction_screwdriver(user,"material_alloyer_open","material_alloyer",weapon)
		return
	if(weapon.tool_behaviour == TOOL_CROWBAR)
		default_deconstruction_crowbar(weapon)
		return
	return ..()

/obj/machinery/material_alloyer/proc/try_add_to_buffer(obj/item/adder)
	if(!slot_one_item)
		slot_one_item = adder
		adder.forceMove(src)
		return TRUE
	if(!slot_two_item)
		slot_two_item = adder
		adder.forceMove(src)
		return TRUE
	return FALSE

/obj/machinery/material_alloyer/AltClick(mob/user)
	if(attempt_material_forge())
		return TRUE
	. = ..()

/obj/machinery/material_alloyer/proc/attempt_material_forge()
	if(!slot_one_item || !slot_two_item)
		return FALSE

	var/obj/item/merged_material/new_material = new(get_turf(src))
	if(isstack(slot_one_item))
		var/obj/item/stack/stack = slot_one_item
		new_material.create_stats_from_material(stack.material_type)
	else
		new_material.create_stats_from_material_stats(slot_one_item.material_stats)

	new_material.combine_material_stats(slot_two_item)

	new_material.name = "[new_material.material_stats.material_name] Ingot"

	QDEL_NULL(slot_one_item)
	QDEL_NULL(slot_two_item)
	return TRUE

/obj/item/circuitboard/machine/material_alloyer
	name = "material alloyer"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor = 4
	)
	build_path = /obj/machinery/material_alloyer
