/obj/machinery/fishing
	name = "fishing machine"
	desc = "Your little home away from home."
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "machine"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/fishing
	active_power_usage = 100
	idle_power_usage = 50
	use_power = IDLE_POWER_USE

	var/datum/component/fishable/fishing_component
	var/active = FALSE
	var/overlay_name = "machine_overlay"
	var/syndicate_chummed = FALSE

/obj/machinery/fishing/Initialize()
	. = ..()
	fishing_component = AddComponent(/datum/component/fishable,FALSE)
	set_biome()

/obj/machinery/fishing/Destroy()
	fishing_component.interrupt()
	QDEL_NULL(fishing_component)
	. = ..()

/obj/machinery/fishing/proc/set_biome()
	if(syndicate_chummed)
		overlay_name = "machine_overlay_syndicate"
		return
	var/area/A = get_area(src)
	if(istype(A,/area/maintenance/))
		fishing_component.loot = GLOB.fishing_table["maintenance"]
		return
	if(istype(A,/area/lavaland/))
		fishing_component.loot = GLOB.fishing_table["lavaland"]
		return
	fishing_component.loot = GLOB.fishing_table["water"]	

/obj/machinery/fishing/interact(mob/user, special_state)
	if(panel_open)
		return ..()
	toggle_power()

/obj/machinery/fishing/proc/toggle_power()
	active = !active
	use_power = active + 1
	if(!active)
		//interrupt fishing
		fishing_component.interrupt()
	fishing_component.can_fish = active
	update_icon()

/obj/machinery/fishing/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_crowbar(I))
		return

	if(!active && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return

	if(I.tool_behaviour == TOOL_WRENCH)
		if(active)
			to_chat(user,span_notice("Turn it off first!"))
			return
		to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
			setAnchored(!anchored)
	else
		return ..()

/obj/machinery/fishing/setAnchored(anchorvalue)
	. = ..()
	if(anchored)
		set_biome()

/obj/machinery/fishing/update_icon()
	. = ..()
	cut_overlays()
	icon_state = panel_open ? "[initial(icon_state)]_open" : initial(icon_state)
	if(active)
		add_overlay(mutable_appearance(icon,overlay_name))
	

/obj/machinery/fishing/process()
	if(active && !is_operational())
		toggle_power()

/obj/machinery/fishing/cargo //you can buy a better one from cargo
	icon_state = "machine_gold"
	flags_1 = NODECONSTRUCT_1
	circuit = null
	anchored = FALSE
