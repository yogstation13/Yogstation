#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.return_volume())/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature()))

/obj/machinery/atmospherics/components/unary/tank
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	icon = 'icons/obj/atmospherics/pressure_tank.dmi'
	icon_state = "base"

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPING_ONE_PER_TURF

	greyscale_config = /datum/greyscale_config/pressure_tank
	greyscale_colors = "#ffffff"

	var/volume = 10000 //in liters
	var/gas_type = 0

/obj/machinery/atmospherics/components/unary/tank/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_volume(volume)
	air_contents.set_temperature(T20C)
	if(gas_type)
		air_contents.set_moles(gas_type, AIR_CONTENTS)
		name = "[name] ([GLOB.gas_data.names[gas_type]])" // Automatically names them after gas type
	set_piping_layer(piping_layer)

/obj/machinery/atmospherics/components/unary/tank/air
	name = "pressure tank (Air)"
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/atmospherics/components/unary/tank/air/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS * 0.2)
	air_contents.set_moles(GAS_N2, AIR_CONTENTS * 0.8)

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	gas_type = GAS_CO2
	greyscale_colors = "#2f2f38"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_CO2, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/plasma
	gas_type = GAS_PLASMA
	greyscale_colors = "#f05f16"

/obj/machinery/atmospherics/components/unary/tank/plasma/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_PLASMA, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/oxygen
	gas_type = GAS_O2
	greyscale_colors = "#148df4"

/obj/machinery/atmospherics/components/unary/tank/oxygen/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	gas_type = GAS_N2
	greyscale_colors = "#2d8f44"

/obj/machinery/atmospherics/components/unary/tank/nitrogen/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_N2, AIR_CONTENTS)
