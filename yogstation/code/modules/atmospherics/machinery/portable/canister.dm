/obj/machinery/portable_atmospherics/canister/fusion_test	
	name = "Fusion Test Canister"	
	desc = "This should never be spawned in game."	
	icon_state = "green"	
/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()	
	air_contents.add_gases(/datum/gas/tritium,/datum/gas/plasma,/datum/gas/carbon_dioxide,/datum/gas/nitrous_oxide)	
	air_contents.gases[/datum/gas/tritium][MOLES] = 10	
	air_contents.gases[/datum/gas/plasma][MOLES] = 500	
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = 500	
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = 100	
	air_contents.temperature = 9999	

 /obj/machinery/portable_atmospherics/canister/fusion_test_2	
	name = "Fusion Test Canister"	
	desc = "This should never be spawned in game."	
	icon_state = "green"	
/obj/machinery/portable_atmospherics/canister/fusion_test_2/create_gas()	
	air_contents.add_gases(/datum/gas/tritium,/datum/gas/plasma,/datum/gas/carbon_dioxide,/datum/gas/nitrous_oxide)	
	air_contents.gases[/datum/gas/tritium][MOLES] = 10	
	air_contents.gases[/datum/gas/plasma][MOLES] = 15000	
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = 1500	
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = 100	
	air_contents.temperature = 9999
