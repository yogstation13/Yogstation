/// Canister 1 Kelvin below the fusion point. Is highly unoptimal, do not spawn to start fusion, only good for testing low instability mixes.
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

/// Canister 1 Kelvin below the fusion point. Contains far too much plasma. Only good for adding more fuel to ongoing fusion reactions.
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

/// Canister at the perfect conditions to start and continue fusion for a long time.
/obj/machinery/portable_atmospherics/canister/fusion_test_3
	name = "Fusion Test Canister"	
	desc = "This should never be spawned in game."	
	icon_state = "green"	
/obj/machinery/portable_atmospherics/canister/fusion_test_3/create_gas()	
	air_contents.set_moles(/datum/gas/tritium, 1000)
	air_contents.set_moles(/datum/gas/plasma, 4500)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 1500)
	air_contents.set_temperature(1000000)

/** Canister for testing dilithium based cold fusion. Use fusion_test_3 if you don't know what you are doing.
 This canister is significantly harder to fix if shit goes wrong.*/
/obj/machinery/portable_atmospherics/canister/fusion_test_4
	name = "Cold Fusion Test Canister"	
	desc = "This should never be spawned in game. Contains dilithium for cold fusion."	
	icon_state = "green"	
/obj/machinery/portable_atmospherics/canister/fusion_test_4/create_gas()	
	air_contents.set_moles(/datum/gas/tritium, 1000)
	air_contents.set_moles(/datum/gas/plasma, 4500)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 1500)
	air_contents.set_moles(/datum/gas/dilithium, 2000)
	air_contents.set_temperature(10000)
  
///A canister that is 1 Kelvin away from doing the stimball reaction.
/obj/machinery/portable_atmospherics/canister/stimball_test
	name = "Stimball Test Canister"
	desc = "This should never be spawned in game except for testing purposes."

/obj/machinery/portable_atmospherics/canister/stimball_test/create_gas()
	air_contents.set_moles(/datum/gas/stimulum, 1000)
	air_contents.set_moles(/datum/gas/plasma, 1000)
	air_contents.set_moles(/datum/gas/pluoxium, 1000)
	air_contents.set_temperature(FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1)