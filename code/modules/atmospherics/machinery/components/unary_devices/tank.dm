#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.return_volume())/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature()))

/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/stationary_canisters.dmi'
	icon_state = "smooth"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPING_ONE_PER_TURF

	greyscale_config = /datum/greyscale_config/stationary_canister
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
		name = "[name] ([GLOB.gas_data.names[gas_type]])"
	set_piping_layer(piping_layer)

/obj/machinery/atmospherics/components/unary/tank/air
	greyscale_colors = "#c6c0b5"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/unary/tank/air/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS * 0.2)
	air_contents.set_moles(GAS_N2, AIR_CONTENTS * 0.8)

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	gas_type = GAS_CO2

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_CO2, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/toxins
	greyscale_colors = "#f62800"
	gas_type = GAS_PLASMA

/obj/machinery/atmospherics/components/unary/tank/toxins/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_PLASMA, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/oxygen
	greyscale_colors = "#2786E5"
	gas_type = GAS_O2

/obj/machinery/atmospherics/components/unary/tank/oxygen/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	greyscale_colors = "#d41010"
	gas_type = GAS_N2

/obj/machinery/atmospherics/components/unary/tank/nitrogen/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_N2, AIR_CONTENTS)
