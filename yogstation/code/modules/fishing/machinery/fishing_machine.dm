/obj/machinery/fishing
	name = "fishing machine"
	desc = "Your little home away from home."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray2"
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
	QDEL_NULL(fishing_component)
	. = ..()
	

/obj/machinery/fishing/process()
	fishing_component.can_fish = is_operational()

/obj/item/circuitboard/machine/fishing
	name = "Fishing Machine (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/fishing
	req_components = list()
