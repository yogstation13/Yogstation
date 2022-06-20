/obj/machinery/fishing
	name = "fishing machine"
	desc = "Your little home away from home."
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "machinee"
	density = TRUE
	var/active = FALSE
	active_power_usage = 100
	idle_power_usage = 50
	use_power = IDLE_POWER_USE
	var/datum/component/fishable/fishing_component

/obj/machinery/fishing/Initialize()
	. = ..()
	var/pow = powered(power_channel)
	fishing_component = AddComponent(/datum/component/fishable,pow)

/obj/machinery/fishing/Destroy()
	fishing_component.interrupt()
	QDEL_NULL(fishing_component)
	. = ..()

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

/obj/machinery/fishing/update_icon()
	. = ..()
	cut_overlays()
	icon_state = panel_open ? "machine_open" : "machine"
	if(active)
		add_overlay(mutable_appearance(icon,"machine_overlay"))
	

/obj/machinery/fishing/process()
	if(active && !is_operational())
		toggle_power()

/obj/machinery/fishing/cargo //you can buy a better one from cargo
	flags_1 = NODECONSTRUCT_1
	circuit = null


/obj/item/circuitboard/machine/fishing
	name = "Fishing Machine (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/fishing
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)
