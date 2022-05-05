/obj/item/tank/internals/co2
	name = "CO2 internals tank"
	desc = "A tank of CO2 gas designed specifically for use as internals. You don't want to use it unless you breathe CO2!"
	icon_state = "plasmaman_tank"
	item_state = "plasmaman_tank"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/co2/populate_gas()
	air_contents.set_moles(/datum/gas/carbon_dioxide, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/co2/full/populate_gas()
	air_contents.set_moles(/datum/gas/carbon_dioxide, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))
