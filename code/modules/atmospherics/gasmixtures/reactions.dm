//All defines used in reactions are located in ..\__DEFINES\reactions.dm
/*priority so far, check this list to see what are the numbers used. Please use a different priority for each reaction(higher number are done first)
miaster = -10 (this should always be under all other fires)
freonfire = -5
plasmafire = -4
h2fire = -3
tritfire = -2
halon_o2removal = -1
nitrous_decomp = 0
water_vapor = 1
fusion = 2
nitrylformation = 3
bzformation = 4
freonformation = 5
stimformation = 6
stim_ball = 7
zauker_decomp = 8
healium_formation = 9
pluonium_formation = 10
zauker_formation = 11
halon_formation = 12
hexane_formation = 13
pluonium_response = 14 - 16
metalhydrogen = 17
nobliumsuppression = 1000
nobliumformation = 1001
*/

/proc/init_gas_reactions()
	. = list()
	for(var/type in subtypesof(/datum/gas))
		.[type] = list()

	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(initial(reaction.exclude))
			continue
		reaction = new r
		var/datum/gas/reaction_key
		for (var/req in reaction.min_requirements)
			if (ispath(req))
				var/datum/gas/req_gas = req
				if (!reaction_key || initial(reaction_key.rarity) > initial(req_gas.rarity))
					reaction_key = req_gas
		.[reaction_key] += list(reaction)
		sortTim(., /proc/cmp_gas_reactions, TRUE)

/proc/cmp_gas_reactions(list/datum/gas_reaction/a, list/datum/gas_reaction/b) // compares lists of reactions by the maximum priority contained within the list
	if (!length(a) || !length(b))
		return length(b) - length(a)
	var/maxa
	var/maxb
	for (var/datum/gas_reaction/R in a)
		if (R.priority > maxa)
			maxa = R.priority
	for (var/datum/gas_reaction/R in b)
		if (R.priority > maxb)
			maxb = R.priority
	return maxb - maxa

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_MOLE_COUNT.
	var/list/min_requirements
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = 100 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

/datum/gas_reaction/nobliumsupression
	priority = 1000 //ensure all non-HN reactions are lower than this number.
	name = "Hyper-Noblium Reaction Suppression"
	id = "nobstop"

/datum/gas_reaction/nobliumsupression/init_reqs()
	min_requirements = list(/datum/gas/hypernoblium = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list(/datum/gas/water_vapor = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.return_temperature() <= WATER_VAPOR_FREEZE)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.adjust_moles(/datum/gas/water_vapor, -MOLES_GAS_VISIBLE)
		. = REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority = -2 //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	var/initial_trit = air.get_moles(/datum/gas/tritium)// Yogs
	if(air.get_moles(/datum/gas/oxygen) < initial_trit || MINIMUM_TRIT_OXYBURN_ENERGY > (temperature * old_heat_capacity))// Yogs -- Maybe a tiny performance boost? I'unno
		burned_fuel = air.get_moles(/datum/gas/oxygen)/TRITIUM_BURN_OXY_FACTOR
		if(burned_fuel > initial_trit) burned_fuel = initial_trit //Yogs -- prevents negative moles of Tritium
		air.adjust_moles(/datum/gas/tritium, -burned_fuel)
	else
		burned_fuel = initial_trit // Yogs -- Conservation of Mass fix
		air.set_moles(/datum/gas/tritium, air.get_moles(/datum/gas/tritium) * (1 - 1/TRITIUM_BURN_TRIT_FACTOR)) // Yogs -- Maybe a tiny performance boost? I'unno
		air.adjust_moles(/datum/gas/oxygen, -air.get_moles(/datum/gas/tritium))
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel * (TRITIUM_BURN_TRIT_FACTOR - 1)) // Yogs -- Fixes low-energy tritium fires

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

		//oxygen+more-or-less hydrogen=H2O
		air.adjust_moles(/datum/gas/water_vapor, burned_fuel )// Yogs -- Conservation of Mass

		cached_results["fire"] += burned_fuel

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)

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

//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority = -4 //fire should ALWAYS be last, but plasma fires happen after tritium fires
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
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

	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(air.get_moles(/datum/gas/oxygen) / air.get_moles(/datum/gas/plasma) > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(air.get_moles(/datum/gas/oxygen) > air.get_moles(/datum/gas/plasma)*PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (air.get_moles(/datum/gas/plasma)*temperature_scale)/PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale*(air.get_moles(/datum/gas/oxygen)/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate,air.get_moles(/datum/gas/plasma),air.get_moles(/datum/gas/oxygen)/oxygen_burn_rate) //Ensures matter is conserved properly
			air.set_moles(/datum/gas/plasma, QUANTIZE(air.get_moles(/datum/gas/plasma) - plasma_burn_rate))
			air.set_moles(/datum/gas/oxygen, QUANTIZE(air.get_moles(/datum/gas/oxygen) - (plasma_burn_rate * oxygen_burn_rate)))
			if (super_saturation)
				air.adjust_moles(/datum/gas/tritium, plasma_burn_rate)
			else
				air.adjust_moles(/datum/gas/carbon_dioxide, plasma_burn_rate)

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)

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

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD_MINIMUM, // Yogs -- Cold Fusion
		/datum/gas/tritium = FUSION_TRITIUM_MOLES_USED,
		/datum/gas/plasma = FUSION_MOLE_THRESHOLD,
		/datum/gas/carbon_dioxide = FUSION_MOLE_THRESHOLD)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	//Yogs start -- Cold Fusion
	if(air.return_temperature() < FUSION_TEMPERATURE_THRESHOLD)
		if(!air.get_moles(/datum/gas/dilithium))
			return
		if(air.return_temperature() < (FUSION_TEMPERATURE_THRESHOLD - FUSION_TEMPERATURE_THRESHOLD_MINIMUM) * NUM_E**( - air.get_moles(/datum/gas/dilithium) * DILITHIUM_LAMBDA) + FUSION_TEMPERATURE_THRESHOLD_MINIMUM)
			// This is an exponential decay equation, actually. Horizontal Asymptote is FUSION_TEMPERATURE_THRESHOLD_MINIMUM.
			return
	//Yogs End
	var/turf/open/location
	if (istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)
	if(!air.analyzer_results)
		air.analyzer_results = new
	var/list/cached_scan_results = air.analyzer_results
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = air.get_moles(/datum/gas/plasma)
	var/initial_carbon = air.get_moles(/datum/gas/carbon_dioxide)
	var/scale_factor = (air.return_volume())/(PI) //We scale it down by volume/Pi because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/toroidal_size = (2*PI)+TORADIANS(arctan((air.return_volume()-TOROID_VOLUME_BREAKEVEN)/TOROID_VOLUME_BREAKEVEN)) //The size of the phase space hypertorus
	var/gas_power = 0
	for (var/gas_id in air.get_gases())
		gas_power += (GLOB.meta_gas_info[gas_id][META_GAS_FUSION_POWER]*air.get_moles(gas_id))
	var/instability = MODULUS((gas_power*INSTABILITY_GAS_POWER_FACTOR)**2,toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results[id] = instability//used for analyzer feedback

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)


	air.set_moles(/datum/gas/plasma, plasma*scale_factor + FUSION_MOLE_THRESHOLD )//Scales the gases back up
	air.set_moles(/datum/gas/carbon_dioxide, carbon*scale_factor + FUSION_MOLE_THRESHOLD)
	var/delta_plasma = initial_plasma - air.get_moles(/datum/gas/plasma)

	reaction_energy += delta_plasma*PLASMA_BINDING_ENERGY //Energy is gained or lost corresponding to the creation or destruction of mass.
	if(instability < FUSION_INSTABILITY_ENDOTHERMALITY)
		reaction_energy = max(reaction_energy,0) //Stable reactions don't end up endothermic.
	else if (reaction_energy < 0)
		reaction_energy *= (instability-FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	if(air.thermal_energy() + reaction_energy < 0) //No using energy that doesn't exist.
		air.set_moles(/datum/gas/plasma, initial_plasma)
		air.set_moles(/datum/gas/carbon_dioxide, initial_carbon)
		return NO_REACTION
	air.adjust_moles(/datum/gas/tritium, -FUSION_TRITIUM_MOLES_USED)
	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	if(reaction_energy > 0)
		air.adjust_moles(/datum/gas/oxygen, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(/datum/gas/nitrous_oxide, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
	else
		air.adjust_moles(/datum/gas/bz, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(/datum/gas/nitryl, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))

	if(reaction_energy)
		if(location)
			var/particle_chance = ((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
			if(prob(PERCENT(particle_chance)))
				location.fire_nuclear_particle()
			var/rad_power = max((FUSION_RAD_COEFFICIENT/instability) + FUSION_RAD_MAX,0)
			radiation_pulse(location,rad_power)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp(((air.return_temperature()*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB,INFINITY))
		return REACTING

/datum/gas_reaction/nitrylformation //The formation of nitryl. Endothermic. Requires N2O as a catalyst.
	priority = 3
	name = "Nitryl formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	min_requirements = list(
		/datum/gas/oxygen = 20,
		/datum/gas/nitrogen = 20,
		/datum/gas/nitrous_oxide = 5,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*30
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*60),air.get_moles(/datum/gas/oxygen),air.get_moles(/datum/gas/nitrogen))
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	if ((air.get_moles(/datum/gas/oxygen) - heat_efficency < 0 )|| (air.get_moles(/datum/gas/nitrogen) - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/oxygen, -heat_efficency)
	air.adjust_moles(/datum/gas/nitrogen, -heat_efficency)
	air.adjust_moles(/datum/gas/nitryl, heat_efficency*2)

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity - energy_used)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = 4
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()
	var/pressure = air.return_pressure()
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = min(1/((clamp(pressure,1,1000)/(0.5*ONE_ATMOSPHERE))*(max(air.get_moles(/datum/gas/plasma)/air.get_moles(/datum/gas/nitrous_oxide),1))),air.get_moles(/datum/gas/nitrous_oxide),air.get_moles(/datum/gas/plasma)/2)
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED
	if ((air.get_moles(/datum/gas/nitrous_oxide) - reaction_efficency < 0 )|| (air.get_moles(/datum/gas/plasma) - (2*reaction_efficency) < 0) || energy_released <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/bz, reaction_efficency)
	if(reaction_efficency == air.get_moles(/datum/gas/nitrous_oxide))
		air.adjust_moles(/datum/gas/bz, -min(pressure,1))
		air.adjust_moles(/datum/gas/oxygen, min(pressure,1))
	air.adjust_moles(/datum/gas/nitrous_oxide, -reaction_efficency)
	air.adjust_moles(/datum/gas/plasma, -2*reaction_efficency)

	//clamps by a minimum amount in the event of an underflow.
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp((reaction_efficency**2)*BZ_RESEARCH_AMOUNT,0.01,BZ_RESEARCH_MAX_AMOUNT))

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity + energy_released)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority = 6
	name = "Stimulum formation"
	id = "stimformation"

/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		/datum/gas/plasma = 10,
		/datum/gas/bz = 20,
		/datum/gas/nitryl = 30,
		"TEMP" = STIMULUM_HEAT_SCALE/2)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)

	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = min(air.return_temperature()/STIMULUM_HEAT_SCALE,air.get_moles(/datum/gas/plasma),air.get_moles(/datum/gas/nitryl))
	var/stim_energy_change = heat_scale*STIMULUM_HEAT_SCALE

	if ((air.get_moles(/datum/gas/plasma) - heat_scale < 0) || (air.get_moles(/datum/gas/nitryl) - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/stimulum, heat_scale/10)
	air.adjust_moles(/datum/gas/plasma, -heat_scale)
	air.adjust_moles(/datum/gas/nitryl, -heat_scale)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp(STIMULUM_RESEARCH_AMOUNT*heat_scale/10,0.01, STIMULUM_RESEARCH_MAX_AMOUNT))
	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority = 1001 //Ensure this value is higher than nobstop
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	min_requirements = list(
		/datum/gas/nitrogen = 20,
		/datum/gas/tritium = 10,
		"TEMP" = 5000000)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/nob_formed = min(air.get_moles(/datum/gas/tritium)/10,air.get_moles(/datum/gas/nitrogen)/20)
	var/old_heat_capacity = air.heat_capacity()
	var/energy_taken = nob_formed*(NOBLIUM_FORMATION_ENERGY/(max(air.get_moles(/datum/gas/bz),1)))
	air.adjust_moles(/datum/gas/tritium, -10*nob_formed)
	air.adjust_moles(/datum/gas/nitrogen, -20*nob_formed)
	air.adjust_moles(/datum/gas/hypernoblium, nob_formed)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp(nob_formed*NOBLIUM_RESEARCH_AMOUNT, 0.01, NOBLIUM_RESEARCH_MAX_AMOUNT))
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.set_temperature(max(((air.return_temperature()*old_heat_capacity - energy_taken)/new_heat_capacity),TCMB))
		return REACTING


/datum/gas_reaction/miaster	//dry heat sterilization: clears out pathogens in the air
	priority = -10 //after all the heating from fires etc. is done
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST+70,
		/datum/gas/miasma = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	// As the name says it, it needs to be dry
	if(air.get_moles(/datum/gas/water_vapor)/air.total_moles() > 0.1) // Yogs --Fixes runtime in Sterilization
		return NO_REACT

	//Replace miasma with oxygen
	var/cleaned_air = min(air.get_moles(/datum/gas/miasma), 20 + (air.return_temperature() - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	air.adjust_moles(/datum/gas/miasma, -cleaned_air)
	air.adjust_moles(/datum/gas/oxygen, cleaned_air)

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.set_temperature(air.return_temperature() + cleaned_air * 0.002)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, clamp(cleaned_air*MIASMA_RESEARCH_AMOUNT,0.01, MIASMA_RESEARCH_MAX_AMOUNT))//Turns out the burning of miasma is kinda interesting to scientists
	return REACTING
  
/datum/gas_reaction/stim_ball
	priority = 7
	name ="Stimulum Energy Ball"
	id = "stimball"

/datum/gas_reaction/stim_ball/init_reqs()
	min_requirements = list(
		/datum/gas/pluoxium = STIM_BALL_MOLES_REQUIRED,
		/datum/gas/stimulum = STIM_BALL_MOLES_REQUIRED,
		/datum/gas/plasma = STIM_BALL_MOLES_REQUIRED,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/// Reaction that burns stimulum and plouxium into radballs and partial constituent gases, but also catalyzes the combustion of plasma.
/datum/gas_reaction/stim_ball/react(datum/gas_mixture/air, datum/holder)
	var/turf/location
	var/old_heat_capacity = air.heat_capacity()
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var/reaction_rate = min(STIM_BALL_MAX_REACT_RATE, air.get_moles(/datum/gas/pluoxium), air.get_moles(/datum/gas/stimulum), air.get_moles(/datum/gas/plasma))
	var/balls_shot = round(reaction_rate/STIM_BALL_MOLES_REQUIRED)
	//A percentage of plasma is burned during the reaction that is converted into energy and radballs, though mostly pure heat. 
	var/plasma_burned = QUANTIZE((air.get_moles(/datum/gas/plasma) + 5*reaction_rate)*STIM_BALL_PLASMA_COEFFICIENT)
	//Stimulum has a lot of stored energy, and breaking it up releases some of it. Plasma is also partially converted into energy in the process.
	var/energy_released = (reaction_rate*STIMULUM_HEAT_SCALE) + (plasma_burned*STIM_BALL_PLASMA_ENERGY)
	air.adjust_moles(/datum/gas/stimulum, -reaction_rate)
	air.adjust_moles(/datum/gas/pluoxium, -reaction_rate)
	air.adjust_moles(/datum/gas/nitryl, reaction_rate*5)
	air.adjust_moles(/datum/gas/plasma, -plasma_burned)
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp((air.return_temperature()*old_heat_capacity + energy_released)/new_heat_capacity,TCMB,INFINITY))
		return REACTING
	if(balls_shot && !isnull(location))
		var/angular_increment = 360/balls_shot
		var/random_starting_angle = rand(0,360)
		for(var/i in 1 to balls_shot)
			location.fire_nuclear_particle((i*angular_increment+random_starting_angle))

//freon reaction (is not a fire yet)
/datum/gas_reaction/freonfire
	priority = -5
	name = "Freon combustion"
	id = "freonfire"

/datum/gas_reaction/freonfire/init_reqs()
	min_requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"TEMP" = FREON_LOWER_TEMPERATURE,
		"MAX_TEMP" = FREON_MAXIMUM_BURN_TEMPERATURE
		)

/datum/gas_reaction/freonfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	if(!isturf(holder))
		return NO_REACTION
	var/turf/open/location = holder

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
		if(air.get_moles(/datum/gas/oxygen) > air.get_moles(/datum/gas/freon) * FREON_OXYGEN_FULLBURN)
			freon_burn_rate = (air.get_moles(/datum/gas/freon) * temperature_scale) / FREON_BURN_RATE_DELTA
		else
			freon_burn_rate = (temperature_scale * (air.get_moles(/datum/gas/oxygen) / FREON_OXYGEN_FULLBURN)) / FREON_BURN_RATE_DELTA

		if(freon_burn_rate > MINIMUM_HEAT_CAPACITY)
			freon_burn_rate = min(freon_burn_rate, air.get_moles(/datum/gas/freon), air.get_moles(/datum/gas/oxygen) / oxygen_burn_rate) //Ensures matter is conserved properly
			air.adjust_moles(/datum/gas/freon, -freon_burn_rate)
			air.adjust_moles(/datum/gas/oxygen, -(freon_burn_rate * oxygen_burn_rate))
			air.adjust_moles(/datum/gas/carbon_dioxide, freon_burn_rate)

			if(temperature < 160 && temperature > 120 && prob(2))
				new /obj/item/stack/sheet/hot_ice(location)

			energy_released += FIRE_FREON_ENERGY_RELEASED * (freon_burn_rate)

	if(energy_released < 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature * old_heat_capacity + energy_released) / new_heat_capacity)

/datum/gas_reaction/h2fire
	priority = -3 //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Hydrogen Combustion"
	id = "h2fire"

/datum/gas_reaction/h2fire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/h2fire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
 //this speeds things up because accessing datum vars is slow
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	if(air.get_moles(/datum/gas/oxygen) < air.get_moles(/datum/gas/hydrogen) || MINIMUM_H2_OXYBURN_ENERGY > air.thermal_energy())
		burned_fuel = (air.get_moles(/datum/gas/oxygen)/HYDROGEN_BURN_OXY_FACTOR)
		air.adjust_moles(/datum/gas/hydrogen, -burned_fuel)
	else
		burned_fuel = (air.get_moles(/datum/gas/hydrogen) * HYDROGEN_BURN_H2_FACTOR)
		air.adjust_moles(/datum/gas/hydrogen, -(air.get_moles(/datum/gas/hydrogen) / HYDROGEN_BURN_H2_FACTOR))
		air.adjust_moles(/datum/gas/oxygen, -air.get_moles(/datum/gas/hydrogen))

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		air.adjust_moles(/datum/gas/water_vapor, (burned_fuel / HYDROGEN_BURN_OXY_FACTOR))

		cached_results["fire"] += burned_fuel

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released) / new_heat_capacity)

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
	priority = 13
	name = "Hexane formation"
	id = "hexane_formation"

/datum/gas_reaction/hexane_formation/init_reqs()
	min_requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		"TEMP" = 450,
		"MAX_TEMP" = 465
	)

/datum/gas_reaction/hexane_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.01, air.get_moles(/datum/gas/hydrogen), air.get_moles(/datum/gas/bz))
	var/energy_used = heat_efficency * 600
	if (air.get_moles(/datum/gas/hydrogen) - (heat_efficency * 5) < 0  || air.get_moles(/datum/gas/bz) - (heat_efficency * 0.25) < 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/hydrogen, -(heat_efficency * 5))
	air.adjust_moles(/datum/gas/bz, -(heat_efficency * 0.25))
	air.adjust_moles(/datum/gas/hexane, (heat_efficency * 5.25))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/metalhydrogen
	priority = 17
	name = "Metal Hydrogen formation"
	id = "metalhydrogen"

/datum/gas_reaction/metalhydrogen/init_reqs()
	min_requirements = list(
		/datum/gas/hydrogen = 100,
		/datum/gas/bz		= 5,
		"TEMP" = METAL_HYDROGEN_MINIMUM_HEAT
		)

/datum/gas_reaction/metalhydrogen/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	if(!isturf(holder))
		return NO_REACTION
	var/turf/open/location = holder
	///the more heat you use the higher is this factor
	var/increase_factor = min((temperature / METAL_HYDROGEN_MINIMUM_HEAT), 5)
	///the more moles you use and the higher the heat, the higher is the efficiency
	var/heat_efficency = air.get_moles(/datum/gas/hydrogen)* 0.01 * increase_factor
	var/pressure = air.return_pressure()
	var/energy_used = heat_efficency * METAL_HYDROGEN_FORMATION_ENERGY

	if(pressure >= METAL_HYDROGEN_MINIMUM_PRESSURE && temperature >= METAL_HYDROGEN_MINIMUM_HEAT)
		air.adjust_moles(/datum/gas/bz, -(heat_efficency * 0.01))
		if (prob(20 * increase_factor))
			air.adjust_moles(/datum/gas/hydrogen, -(heat_efficency * 3.5))
			if (prob(100 / increase_factor))
				new /obj/item/stack/sheet/mineral/metal_hydrogen(location)
				SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min((heat_efficency * increase_factor * 0.5), METAL_HYDROGEN_RESEARCH_MAX_AMOUNT))

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB))
		return REACTING

/datum/gas_reaction/freonformation
	priority = 5
	name = "Freon formation"
	id = "freonformation"

/datum/gas_reaction/freonformation/init_reqs() //minimum requirements for freon formation
	min_requirements = list(
		/datum/gas/plasma = 40,
		/datum/gas/carbon_dioxide = 20,
		/datum/gas/bz = 20,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100
		)

/datum/gas_reaction/freonformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), air.get_moles(/datum/gas/plasma), air.get_moles(/datum/gas/carbon_dioxide), air.get_moles(/datum/gas/bz))
	var/energy_used = heat_efficency * 100
	if ((air.get_moles(/datum/gas/plasma) - heat_efficency * 1.5 < 0 ) || (air.get_moles(/datum/gas/carbon_dioxide) - heat_efficency * 0.75 < 0) || (air.get_moles(/datum/gas/bz) - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/plasma, -(heat_efficency * 1.5))
	air.adjust_moles(/datum/gas/carbon_dioxide, -(heat_efficency * 0.75))
	air.adjust_moles(/datum/gas/bz, -(heat_efficency * 0.25))
	air.adjust_moles(/datum/gas/freon, (heat_efficency * 2.5))

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity - energy_used)/new_heat_capacity), TCMB))
		return REACTING


/datum/gas_reaction/halon_formation
	priority = 12
	name = "Halon formation"
	id = "halon_formation"

/datum/gas_reaction/halon_formation/init_reqs()
	min_requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"TEMP" = 30,
		"MAX_TEMP" = 55
	)

/datum/gas_reaction/halon_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.01, air.get_moles(/datum/gas/tritium), air.get_moles(/datum/gas/bz))
	var/energy_used = heat_efficency * 300
	if ((air.get_moles(/datum/gas/tritium) - heat_efficency * 4 < 0 ) || (air.get_moles(/datum/gas/bz) - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/tritium, -(heat_efficency * 4))
	air.adjust_moles(/datum/gas/bz, -(heat_efficency * 0.25))
	air.adjust_moles(/datum/gas/halon, (heat_efficency * 4.25))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/healium_formation
	priority = 9
	name = "Healium formation"
	id = "healium_formation"

/datum/gas_reaction/healium_formation/init_reqs()
	min_requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		/datum/gas/freon = MINIMUM_MOLE_COUNT,
		"TEMP" = 25,
		"MAX_TEMP" = 300
	)

/datum/gas_reaction/healium_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.3, air.get_moles(/datum/gas/freon), air.get_moles(/datum/gas/bz))
	var/energy_used = heat_efficency * 9000
	if ((air.get_moles(/datum/gas/freon) - heat_efficency * 2.75 < 0 ) || (air.get_moles(/datum/gas/bz) - heat_efficency * 0.25 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/freon, -(heat_efficency * 2.75))
	air.adjust_moles(/datum/gas/bz, -(heat_efficency * 0.25))
	air.adjust_moles(/datum/gas/healium, (heat_efficency * 3))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/pluonium_formation
	priority = 10
	name = "Pluonium formation"
	id = "pluonium_formation"

/datum/gas_reaction/pluonium_formation/init_reqs()
	min_requirements = list(
		/datum/gas/pluoxium = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = MINIMUM_MOLE_COUNT,
		"TEMP" = 5000,
		"MAX_TEMP" = 10000
	)

/datum/gas_reaction/pluonium_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.005, air.get_moles(/datum/gas/pluoxium), air.get_moles(/datum/gas/hydrogen))
	var/energy_used = heat_efficency * 650
	if ((air.get_moles(/datum/gas/pluoxium) - heat_efficency * 0.2 < 0 ) || (air.get_moles(/datum/gas/hydrogen) - heat_efficency * 2 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/hydrogen, -(heat_efficency * 2))
	air.adjust_moles(/datum/gas/pluoxium, -(heat_efficency * 0.2))
	air.adjust_moles(/datum/gas/pluonium, (heat_efficency * 2.2))

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/zauker_formation
	priority = 11
	name = "Zauker formation"
	id = "zauker_formation"

/datum/gas_reaction/zauker_formation/init_reqs()
	min_requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		/datum/gas/stimulum = MINIMUM_MOLE_COUNT,
		"TEMP" = 50000,
		"MAX_TEMP" = 75000
	)

/datum/gas_reaction/zauker_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature * 0.000005, air.get_moles(/datum/gas/hypernoblium), air.get_moles(/datum/gas/stimulum))
	var/energy_used = heat_efficency * 5000
	if ((air.get_moles(/datum/gas/hypernoblium) - heat_efficency * 0.01 < 0 ) || (air.get_moles(/datum/gas/stimulum) - heat_efficency * 0.5 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/hypernoblium, -(heat_efficency * 0.01))
	air.adjust_moles(/datum/gas/stimulum, -(heat_efficency * 0.5))
	air.adjust_moles(/datum/gas/zauker, (heat_efficency * 0.5))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/halon_o2removal
	priority = -1
	name = "Halon o2 removal"
	id = "halon_o2removal"

/datum/gas_reaction/halon_o2removal/init_reqs()
	min_requirements = list(
		/datum/gas/halon = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/halon_o2removal/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature / ( FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10), air.get_moles(/datum/gas/halon), air.get_moles(/datum/gas/oxygen))
	var/energy_used = heat_efficency * 2500
	if ((air.get_moles(/datum/gas/halon) - heat_efficency < 0 ) || (air.get_moles(/datum/gas/oxygen) - heat_efficency * 20 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/halon, -(heat_efficency))
	air.adjust_moles(/datum/gas/oxygen, -(heat_efficency * 20))
	air.adjust_moles(/datum/gas/carbon_dioxide, (heat_efficency * 5))

	if(energy_used)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB))
	return REACTING

/datum/gas_reaction/zauker_decomp
	priority = 8
	name = "Zauker decomposition"
	id = "zauker_decomp"

/datum/gas_reaction/zauker_decomp/init_reqs()
	min_requirements = list(
		/datum/gas/nitrogen = MINIMUM_MOLE_COUNT,
		/datum/gas/zauker = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/zauker_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
 //this speeds things up because accessing datum vars is slow
	var/temperature = air.return_temperature()
	var/burned_fuel = 0
	burned_fuel = min(20, air.get_moles(/datum/gas/nitrogen), air.get_moles(/datum/gas/zauker))
	if(air.get_moles(/datum/gas/zauker) - burned_fuel < 0)
		return NO_REACTION
	air.adjust_moles(/datum/gas/zauker, -burned_fuel)

	if(burned_fuel)
		energy_released += (460 * burned_fuel)
		air.adjust_moles(/datum/gas/oxygen, (burned_fuel * 0.3))
		air.adjust_moles(/datum/gas/nitrogen, (burned_fuel * 0.7))

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB))
		return REACTING
	return NO_REACTION

/datum/gas_reaction/pluonium_bz_response
	priority = 14
	name = "Pluonium bz response"
	id = "pluonium_bz_response"

/datum/gas_reaction/pluonium_bz_response/init_reqs()
	min_requirements = list(
		/datum/gas/pluonium = MINIMUM_MOLE_COUNT,
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
		"TEMP" = 260,
		"MAX_TEMP" = 280
	)

/datum/gas_reaction/pluonium_bz_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()

	var/temperature = air.return_temperature()
	var/turf/open/location
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var consumed_amount = min(5, air.get_moles(/datum/gas/bz), air.get_moles(/datum/gas/pluonium))
	if(air.get_moles(/datum/gas/bz) - consumed_amount < 0)
		return NO_REACTION
	if(air.get_moles(/datum/gas/bz) < 30)
		radiation_pulse(location, consumed_amount * 20, 2.5, TRUE, FALSE)
		air.adjust_moles(/datum/gas/bz, -consumed_amount)
	else
		for(var/mob/living/carbon/L in location)
			L.hallucination += (air.get_moles(/datum/gas/bz * 0.7))
	energy_released += 100
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB))
	return REACTING

/datum/gas_reaction/pluonium_tritium_response
	priority = 15
	name = "Pluonium tritium response"
	id = "pluonium_tritium_response"

/datum/gas_reaction/pluonium_tritium_response/init_reqs()
	min_requirements = list(
		/datum/gas/pluonium = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"TEMP" = 150,
		"MAX_TEMP" = 340
	)

/datum/gas_reaction/pluonium_tritium_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/turf/open/location = isturf(holder) ? holder : null
	var produced_amount = min(5, air.get_moles(/datum/gas/tritium), air.get_moles(/datum/gas/pluonium))
	if(air.get_moles(/datum/gas/tritium) - produced_amount < 0 || air.get_moles(/datum/gas/pluonium) - produced_amount * 0.01 < 0)
		return NO_REACTION
	location.rad_act(produced_amount * 2.4)
	air.adjust_moles(/datum/gas/tritium, -produced_amount)
	air.adjust_moles(/datum/gas/hydrogen, produced_amount)
	air.adjust_moles(/datum/gas/pluonium, -(produced_amount * 0.01))
	energy_released += 50
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB))
	return REACTING

/datum/gas_reaction/pluonium_hydrogen_response
	priority = 16
	name = "Pluonium hydrogen response"
	id = "pluonium_hydrogen_response"

/datum/gas_reaction/pluonium_hydrogen_response/init_reqs()
	min_requirements = list(
		/datum/gas/pluonium = MINIMUM_MOLE_COUNT,
		/datum/gas/hydrogen = 150,
	)

/datum/gas_reaction/pluonium_hydrogen_response/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var produced_amount = min(5, air.get_moles(/datum/gas/hydrogen), air.adjust_moles(/datum/gas/pluonium))
	if(air.get_moles(/datum/gas/hydrogen) - produced_amount < 0)
		return NO_REACTION
	air.adjust_moles(/datum/gas/hydrogen, -produced_amount)
	air.adjust_moles(/datum/gas/pluonium, (produced_amount * 0.5))
	energy_released = produced_amount * 2500
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max((temperature * old_heat_capacity - energy_released) / new_heat_capacity, TCMB))
	return REACTING
