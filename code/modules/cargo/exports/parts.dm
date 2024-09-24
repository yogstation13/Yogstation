// Circuit boards, spare parts, etc.

/datum/export/solar/assembly
	cost = 50
	unit_name = "solar panel assembly"
	export_types = list(/obj/item/solar_assembly)

/datum/export/solar/tracker_board
	cost = 100
	unit_name = "solar tracker board"
	export_types = list(/obj/item/electronics/tracker)

/datum/export/solar/control_board
	cost = 150
	unit_name = "solar panel control board"
	export_types = list(/obj/item/circuitboard/computer/solar_control)

//Hunting headcrabs might be profitable...
/datum/export/xenmeat
	cost = 30
	unit_name = "xen flesh"
	export_types = list(/obj/item/reagent_containers/food/snacks/meat/slab/xen)

/datum/export/watercanister
	cost = 30
	unit_name = "water canister"
	export_types = list(/obj/item/water_canister)

//clearing out xen infestations might be profitable... or even farming them?
/datum/export/xenshrooms
	cost = 15
	unit_name = "xenian mushrooms"
	export_types = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem)

//package and sell medkits for a profit
/datum/export/medkits
	cost = 50
	unit_name = "medkits"
	export_types = list(/obj/item/reagent_containers/pill/patch/medkit/manufactured)

//sell manufactured rations for money
/datum/export/rations
	cost = 35
	unit_name = "rations"
	export_types = list(/obj/item/reagent_containers/food/snacks/rationpack/manufactured)
