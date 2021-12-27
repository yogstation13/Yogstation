/obj/machinery/ai_fabricator
	name = "circuit fabricator"
	desc = "It produces items using metal and glass."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	//circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER

	var/datum/component/remote_materials/materials
	var/datum/techweb/stored_research

/obj/machinery/ai_fabricator/Initialize()
	materials = AddComponent(/datum/component/remote_materials, "mechfab", mapload && link_on_init)
	stored_research = SSresearch.science_tech
	. = ..()
