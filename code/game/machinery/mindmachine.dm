/obj/machinery/mindmachine
	name = "\improper Mind Machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/machines/mind_machine.dmi'
	active_power_usage = 10000 // Placeholder value.
	density = TRUE

/obj/machinery/mindmachine_hub
	name = "\improper Mind Machine Hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. \
			Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	icon_state = "hub"
	circuit = /obj/item/circuitboard/machine/mindmachine_hub

/obj/machinery/mindmachine_pod
	name = "\improper Mind Machine Pod"
	desc = "A large pod used for mind transfers. \
	Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	icon_state = "pod_open"
	circuit = /obj/item/circuitboard/machine/mindmachine_pod
