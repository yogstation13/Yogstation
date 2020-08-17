/obj/machinery/portable_atmospherics/canister/fusion_test	
	name = "Fusion Test Canister"	
	desc = "This should never be spawned in game."	
	icon_state = "green"	
/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()	
	air_contents.set_moles(/datum/gas/tritium, 10)
	air_contents.set_moles(/datum/gas/plasma, 500)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 500)
	air_contents.set_moles(/datum/gas/nitrous_oxide, 100)
	air_contents.set_temperature(9999)

 /obj/machinery/portable_atmospherics/canister/fusion_test_2	
	name = "Fusion Test Canister"	
	desc = "This should never be spawned in game."	
	icon_state = "green"	
/obj/machinery/portable_atmospherics/canister/fusion_test_2/create_gas()	
	air_contents.set_moles(/datum/gas/tritium, 10)
	air_contents.set_moles(/datum/gas/plasma, 15000)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 1500)
	air_contents.set_moles(/datum/gas/nitrous_oxide, 100)
	air_contents.set_temperature(9999)
