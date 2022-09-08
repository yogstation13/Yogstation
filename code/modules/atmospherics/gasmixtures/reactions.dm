//All defines used in reactions are located in ..\__DEFINES\reactions.dm
//priority so far, check this list to see what are the numbers used.
//Please use a different priority for each reaction(higher number are done first) 
//or else auxmos will ignore the reaction
//NOTE: ONLY INTEGERS ARE ALLOWED, EXPECT WEIRDNESS IF YOU DON'T FOLLOW THIS
#define MIASTER 				-10
#define FREONFIRE 				-5
#define PLASMAFIRE				-4
#define H2FIRE 					-3
#define TRITFIRE 				-2
#define HALONO2REMOVAL 			-1
#define NITROUSDECOMP 			0
#define WATERVAPOR 				1
#define FUSION 					2
#define COLDFUSION 				3
#define NITRYLFORMATION 		4
#define BZFORMATION 			5
#define FREONFORMATION 			6
#define STIMFORMATION 			7
#define STIMBALL 				8
#define ZAUKERDECOMP 			9
#define HEALIUMFORMATION 		10
#define PLUONIUMFORMATION 		11
#define ZAUKERFORMATION 		12
#define HALONFORMATION 			13
#define HEXANEFORMATION 		14
#define PLUONIUMBZRESPONSE 		15
#define PLUONIUMTRITRESPONSE 	16
#define PLUONIUMH2RESPONSE 		17
#define METALHYDROGEN 			18
#define NOBLIUMSUPPRESSION	 	1000
#define NOBLIUMFORMATION 		1001

/proc/init_gas_reactions()
	. = list()

	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(initial(reaction.exclude))
			continue
		reaction = new r
		. += reaction

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_MOLE_COUNT.
	var/list/min_requirements
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = -1000 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

//fires cannot use this proc, because you don't want fires in pipes to proc fire_act on random turfs above the pipe
/proc/get_holder_turf(datum/holder)
	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	return location

/datum/gas_reaction/nobliumsupression
	priority = NOBLIUMSUPPRESSION //ensure all non-HN reactions are lower than this number.
	name = "Hyper-Noblium Reaction Suppression"
	id = "nobstop"

/datum/gas_reaction/nobliumsupression/init_reqs()
	min_requirements = list(GAS_HYPERNOB = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = WATERVAPOR
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list(
		GAS_H2O = MOLES_GAS_VISIBLE, 
	)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.return_temperature() <= WATER_VAPOR_FREEZE)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.adjust_moles(GAS_H2O, -MOLES_GAS_VISIBLE)
		. = REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority = TRITFIRE //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		GAS_TRITIUM = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/initial_thermal_energy = air.thermal_energy()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	var/initial_trit = air.get_moles(GAS_TRITIUM)
	var/initial_o2 = air.get_moles(GAS_O2)
	if(initial_o2 < initial_trit || MINIMUM_TRIT_OXYBURN_ENERGY > initial_thermal_energy)
		burned_fuel = initial_o2 / TRITIUM_BURN_OXY_FACTOR
		air.adjust_moles(GAS_TRITIUM, -burned_fuel)
	else
		burned_fuel = initial_trit
		air.adjust_moles(GAS_TRITIUM, -initial_trit / TRITIUM_BURN_TRIT_FACTOR) 
		air.adjust_moles(GAS_O2, -initial_trit)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel * (TRITIUM_BURN_TRIT_FACTOR - 1)) 

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

		//oxygen+more-or-less hydrogen=H2O
		air.adjust_moles(GAS_H2O, burned_fuel)

		cached_results["fire"] += burned_fuel

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((initial_thermal_energy + energy_released)/new_heat_capacity)

	//let the floor know a fire is happening
	if(istype(location))
		var/temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority = PLASMAFIRE //fire should ALWAYS be last, but plasma fires happen after tritium fires
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		GAS_PLASMA = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null

	//Handle plasma burning
	var/plasma_burn_rate = 0
	var/oxygen_burn_rate = 0
	//more plasma released at higher temperatures
	var/temperature_scale = 0
	//to make tritium
	var/super_saturation = FALSE

	var/initial_o2 = air.get_moles(GAS_O2)
	var/initial_plas = air.get_moles(GAS_PLASMA)

	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(initial_o2 / initial_plas > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(initial_o2 > initial_plas * PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (initial_plas*temperature_scale)/PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale*(initial_o2/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate,initial_plas,initial_o2/oxygen_burn_rate) //Ensures matter is conserved properly
			air.adjust_moles(GAS_PLASMA, -plasma_burn_rate)
			air.adjust_moles(GAS_O2, -(plasma_burn_rate * oxygen_burn_rate))
			if (super_saturation)
				air.adjust_moles(GAS_TRITIUM, plasma_burn_rate)
			else
				air.adjust_moles(GAS_CO2, plasma_burn_rate)

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((old_thermal_energy + energy_released)/new_heat_capacity)

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

/datum/gas_reaction/n2odecomp
	priority = NITROUSDECOMP
	name = "Nitrous Oxide Decomposition"
	id = "n2odecomp"

/datum/gas_reaction/n2odecomp/init_reqs()
	min_requirements = list(
		"TEMP" = N2O_DECOMPOSITION_MIN_HEAT,
		GAS_NITROUS = MINIMUM_MOLE_COUNT*2
	)

/datum/gas_reaction/n2odecomp/react(datum/gas_mixture/air, datum/holder)
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/nitrous = air.get_moles(GAS_NITROUS)

	var/burned_fuel = min(N2O_DECOMPOSITION_RATE*nitrous*temperature*(temperature-N2O_DECOMPOSITION_MAX_HEAT)/((-1/4)*(N2O_DECOMPOSITION_MAX_HEAT**2)), nitrous)
	if(burned_fuel>0)
		air.set_moles(GAS_NITROUS, QUANTIZE(nitrous - burned_fuel))
		air.set_moles(GAS_N2, QUANTIZE(air.get_moles(GAS_N2) + burned_fuel))
		air.set_moles(GAS_O2, QUANTIZE(air.get_moles(GAS_O2) + burned_fuel/2))
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + burned_fuel*N2O_DECOMPOSITION_ENERGY)/new_heat_capacity)
		return REACTING

	return NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

/datum/gas_reaction/cold_fusion
	exclude = FALSE
	priority = COLDFUSION
	name = "Cold Plasmic Fusion"
	id = "coldfusion"

/datum/gas_reaction/cold_fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD_MINIMUM,
		"MAX_TEMP" = FUSION_TEMPERATURE_THRESHOLD,
		GAS_DILITHIUM = MINIMUM_MOLE_COUNT,
		GAS_TRITIUM = FUSION_TRITIUM_MOLES_USED,
		GAS_PLASMA = FUSION_MOLE_THRESHOLD,
		GAS_CO2 = FUSION_MOLE_THRESHOLD)

/datum/gas_reaction/cold_fusion/react(datum/gas_mixture/air, datum/holder)
	if(air.return_temperature() < (FUSION_TEMPERATURE_THRESHOLD - FUSION_TEMPERATURE_THRESHOLD_MINIMUM) * NUM_E**( - air.get_moles(GAS_DILITHIUM) * DILITHIUM_LAMBDA) + FUSION_TEMPERATURE_THRESHOLD_MINIMUM)
		// This is an exponential decay equation, actually. Horizontal Asymptote is FUSION_TEMPERATURE_THRESHOLD_MINIMUM.
		return NO_REACTION
	return fusion_react(air, holder, id)

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = FUSION
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD, 
		GAS_TRITIUM = FUSION_TRITIUM_MOLES_USED,
		GAS_PLASMA = FUSION_MOLE_THRESHOLD,
		GAS_CO2 = FUSION_MOLE_THRESHOLD)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	return fusion_react(air, holder, id)

/proc/fusion_react(datum/gas_mixture/air, datum/holder, id)
	var/turf/open/location = get_holder_turf(holder)
	if(!location)
		return NO_REACTION
	if(!air.analyzer_results)
		air.analyzer_results = new
	var/list/cached_scan_results = air.analyzer_results
	var/old_thermal_energy = air.thermal_energy()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = air.get_moles(GAS_PLASMA)
	var/initial_carbon = air.get_moles(GAS_CO2)
	var/scale_factor = (air.return_volume())/(PI) //We scale it down by volume/Pi because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/toroidal_size = (2*PI)+TORADIANS(arctan((air.return_volume()-TOROID_VOLUME_BREAKEVEN)/TOROID_VOLUME_BREAKEVEN)) //The size of the phase space hypertorus
	var/gas_power = 0
	for (var/gas_id in air.get_gases())
		gas_power += (GLOB.gas_data.fusion_powers[gas_id]*air.get_moles(gas_id))
	var/instability = MODULUS((gas_power*INSTABILITY_GAS_POWER_FACTOR)**2,toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results[id] = instability//used for analyzer feedback

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)


	air.set_moles(GAS_PLASMA, plasma*scale_factor + FUSION_MOLE_THRESHOLD )//Scales the gases back up
	air.set_moles(GAS_CO2, carbon*scale_factor + FUSION_MOLE_THRESHOLD)
	var/delta_plasma = initial_plasma - air.get_moles(GAS_PLASMA)

	reaction_energy += delta_plasma*PLASMA_BINDING_ENERGY //Energy is gained or lost corresponding to the creation or destruction of mass.
	if(instability < FUSION_INSTABILITY_ENDOTHERMALITY)
		reaction_energy = max(reaction_energy,0) //Stable reactions don't end up endothermic.
	else if (reaction_energy < 0)
		reaction_energy *= (instability-FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	if(air.thermal_energy() + reaction_energy < 0) //No using energy that doesn't exist.
		air.set_moles(GAS_PLASMA, initial_plasma)
		air.set_moles(GAS_CO2, initial_carbon)
		return NO_REACTION
	air.adjust_moles(GAS_TRITIUM, -FUSION_TRITIUM_MOLES_USED)
	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	if(reaction_energy > 0)
		air.adjust_moles(GAS_O2, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(GAS_NITROUS, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
	else
		air.adjust_moles(GAS_BZ, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(GAS_NITRYL, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))

	if(reaction_energy)
		if(location)
			var/particle_chance = ((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
			if(prob(PERCENT(particle_chance)))
				location.fire_nuclear_particle()
			var/rad_power = max((FUSION_RAD_COEFFICIENT/instability) + FUSION_RAD_MAX,0)
			radiation_pulse(location,rad_power)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp(((old_thermal_energy + reaction_energy)/new_heat_capacity),TCMB,INFINITY))
		return REACTING

/datum/gas_reaction/nitrylformation //The formation of nitryl. Endothermic. Requires N2O as a catalyst.
	priority = NITRYLFORMATION
	name = "Nitryl formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	min_requirements = list(
		GAS_O2 = 20,
		GAS_N2 = 20,
		GAS_NITROUS = 5,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*30
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()

	var/initial_o2 = air.get_moles(GAS_O2)
	var/initial_n2 = air.get_moles(GAS_N2)

	var/old_thermal_energy = air.thermal_energy()
	var/heat_efficency = min(temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*60),initial_o2,initial_n2)
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	if ((initial_o2 - heat_efficency < 0 ) || (initial_n2 - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_O2, -heat_efficency)
	air.adjust_moles(GAS_N2, -heat_efficency)
	air.adjust_moles(GAS_NITRYL, heat_efficency*2)

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy - energy_used)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = BZFORMATION
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		GAS_NITROUS = 10,
		GAS_PLASMA = 10
	)

/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/pressure = air.return_pressure()
	var/old_thermal_energy = air.thermal_energy()

	var/initial_plas = air.get_moles(GAS_PLASMA)
	var/initial_nitrous = air.get_moles(GAS_NITROUS)

	var/reaction_efficency = min(1/((clamp(pressure,1,1000)/(0.5*ONE_ATMOSPHERE))*(max(initial_plas/initial_nitrous,1))),initial_nitrous,initial_plas/2)
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED
	if ((initial_nitrous - reaction_efficency < 0 )|| (initial_plas - (2*reaction_efficency) < 0) || energy_released <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_BZ, reaction_efficency)
	if(reaction_efficency == initial_nitrous)
		air.adjust_moles(GAS_BZ, -min(pressure,1))
		air.adjust_moles(GAS_O2, min(pressure,1))
	air.adjust_moles(GAS_NITROUS, -reaction_efficency)
	air.adjust_moles(GAS_PLASMA, -2*reaction_efficency)

	//clamps by a minimum amount in the event of an underflow.
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp((reaction_efficency**2)*BZ_RESEARCH_AMOUNT,0.01,BZ_RESEARCH_MAX_AMOUNT))

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy + energy_released)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority = STIMFORMATION
	name = "Stimulum formation"
	id = "stimformation"

/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		GAS_PLASMA = 10,
		GAS_BZ = 20,
		GAS_NITRYL = 30,
		"TEMP" = STIMULUM_HEAT_SCALE/2)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)

	var/old_thermal_energy = air.thermal_energy()
	var/initial_plas = air.get_moles(GAS_PLASMA)
	var/initial_nitryl = air.get_moles(GAS_NITRYL)
	var/heat_scale = min(air.return_temperature()/STIMULUM_HEAT_SCALE,initial_plas,initial_nitryl)
	var/stim_energy_change = heat_scale*STIMULUM_HEAT_SCALE

	if ((initial_plas - heat_scale < 0) || (initial_nitryl - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_STIMULUM, heat_scale/10)
	air.adjust_moles(GAS_PLASMA, -heat_scale)
	air.adjust_moles(GAS_NITRYL, -heat_scale)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp(STIMULUM_RESEARCH_AMOUNT*heat_scale/10,0.01, STIMULUM_RESEARCH_MAX_AMOUNT))
	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy + stim_energy_change)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority = NOBLIUMFORMATION //Ensure this value is higher than nobstop
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	min_requirements = list(
		GAS_N2 = 20,
		GAS_TRITIUM = 10,
		"TEMP" = 5000000)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/initial_trit = air.get_moles(GAS_TRITIUM)
	var/initial_n2 = air.get_moles(GAS_N2)
	var/initial_bz = air.get_moles(GAS_BZ)

	var/nob_formed = min(initial_trit/10,initial_n2/20)
	var/old_thermal_energy = air.thermal_energy()

	var/energy_taken = nob_formed*(NOBLIUM_FORMATION_ENERGY/(max(initial_bz,1)))
	air.adjust_moles(GAS_TRITIUM, -10*nob_formed)
	air.adjust_moles(GAS_N2, -20*nob_formed)
	air.adjust_moles(GAS_HYPERNOB, nob_formed)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp(nob_formed*NOBLIUM_RESEARCH_AMOUNT, 0.01, NOBLIUM_RESEARCH_MAX_AMOUNT))
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.set_temperature(max(((old_thermal_energy - energy_taken)/new_heat_capacity),TCMB))
		return REACTING


/datum/gas_reaction/miaster	//dry heat sterilization: clears out pathogens in the air
	priority = MIASTER //after all the heating from fires etc. is done
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST+70,
		GAS_MIASMA = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	// As the name says it, it needs to be dry
	if(air.get_moles(GAS_H2O)/air.total_moles() > 0.1) // Yogs --Fixes runtime in Sterilization
		return NO_REACT

	//Replace miasma with oxygen
	var/cleaned_air = min(air.get_moles(GAS_MIASMA), 20 + (air.return_temperature() - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	air.adjust_moles(GAS_MIASMA, -cleaned_air)
	air.adjust_moles(GAS_O2, cleaned_air)

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.set_temperature(air.return_temperature() + cleaned_air * 0.002)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp(cleaned_air*MIASMA_RESEARCH_AMOUNT,0.01, MIASMA_RESEARCH_MAX_AMOUNT))//Turns out the burning of miasma is kinda interesting to scientists
	return REACTING

/datum/gas_reaction/stim_ball
	priority = STIMBALL
	name ="Stimulum Energy Ball"
	id = "stimball"

/datum/gas_reaction/stim_ball/init_reqs()
	min_requirements = list(
		GAS_PLUOXIUM = STIM_BALL_MOLES_REQUIRED,
		GAS_STIMULUM = STIM_BALL_MOLES_REQUIRED,
		GAS_PLASMA = STIM_BALL_MOLES_REQUIRED,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/// Reaction that burns stimulum and plouxium into radballs and partial constituent gases, but also catalyzes the combustion of plasma.
/datum/gas_reaction/stim_ball/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = get_holder_turf(holder)
	if(!location)
		return NO_REACTION
	var/old_thermal_energy = air.thermal_energy()
	var/initial_pluox = air.get_moles(GAS_PLUOXIUM)
	var/initial_plas = air.get_moles(GAS_PLASMA)
	var/initial_stim = air.get_moles(GAS_STIMULUM)
	var/reaction_rate = min(STIM_BALL_MAX_REACT_RATE, initial_plas, initial_pluox, initial_stim)
	var/balls_shot = round(reaction_rate/STIM_BALL_MOLES_REQUIRED)
	//A percentage of plasma is burned during the reaction that is converted into energy and radballs, though mostly pure heat. 
	var/plasma_burned = QUANTIZE((initial_plas + 5*reaction_rate)*STIM_BALL_PLASMA_COEFFICIENT)
	//Stimulum has a lot of stored energy, and breaking it up releases some of it. Plasma is also partially converted into energy in the process.
	var/energy_released = (reaction_rate*STIMULUM_HEAT_SCALE) + (plasma_burned*STIM_BALL_PLASMA_ENERGY)
	air.adjust_moles(GAS_STIMULUM, -reaction_rate)
	air.adjust_moles(GAS_PLUOXIUM, -reaction_rate)
	air.adjust_moles(GAS_NITRYL, reaction_rate*5)
	air.adjust_moles(GAS_PLASMA, -plasma_burned)
	if(balls_shot)
		var/angular_increment = 360/balls_shot
		var/random_starting_angle = rand(0,360)
		for(var/i in 1 to balls_shot)
			location.fire_nuclear_particle((i*angular_increment+random_starting_angle))
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp((old_thermal_energy + energy_released)/new_heat_capacity,TCMB,INFINITY))
		return REACTING

//freon reaction (is not a fire yet)
/datum/gas_reaction/freonfire
	priority = FREONFIRE
	name = "Freon combustion"
	id = "freonfire"

/datum/gas_reaction/freonfire/init_reqs()
	min_requirements = list(
		GAS_O2 = MINIMUM_MOLE_COUNT,
		GAS_FREON = MINIMUM_MOLE_COUNT,
		"TEMP" = FREON_LOWER_TEMPERATURE,
		"MAX_TEMP" = FREON_MAXIMUM_BURN_TEMPERATURE
		)

/datum/gas_reaction/freonfire/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = get_holder_turf(holder)
	if(!location)
		return NO_REACTION
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
	var/temperature = air.return_temperature()
	var/initial_o2 = air.get_moles(GAS_O2)
	var/initial_freon = air.get_moles(GAS_FREON)

	//Handle freon burning (only reaction now)
	var/freon_burn_rate = 0
	var/oxygen_burn_rate = 0
	//more freon released at lower temperatures
	var/temperature_scale = 1

	if(temperature < FREON_LOWER_TEMPERATURE) //stop the reaction when too cold
		temperature_scale = 0
	else
		temperature_scale = (FREON_MAXIMUM_BURN_TEMPERATURE - temperature) / (FREON_MAXIMUM_BURN_TEMPERATURE - FREON_LOWER_TEMPERATURE) //calculate the scale based on the temperature
	if(temperature_scale >= 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(initial_o2 > initial_freon * FREON_OXYGEN_FULLBURN)
			freon_burn_rate = (initial_freon * temperature_scale) / FREON_BURN_RATE_DELTA
		else
			freon_burn_rate = (temperature_scale * (initial_o2 / FREON_OXYGEN_FULLBURN)) / FREON_BURN_RATE_DELTA

		if(freon_burn_rate > MINIMUM_HEAT_CAPACITY)
			freon_burn_rate = min(freon_burn_rate, initial_freon, initial_o2 / oxygen_burn_rate) //Ensures matter is conserved properly
			air.adjust_moles(GAS_FREON, -freon_burn_rate)
			air.adjust_moles(GAS_O2, -(freon_burn_rate * oxygen_burn_rate))
			air.adjust_moles(GAS_CO2, freon_burn_rate)

			if(temperature < 160 && temperature > 120 && prob(2))
				new /obj/item/stack/sheet/hot_ice(location)

			energy_released += FIRE_FREON_ENERGY_RELEASED * (freon_burn_rate)

	if(energy_released < 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((old_thermal_energy + energy_released) / new_heat_capacity)

/datum/gas_reaction/h2fire
	priority = H2FIRE //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Hydrogen Combustion"
	id = "h2fire"

/datum/gas_reaction/h2fire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		GAS_H2 = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/h2fire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
 //this speeds things up because accessing datum vars is slow
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	var/initial_o2 = air.get_moles(GAS_O2)
	var/initial_h2 = air.get_moles(GAS_H2)
	if(initial_o2 < initial_h2 || MINIMUM_H2_OXYBURN_ENERGY > old_thermal_energy)
		burned_fuel = (initial_o2/HYDROGEN_BURN_OXY_FACTOR)
		air.adjust_moles(GAS_H2, -burned_fuel)
	else
		burned_fuel = (initial_h2 * HYDROGEN_BURN_H2_FACTOR)
		air.adjust_moles(GAS_H2, -(initial_h2 / HYDROGEN_BURN_H2_FACTOR))
		air.adjust_moles(GAS_O2, -initial_h2)

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		air.adjust_moles(GAS_H2O, (burned_fuel / HYDROGEN_BURN_OXY_FACTOR))

		cached_results["fire"] += burned_fuel

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((old_thermal_energy + energy_released) / new_heat_capacity)

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION
	
	
/datum/gas_reaction/hexane_formation
	priority = HEXANEFORMATION
	name = "Hexane formation"
	id = "hexane_formation"

/datum/gas_reaction/hexane_formation/init_reqs()
	min_requirements = list(
		GAS_BZ = MINIMUM_MOLE_COUNT,
		GAS_H2 = MINIMUM_MOLE_COUNT,
		"TEMP" = 450,
		"MAX_TEMP" = 465
	)

/datum/gas_reaction/hexane_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_h2 = air.get_moles(GAS_H2)
	var/initial_bz = air.get_moles(GAS_BZ)
	var/heat_efficency = min(temperature * 0.01, initial_h2, initial_bz)
	var/energy_used = heat_efficency * 600
	if (initial_h2 - (heat_efficency * 5) < 0  || initial_bz - (heat_efficency * 0.25) < 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_H2, -(heat_efficency * 5))
	air.adjust_moles(GAS_BZ, -(heat_efficency * 0.25))
	air.adjust_moles(GAS_HEXANE, (heat_efficency * 5.25))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy - energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/metalhydrogen
	priority = METALHYDROGEN
	name = "Metal Hydrogen formation"
	id = "metalhydrogen"

/datum/gas_reaction/metalhydrogen/init_reqs()
	min_requirements = list(
		GAS_H2 = 1000,
		GAS_BZ = 50,
		"TEMP" = METAL_HYDROGEN_MINIMUM_HEAT
		)

/datum/gas_reaction/metalhydrogen/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = get_holder_turf(holder)
	if(!location)
		return NO_REACTION
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	///the more heat you use the higher is this factor
	var/increase_factor = min(log(10, (temperature / METAL_HYDROGEN_MINIMUM_HEAT)), 5)
	///the more moles you use and the higher the heat, the higher is the efficiency
	var/heat_efficency = air.get_moles(GAS_H2)* 0.01 * increase_factor
	var/pressure = air.return_pressure()
	var/energy_used = heat_efficency * METAL_HYDROGEN_FORMATION_ENERGY

	if(pressure >= METAL_HYDROGEN_MINIMUM_PRESSURE && temperature >= METAL_HYDROGEN_MINIMUM_HEAT)
		air.adjust_moles(GAS_BZ, -(heat_efficency * 0.05))
		if (prob(20 * increase_factor))
			air.adjust_moles(GAS_H2, -(heat_efficency * 14))
			if (prob(25 / increase_factor))
				new /obj/item/stack/sheet/mineral/metal_hydrogen(location)
				SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min((heat_efficency * increase_factor * 0.5), METAL_HYDROGEN_RESEARCH_MAX_AMOUNT))

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy - energy_used) / new_heat_capacity), TCMB))
		return REACTING

/datum/gas_reaction/freonformation
	priority = FREONFORMATION
	name = "Freon formation"
	id = "freonformation"

/datum/gas_reaction/freonformation/init_reqs() //minimum requirements for freon formation
	min_requirements = list(
		GAS_PLASMA = 40,
		GAS_CO2 = 20,
		GAS_BZ = 20,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100
		)

/datum/gas_reaction/freonformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_plas = air.get_moles(GAS_PLASMA)
	var/initial_co2 = air.get_moles(GAS_CO2) 
	var/initial_bz = air.get_moles(GAS_BZ)
	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), initial_plas, initial_co2, initial_bz)
	var/energy_used = heat_efficency * 100
	if ((initial_plas - heat_efficency * 1.5 < 0 ) || (initial_co2 - heat_efficency * 0.75 < 0) || (initial_bz - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_PLASMA, -(heat_efficency * 1.5))
	air.adjust_moles(GAS_CO2, -(heat_efficency * 0.75))
	air.adjust_moles(GAS_BZ, -(heat_efficency * 0.25))
	air.adjust_moles(GAS_FREON, (heat_efficency * 2.5))

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy - energy_used)/new_heat_capacity), TCMB))
		return REACTING

/datum/gas_reaction/halon_formation
	priority = HALONFORMATION
	name = "Halon formation"
	id = "halon_formation"

/datum/gas_reaction/halon_formation/init_reqs()
	min_requirements = list(
		GAS_BZ = MINIMUM_MOLE_COUNT,
		GAS_TRITIUM = MINIMUM_MOLE_COUNT,
		"TEMP" = 30,
		"MAX_TEMP" = 55
	)

/datum/gas_reaction/halon_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_bz = air.get_moles(GAS_BZ)
	var/initial_trit = air.get_moles(GAS_TRITIUM)
	var/heat_efficency = min(temperature * 0.01, initial_trit, initial_bz)
	var/energy_used = heat_efficency * 300
	if ((initial_trit - heat_efficency * 4 < 0 ) || (initial_bz - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_TRITIUM, -(heat_efficency * 4))
	air.adjust_moles(GAS_BZ, -(heat_efficency * 0.25))
	air.adjust_moles(GAS_HALON, (heat_efficency * 4.25))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy + energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/healium_formation
	priority = HEALIUMFORMATION
	name = "Healium formation"
	id = "healium_formation"

/datum/gas_reaction/healium_formation/init_reqs()
	min_requirements = list(
		GAS_BZ = MINIMUM_MOLE_COUNT,
		GAS_FREON = MINIMUM_MOLE_COUNT,
		"TEMP" = 25,
		"MAX_TEMP" = 300
	)

/datum/gas_reaction/healium_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_freon = air.get_moles(GAS_FREON)
	var/initial_bz = air.get_moles(GAS_BZ)
	var/heat_efficency = min(temperature * 0.3, initial_freon, initial_bz)
	var/energy_used = heat_efficency * 9000
	if ((initial_freon - heat_efficency * 2.75 < 0 ) || (initial_bz - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_FREON, -(heat_efficency * 2.75))
	air.adjust_moles(GAS_BZ, -(heat_efficency * 0.25))
	air.adjust_moles(GAS_HEALIUM, (heat_efficency * 3))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy + energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/pluonium_formation
	priority = PLUONIUMFORMATION
	name = "Pluonium formation"
	id = "pluonium_formation"

/datum/gas_reaction/pluonium_formation/init_reqs()
	min_requirements = list(
		GAS_PLUOXIUM = MINIMUM_MOLE_COUNT,
		GAS_H2 = MINIMUM_MOLE_COUNT,
		"TEMP" = 5000,
		"MAX_TEMP" = 10000
	)

/datum/gas_reaction/pluonium_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_pluox = air.get_moles(GAS_PLUOXIUM)
	var/initial_h2 = air.get_moles(GAS_H2)
	var/heat_efficency = min(temperature * 0.005, initial_pluox, initial_h2)
	var/energy_used = heat_efficency * 650
	if ((initial_pluox - heat_efficency * 0.2 < 0 ) || (initial_h2 - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_H2, -(heat_efficency * 2))
	air.adjust_moles(GAS_PLUOXIUM, -(heat_efficency * 0.2))
	air.adjust_moles(GAS_PLUONIUM, (heat_efficency * 2.2))

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy + energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/zauker_formation
	priority = ZAUKERFORMATION
	name = "Zauker formation"
	id = "zauker_formation"

/datum/gas_reaction/zauker_formation/init_reqs()
	min_requirements = list(
		GAS_HYPERNOB = MINIMUM_MOLE_COUNT,
		GAS_STIMULUM = MINIMUM_MOLE_COUNT,
		"TEMP" = 50000,
		"MAX_TEMP" = 75000
	)

/datum/gas_reaction/zauker_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_nob = air.get_moles(GAS_HYPERNOB)
	var/initial_stim = air.get_moles(GAS_STIMULUM)
	var/heat_efficency = min(temperature * 0.000005, initial_nob, initial_stim)
	var/energy_used = heat_efficency * 5000
	if ((initial_nob - heat_efficency * 0.01 < 0 ) || (initial_stim - heat_efficency * 0.5 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_HYPERNOB, -(heat_efficency * 0.01))
	air.adjust_moles(GAS_STIMULUM, -(heat_efficency * 0.5))
	air.adjust_moles(GAS_ZAUKER, (heat_efficency * 0.5))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy - energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/halon_o2removal
	priority = HALONO2REMOVAL
	name = "Halon o2 removal"
	id = "halon_o2removal"

/datum/gas_reaction/halon_o2removal/init_reqs()
	min_requirements = list(
		GAS_HALON = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/halon_o2removal/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_thermal_energy = air.thermal_energy()
	var/initial_o2 = air.get_moles(GAS_O2)
	var/initial_halon = air.get_moles(GAS_HALON)
	var/heat_efficency = min(temperature / ( FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), initial_halon, initial_o2)
	var/energy_used = heat_efficency * 2500
	if ((initial_halon - heat_efficency < 0 ) || (initial_o2 - heat_efficency * 20 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_HALON, -(heat_efficency))
	air.adjust_moles(GAS_O2, -(heat_efficency * 20))
	air.adjust_moles(GAS_CO2, (heat_efficency * 5))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((old_thermal_energy - energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/zauker_decomp
	priority = ZAUKERDECOMP
	name = "Zauker decomposition"
	id = "zauker_decomp"

/datum/gas_reaction/zauker_decomp/init_reqs()
	min_requirements = list(
		GAS_N2 = MINIMUM_MOLE_COUNT,
		GAS_ZAUKER = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/zauker_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
	var/initial_zauker = air.get_moles(GAS_ZAUKER)
	var/burned_fuel = min(20, air.get_moles(GAS_N2), initial_zauker)
	if(initial_zauker - burned_fuel < 0)
		return NO_REACTION
	air.adjust_moles(GAS_ZAUKER, -burned_fuel)

	if(burned_fuel)
		energy_released += (460 * burned_fuel)
		air.adjust_moles(GAS_O2, (burned_fuel * 0.3))
		air.adjust_moles(GAS_N2, (burned_fuel * 0.7))

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((old_thermal_energy + energy_released) / new_heat_capacity, TCMB))
		return REACTING
	return NO_REACTION

/datum/gas_reaction/pluonium_bz_response
	priority = PLUONIUMBZRESPONSE
	name = "Pluonium bz response"
	id = "pluonium_bz_response"

/datum/gas_reaction/pluonium_bz_response/init_reqs()
	min_requirements = list(
		GAS_PLUONIUM = MINIMUM_MOLE_COUNT,
		GAS_BZ = MINIMUM_MOLE_COUNT,
		"TEMP" = 260,
		"MAX_TEMP" = 280
	)

/datum/gas_reaction/pluonium_bz_response/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = get_holder_turf(holder)
	if(!location)
		return NO_REACTION
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
	var/initial_bz = air.get_moles(GAS_BZ)
	var/initial_pluon = air.get_moles(GAS_PLUONIUM)
	var/consumed_amount = min(5, initial_bz, initial_pluon)
	if(initial_bz - consumed_amount < 0)
		return NO_REACTION
	if(initial_bz < 30)
		radiation_pulse(location, consumed_amount * 20, 2.5, TRUE, FALSE)
		air.adjust_moles(GAS_BZ, -consumed_amount)
	else
		for(var/mob/living/carbon/L in location)
			L.hallucination += (air.get_moles(GAS_BZ * 0.7))
	energy_released += 100
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((old_thermal_energy + energy_released) / new_heat_capacity, TCMB))
	return REACTING

/datum/gas_reaction/pluonium_tritium_response
	priority = PLUONIUMTRITRESPONSE
	name = "Pluonium tritium response"
	id = "pluonium_tritium_response"

/datum/gas_reaction/pluonium_tritium_response/init_reqs()
	min_requirements = list(
		GAS_PLUONIUM = MINIMUM_MOLE_COUNT,
		GAS_TRITIUM = MINIMUM_MOLE_COUNT,
		"TEMP" = 150,
		"MAX_TEMP" = 340
	)

/datum/gas_reaction/pluonium_tritium_response/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = get_holder_turf(holder)
	if(!location)
		return NO_REACTION
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
	var/initial_pluon = air.get_moles(GAS_PLUONIUM)
	var/initial_trit = air.get_moles(GAS_TRITIUM)
	var/produced_amount = min(5, initial_trit, initial_pluon)
	if(initial_trit - produced_amount < 0 || initial_pluon - produced_amount * 0.01 < 0)
		return NO_REACTION
	location.rad_act(produced_amount * 2.4)
	air.adjust_moles(GAS_TRITIUM, -produced_amount)
	air.adjust_moles(GAS_H2, produced_amount)
	air.adjust_moles(GAS_PLUONIUM, -(produced_amount * 0.01))
	energy_released += 50
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((old_thermal_energy + energy_released) / new_heat_capacity, TCMB))
	return REACTING

/datum/gas_reaction/pluonium_hydrogen_response
	priority = PLUONIUMH2RESPONSE
	name = "Pluonium hydrogen response"
	id = "pluonium_hydrogen_response"

/datum/gas_reaction/pluonium_hydrogen_response/init_reqs()
	min_requirements = list(
		GAS_PLUONIUM = MINIMUM_MOLE_COUNT,
		GAS_H2 = 150,
	)

/datum/gas_reaction/pluonium_hydrogen_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_thermal_energy = air.thermal_energy()
	var/initial_h2 = air.get_moles(GAS_H2)
	var/initial_pluon = air.get_moles(GAS_PLUONIUM)
	var/produced_amount = min(5, initial_h2, initial_pluon)
	if(initial_h2 - produced_amount < 0)
		return NO_REACTION
	air.adjust_moles(GAS_H2, -produced_amount)
	air.adjust_moles(GAS_PLUONIUM, (produced_amount * 0.5))
	energy_released = produced_amount * 2500
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((old_thermal_energy - energy_released) / new_heat_capacity, TCMB))
	return REACTING

#undef MIASTER
#undef FREONFIRE
#undef PLASMAFIRE
#undef H2FIRE
#undef TRITFIRE
#undef HALONO2REMOVAL
#undef NITROUSDECOMP
#undef WATERVAPOR
#undef FUSION
#undef COLDFUSION
#undef NITRYLFORMATION
#undef BZFORMATION
#undef FREONFORMATION
#undef STIMFORMATION
#undef STIMBALL
#undef ZAUKERDECOMP
#undef HEALIUMFORMATION
#undef PLUONIUMFORMATION
#undef ZAUKERFORMATION
#undef HALONFORMATION
#undef HEXANEFORMATION
#undef PLUONIUMBZRESPONSE
#undef PLUONIUMTRITRESPONSE
#undef PLUONIUMH2RESPONSE
#undef METALHYDROGEN
#undef NOBLIUMSUPPRESSION
#undef NOBLIUMFORMATION
