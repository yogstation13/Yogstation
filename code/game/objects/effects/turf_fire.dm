/// The base temperature used when calling hotspot_expose()
#define TURF_FIRE_TEMP_BASE (T0C+650)
/// The amount of power loss from low temperatures, scales with how far the temperature FIRE_MINIMUM_TEMPERATURE_TO_EXIST
#define TURF_FIRE_POWER_LOSS_ON_LOW_TEMP 7
/// The increase of temperature used in hotspot_expose() for each fire_power the turf fire has
#define TURF_FIRE_TEMP_INCREMENT_PER_POWER 3
/// The volume of the hotspot exposure, in liters
#define TURF_FIRE_VOLUME 150
/// Maximum fire power the turf fire can have
#define TURF_FIRE_MAX_POWER 50
/// Multiplier for the probability of spreading to adjacent tiles and how much power the new fires have
#define TURF_FIRE_SPREAD_RATE 0.3

/// Joules of energy added to the air for each oxygen molecule consumed
#define TURF_FIRE_ENERGY_PER_BURNED_OXY_MOL 12000
/// The base burn rate, increases with fire power
#define TURF_FIRE_BURN_RATE_BASE 0.15
/// Increase in burn rate for each fire power
#define TURF_FIRE_BURN_RATE_PER_POWER 0.03
/// The oxygen to CO2 conversion rate
#define TURF_FIRE_BURN_CARBON_DIOXIDE_MULTIPLIER 0.75
/// Minimum moles of oxygen required to burn
#define TURF_FIRE_BURN_MINIMUM_OXYGEN_REQUIRED 1
/// Percent chance of playing a sound effect
#define TURF_FIRE_BURN_PLAY_SOUND_EFFECT_CHANCE 6

#define TURF_FIRE_STATE_SMALL 1
#define TURF_FIRE_STATE_MEDIUM 2
#define TURF_FIRE_STATE_LARGE 3

/obj/effect/abstract/turf_fire
	icon = 'icons/effects/turf_fire.dmi'
	icon_state = "fire_small"
	layer = GASFIRE_LAYER
	anchored = TRUE
	base_icon_state = "red"
	move_resist = INFINITY
	light_range = 1.5
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE
	mouse_opacity = FALSE
	var/turf/open/open_turf
	/// How much power have we got. This is treated like fuel, be it flamethrower fuel or any random thing you could come up with
	var/fire_power = 20
	/// Is it magical, if it is then it wont interact with atmos, and it will not lose power by itself. Mainly for adminbus events or mapping
	var/magical = FALSE
	/// Visual state of the fire. Kept track to not do too many updates.
	var/current_fire_state
	/// the list of allowed colors, if fire_color doesn't match, we store the color in hex_color instead and we color the fire based on hex instead
	var/list/allowed_colors = list("red", "blue", "green", "white")
	/// If we are using a custom hex color, which color are we using?
	var/hex_color
	/// If false, it does not interact with atmos.
	var/interact_with_atmos = TRUE


///All the subtypes are for adminbussery and or mapping
/obj/effect/abstract/turf_fire/magical
	magical = TRUE
	interact_with_atmos = FALSE

/obj/effect/abstract/turf_fire/small
	fire_power = 10

/obj/effect/abstract/turf_fire/small/magical
	magical = TRUE
	interact_with_atmos = FALSE

/obj/effect/abstract/turf_fire/inferno
	fire_power = 30

/obj/effect/abstract/turf_fire/inferno/magical
	magical = TRUE
	interact_with_atmos = FALSE

/obj/effect/abstract/turf_fire/Initialize(mapload, power, fire_color)
	. = ..()
	if(!isturf(loc)) // guh
		return INITIALIZE_HINT_QDEL
	open_turf = get_turf(src)
	if(isgroundlessturf(open_turf))
		return INITIALIZE_HINT_QDEL
	if(open_turf.turf_fire)
		return INITIALIZE_HINT_QDEL
	open_turf.turf_fire = src
	RegisterSignal(open_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	START_PROCESSING(SSturf_fire, src)
	if(power)
		fire_power = min(TURF_FIRE_MAX_POWER, power)
	if(!fire_color)
		base_icon_state = "red"
	else if(fire_color in allowed_colors)
		base_icon_state = fire_color
	else
		hex_color = fire_color
		color = fire_color
		base_icon_state = "greyscale"
	UpdateFireState()
	alpha = 160 // be slightly transparent
	//process() // process once instantly, helps prevent weird fire behavior

/obj/effect/abstract/turf_fire/Destroy()
	open_turf.turf_fire = null
	STOP_PROCESSING(SSturf_fire, src)
	UnregisterSignal(open_turf, COMSIG_ATOM_ENTERED)
	return ..()

/obj/effect/abstract/turf_fire/proc/process_waste()
	if(open_turf.planetary_atmos)
		return TRUE
	var/oxy = open_turf.air.get_moles(GAS_O2)
	if (oxy < TURF_FIRE_BURN_MINIMUM_OXYGEN_REQUIRED)
		return FALSE
	var/thermal_energy = open_turf.air.return_temperature() * open_turf.air.heat_capacity()
	var/burn_rate = TURF_FIRE_BURN_RATE_BASE + fire_power * TURF_FIRE_BURN_RATE_PER_POWER
	if(burn_rate > oxy)
		burn_rate = oxy

	open_turf.air.adjust_moles(GAS_O2, -burn_rate)
	open_turf.air.adjust_moles(GAS_CO2, burn_rate * TURF_FIRE_BURN_CARBON_DIOXIDE_MULTIPLIER)

	open_turf.air.set_temperature((thermal_energy + (burn_rate * TURF_FIRE_ENERGY_PER_BURNED_OXY_MOL)) / open_turf.air.heat_capacity())
	open_turf.air_update_turf(TRUE)
	return TRUE

/obj/effect/abstract/turf_fire/proc/fire_pressure_check(turf/open/T)
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		fire_power -= TURF_FIRE_POWER_LOSS_ON_LOW_TEMP

/obj/effect/abstract/turf_fire/process()
	if(open_turf.active_hotspot) //If we have an active hotspot, let it do the damage instead and lets not lose power
		return
	var/obj/structure/window = locate() in loc
	if(window in loc)	
		qdel(src)
		return
	if(interact_with_atmos)
		if(!process_waste())
			qdel(src)
			return
	if(!magical)
		fire_power += open_turf.flammability
		var/temperature = open_turf.air.return_temperature()
		if(temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			fire_power -= TURF_FIRE_POWER_LOSS_ON_LOW_TEMP * ((FIRE_MINIMUM_TEMPERATURE_TO_EXIST - temperature) / FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		fire_power--
		if(fire_power <= 0)
			qdel(src)
			return
		fire_pressure_check()
	var/fire_temp = TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power)
	open_turf.hotspot_expose(fire_temp, TURF_FIRE_VOLUME)
	for(var/atom/movable/burning_atom as anything in open_turf)
		burning_atom.temperature_expose(open_turf.air, fire_temp, TURF_FIRE_VOLUME)
		burning_atom.fire_act(fire_temp, TURF_FIRE_VOLUME)
	var/list/turfs_to_spread = open_turf.atmos_adjacent_turfs
	for(var/turf/open/T in turfs_to_spread)
		if(prob(T.flammability * fire_power * TURF_FIRE_SPREAD_RATE))
			T.ignite_turf(fire_power * TURF_FIRE_SPREAD_RATE)
	if(magical)
		if(prob(fire_power))
			open_turf.burn_tile()
		if(prob(TURF_FIRE_BURN_PLAY_SOUND_EFFECT_CHANCE))
			playsound(open_turf, 'sound/effects/comfyfire.ogg', 40, TRUE)
	UpdateFireState()

/obj/effect/abstract/turf_fire/proc/on_entered(datum/source, atom/movable/AM)
	if(open_turf.active_hotspot) //If we have an active hotspot, let it do the damage instead 
		return
	AM.fire_act(TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power), TURF_FIRE_VOLUME)
	return

/obj/effect/abstract/turf_fire/extinguish()
	qdel(src)

/obj/effect/abstract/turf_fire/proc/AddPower(power)
	fire_power = min(TURF_FIRE_MAX_POWER, fire_power + power)
	UpdateFireState()

/obj/effect/abstract/turf_fire/proc/UpdateFireState()
	var/new_state
	switch(fire_power)
		if(0 to 10)
			new_state = TURF_FIRE_STATE_SMALL
		if(11 to 24)
			new_state = TURF_FIRE_STATE_MEDIUM
		if(25 to INFINITY)
			new_state = TURF_FIRE_STATE_LARGE

	if(new_state == current_fire_state)
		return
	current_fire_state = new_state

	switch(base_icon_state) //switches light color depdning on the flame color
		if("greyscale")
			light_color = hex_color
		if("red")
			light_color = LIGHT_COLOR_FIRE
		if("blue")
			light_color = LIGHT_COLOR_CYAN
		if("green")
			light_color = LIGHT_COLOR_GREEN
		else
			light_color = COLOR_SILVER
	update_light()

	switch(current_fire_state)
		if(TURF_FIRE_STATE_SMALL)
			icon_state = "[base_icon_state]_small"
			set_light_range(1.5)
		if(TURF_FIRE_STATE_MEDIUM)
			icon_state = "[base_icon_state]_medium"
			set_light_range(2.5)
		if(TURF_FIRE_STATE_LARGE)
			icon_state = "[base_icon_state]_big"
			set_light_range(3)

#undef TURF_FIRE_TEMP_BASE
#undef TURF_FIRE_POWER_LOSS_ON_LOW_TEMP
#undef TURF_FIRE_TEMP_INCREMENT_PER_POWER
#undef TURF_FIRE_VOLUME
#undef TURF_FIRE_MAX_POWER
#undef TURF_FIRE_SPREAD_RATE

#undef TURF_FIRE_ENERGY_PER_BURNED_OXY_MOL
#undef TURF_FIRE_BURN_RATE_BASE
#undef TURF_FIRE_BURN_RATE_PER_POWER
#undef TURF_FIRE_BURN_CARBON_DIOXIDE_MULTIPLIER
#undef TURF_FIRE_BURN_MINIMUM_OXYGEN_REQUIRED
#undef TURF_FIRE_BURN_PLAY_SOUND_EFFECT_CHANCE

#undef TURF_FIRE_STATE_SMALL
#undef TURF_FIRE_STATE_MEDIUM
#undef TURF_FIRE_STATE_LARGE
