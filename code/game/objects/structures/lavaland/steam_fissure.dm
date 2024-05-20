#define STEAM_BUILDUP_RATE 0.75
#define STEAM_RELEASE_RATE 0.5

/obj/structure/steam_fissure
	name = "geothermal fissure"
	desc = "A crack in the ground where hot steam rises to the surface."
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // you can't destroy a hole in the ground

	///Gas ID spawned
	var/gas_id = GAS_H2O
	///Temperature of the released gas
	var/steam_production_temp = T0C+800
	///Maximum pressure it can get to
	var/pressure_limit = ONE_ATMOSPHERE*100
	///Internal gas mixture
	var/datum/gas_mixture/contained

/obj/structure/steam_fissure/Initialize(mapload)
	. = ..()
	contained = new()
	START_PROCESSING(SSobj, src)

/obj/structure/steam_fissure/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/steam_fissure/process(delta_time)
	var/pressure_delta = pressure_limit - contained.return_pressure()
	if(pressure_delta > 0)
		var/production = (pressure_delta * STEAM_BUILDUP_RATE) * contained.return_volume() / (R_IDEAL_GAS_EQUATION * steam_production_temp)
		var/heat_delta = (steam_production_temp - contained.return_temperature()) * (GLOB.gas_data.specific_heats[gas_id]*production) / ((GLOB.gas_data.specific_heats[gas_id]*production) + contained.heat_capacity())
		contained.adjust_moles(gas_id, production)
		contained.set_temperature(contained.return_temperature() + heat_delta)

	if(!isopenturf(loc))
		return

	var/turf/open/T = loc
	pressure_delta = contained.return_pressure() - T.air.return_pressure()
	if(pressure_delta > 0)
		T.assume_air(contained.remove_ratio(STEAM_RELEASE_RATE))
		T.air_update_turf()

#undef STEAM_BUILDUP_RATE
#undef STEAM_RELEASE_RATE
