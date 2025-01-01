/obj/item/traitor_machine_trapper/door_charge
	name = "Door Charge"
	desc = "A small explosive charge that can be rigged onto a door."
	deploy_time = 2 SECONDS
	target_machine_path = /obj/machinery/door
	explosion_range = 5
	component_datum = /datum/component/interaction_booby_trap/door

/datum/component/interaction_booby_trap/door
	explosion_heavy_range = 2
