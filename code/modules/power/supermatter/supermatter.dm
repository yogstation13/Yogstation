//Ported from /vg/station13, which was in turn forked from baystation12;
//Please do not bother them with bugs from this port, however, as it has been modified quite a bit.
//Modifications include removing the world-ending full supermatter variation, and leaving only the shard.

/// How much heat before SM prints warnings
#define CRITICAL_TEMPERATURE 10000

/// How much energy before SM prints tesla warnings
#define SUPERMATTER_MAXIMUM_ENERGY 1e6

/// Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define PLASMA_HEAT_PENALTY 15
#define OXYGEN_HEAT_PENALTY 1
#define CO2_HEAT_PENALTY 0.1
#define PLUOXIUM_HEAT_PENALTY -1
#define TRITIUM_HEAT_PENALTY 10
#define HALON_HEAT_PENALTY -5
#define BZ_HEAT_PENALTY 5
#define NITROGEN_HEAT_PENALTY -1.5
#define H2O_HEAT_PENALTY 12 //This'll get made slowly over time, I want my spice rock spicy god damnit
#define ANTINOB_HEAT_PENALTY 15

/// Higher == Bigger bonus to power generation.
/// All of these get divided by 10-bzcomp * 5 before having 1 added and being multiplied with power to determine rads
#define OXYGEN_TRANSMIT_MODIFIER 1.5
#define PLASMA_TRANSMIT_MODIFIER 4
#define BZ_TRANSMIT_MODIFIER -2
#define TRITIUM_TRANSMIT_MODIFIER 30 //We divide by 10, so this works out to 3
#define PLUOXIUM_TRANSMIT_MODIFIER -5 //Should halve the power output
#define H2O_TRANSMIT_MODIFIER 2
#define HYDROGEN_TRANSMIT_MODIFIER 25 //increase the radiation emission, but less than the trit (2.5)
#define HEALIUM_TRANSMIT_MODIFIER 2.4
#define PLUONIUM_TRANSMIT_MODIFIER 15
#define NITRIUM_TRANSMIT_MODIFIER 75 //absurd amount of power, but quickly decays into nuclear particles
#define ANTINOB_TRANSMIT_MODIFIER -0.5

/// How much extra radioactivity to emit
#define BZ_RADIOACTIVITY_MODIFIER 5 // Up to 500% rads
#define TRITIUM_RADIOACTIVITY_MODIFIER 3
#define PLUOXIUM_RADIOACTIVITY_MODIFIER -2

/// Higher == Gas makes the crystal more resistant against heat damage.
#define N2O_HEAT_RESISTANCE 6
#define NOBLIUM_HEAT_RESISTANCE 20 // Very good at keeping an SM from burning
#define PLUOXIUM_HEAT_RESISTANCE 12
#define HYDROGEN_HEAT_RESISTANCE 2 // just a bit of heat resistance to spice it up
#define PLUONIUM_HEAT_RESISTANCE 5

#define ZAUKER_DAMAGE_MOD 9 // Each value is +1 after calculation
#define HEALIUM_HEAL_MOD 4

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define MOLE_SPACE_THRESHOLD 10 			  //Prevents engineers from spacing the crystal or using full vacuum to stop crystal explosions, higher to make penalty apply quicker
#define MOLE_PENALTY_THRESHOLD 1800           //Higher == Shard can absorb more moles before triggering the high mole penalties.
#define MOLE_HEAT_PENALTY 350                 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
#define POWER_PENALTY_THRESHOLD 5000          //Higher == Engine can generate more power before triggering the high power penalties.
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //Same as above, but causes more dangerous effects
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //Even more dangerous effects, threshold for tesla delamination
#define HEAT_PENALTY_THRESHOLD 40             //Higher == Crystal safe operational temperature is higher.
#define DAMAGE_HARDCAP 0.002
#define DAMAGE_INCREASE_MULTIPLIER 0.25

#define THERMAL_RELEASE_MODIFIER 5         //Higher == less heat released during reaction, not to be confused with the above values
#define PLASMA_RELEASE_MODIFIER 750        //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325        //Higher == less oxygen released at high temperature/power

#define REACTION_POWER_MODIFIER 0.55       //Higher == more overall power

#define MATTER_POWER_CONVERSION 10         //Crystal converts 1/this value of stored matter into energy.

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600
#define SUPERMATTER_EXPLOSION_LAMBDA 20

#define WARNING_DELAY 60

#define HALLUCINATION_RANGE(P) (min(7, round(P ** 0.25)))

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 5
#define SUPERMATTER_EMERGENCY_PERCENT 25
#define SUPERMATTER_DANGER_PERCENT 50
#define SUPERMATTER_WARNING_PERCENT 100

#define SUPERMATTER_COUNTDOWN_TIME 30 SECONDS
#define SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN 2 SECONDS ///to prevent accent sounds from layering

GLOBAL_DATUM(main_supermatter_engine, /obj/machinery/power/supermatter_crystal)

/obj/machinery/power/supermatter_crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter"
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	critical_machine = TRUE
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

	light_range = 4
	// this thing bright as hell (to increase bloom)
	light_power = 5
	light_color = "#ffe016"

	//NTNet Related Variables
	var/uid = 1
	var/static/gl_uid = 1

	/// Amount of gas that goes 'into' the SM
	var/gasefficency = 0.15

	/// This is set to true when the SM is about to explode and has the blue shields up
	var/final_countdown = FALSE

	/// Health of the SM
	var/damage = 0
	var/damage_archived = 0

	// Variables for calculating SM Health
	var/warning_point = 50
	var/damage_penalty_point = 550
	var/emergency_point = 700
	var/explosion_point = 900

	// Strings for radio
	var/safe_alert = "Crystalline hyperstructure returning to safe operating parameters."
	var/warning_alert = "Danger! Crystal hyperstructure integrity faltering!"
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."

	/// How much force the SM expldoes with
	var/explosion_power = 35

	/// Factor for power generation. AirTemp*(temp_factor/(0C))
	var/temp_factor = 30
	var/power = 0

	/// Yogs - radiation modifier. After all power calculations, multiplies the intensity of the rad pulse by this value. Used for making engines more hugbox.
	var/radmodifier = 1.5

	/// Time in deciseconds since the last sent warning
	var/lastwarning = 0

	/// Additonal power to add over time comes from sliver extraction(800) or consuming(200)
	var/matter_power = 0
	var/last_rads = 0

	///How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2

	///How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	// Antinobilium related variables
	var/support_integrity = 100			// Current support integrity. Provides *fun* effects
	var/antinoblium_attached = FALSE	// The thing that makes it explode more
	var/corruptor_attached = FALSE		// The thing that reduces support integrity
	var/resonance_cascading = FALSE		// IT'S NOT SHUTTING DOWN!!!!!!!
	var/noblium_suppressed = FALSE		// or is it?

	// Blob related shit
	var/supermatter_blob = FALSE // Well say sike rn

	// Radio related variables
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = RADIO_CHANNEL_ENGINEERING
	var/common_channel = null

	// Logging
	var/has_been_powered = FALSE
	var/has_reached_emergency = FALSE

	// Hugbox Supermatter Variables
	var/takes_damage = TRUE		// Does the SM take integrity damage
	var/produces_gas = TRUE		// Does it make gas

	// Holder variables
	var/obj/effect/countdown/supermatter/countdown
	var/datum/looping_sound/supermatter/soundloop

	/// Effect holder for the displacement filter to distort the SM based on its activity level
	var/atom/movable/distortion_effect/distort

	/// Our last reported status..
	var/last_status

	/// For antag sliver objective or for engineering goal
	var/is_main_engine = FALSE

	/// Is it moveable. Used for SM shards
	var/moveable = FALSE

	/// Cooldown for sounds
	var/last_accent_sound = 0

	/// Incase of clown(Colton) turn to false
	var/messages_admins = TRUE

	/// Makes the SM loose more power the higher it is
	var/powerloss_dynamic_scaling = 1

	/// Ratio of power reduction to power addition. Range is 0-1
	var/gasmix_power_ratio = 0

	/// Used for normalizing/making a ratio of gasses
	var/combined_gas = 0

	/// How much heat the SM produces
	var/dynamic_heat_modifier = 0

	/// How hot the SM can get before delaminating
	var/dynamic_heat_resistance = 0

	/// How much more heat damage to take based on moles
	var/mole_heat_penalty = 0

	/// How much powerloss to reduce. Scale of 1-0
	var/powerloss_inhibitor = 1

	/// How much is the SM surging?
	var/surging = 0

	/// Doesnt do anything they are influenced by gases
	var/damage_mod = 1
	var/heal_mod = 1

	//Data, because graphs are cool
	var/list/powerData = list()
	var/list/radsData = list()
	var/list/tempData = list()
	var/list/kpaData = list()
	var/list/molesData = list()

/obj/machinery/power/supermatter_crystal/Initialize(mapload)
	. = ..()
	uid = gl_uid++
	SSair.start_processing_machine(src)
	countdown = new(src)
	countdown.start()
	GLOB.poi_list |= src
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	distort = new(src)
	add_emitter(/obj/emitter/sparkle, "supermatter_sparkle")
	investigate_log("has been created.", INVESTIGATE_SUPERMATTER)
	if(is_main_engine)
		GLOB.main_supermatter_engine = src

	soundloop = new(list(src), TRUE)

/obj/machinery/power/supermatter_crystal/Destroy()
	investigate_log("has been destroyed.", INVESTIGATE_SUPERMATTER)
	SSair.stop_processing_machine(src)
	QDEL_NULL(radio)
	GLOB.poi_list -= src
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	QDEL_NULL(soundloop)
	distort.icon = 'icons/effects/32x32.dmi'
	distort.icon_state = "SM_remnant"
	distort.pixel_x = 0
	distort.pixel_y = 0
	distort.forceMove(get_turf(src))
	distort = null
	return ..()

/obj/machinery/power/supermatter_crystal/examine(mob/user)
	. = ..()
	var/immune = HAS_TRAIT(user, TRAIT_MESONS) || HAS_TRAIT(user.mind, TRAIT_MESONS)
	if (isliving(user) && !immune && (get_dist(user, src) < HALLUCINATION_RANGE(power)))
		. += span_danger("You get headaches just from looking at it.")

/obj/machinery/power/supermatter_crystal/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	if(get_integrity() < SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING


	if(get_integrity() < SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	if(get_integrity() < SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	if((get_integrity() < SUPERMATTER_WARNING_PERCENT) || (air.return_temperature() > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.return_temperature() > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_crystal/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 100, pressure_affected=FALSE)
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 100, pressure_affected=FALSE)
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 10, pressure_affected=FALSE)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/supermatter_alert.ogg', 75, FALSE, pressure_affected=FALSE)

/obj/machinery/power/supermatter_crystal/get_integrity()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_crystal/proc/get_fake_integrity()
	return max(min(support_integrity + round(rand() * 10, 0.01)-5,99.99),0.01) //never give 100 or 0 as that would be too suspicious.

/obj/machinery/power/supermatter_crystal/update_overlays()
	. = ..()
	. += get_displacement_icon()
	if(final_countdown)
		. += "causality_field"

// Switches the overlay based on the supermatter's current state; only called when the status has changed
/obj/machinery/power/supermatter_crystal/proc/get_displacement_icon()
	switch(last_status)
		if(SUPERMATTER_INACTIVE)
			distort.icon = 'icons/effects/96x96.dmi'
			distort.icon_state = "SM_base"
			distort.pixel_x = -32
			distort.pixel_y = -32
			light_range = 4
			light_power = 5
			light_color = "#ffe016"
		if(SUPERMATTER_NORMAL, SUPERMATTER_NOTIFY, SUPERMATTER_WARNING)
			distort.icon = 'icons/effects/96x96.dmi'
			distort.icon_state = "SM_base_active"
			distort.pixel_x = -32
			distort.pixel_y = -32
			light_range = 4
			light_power = 7
			light_color = "#ffe016"
		if(SUPERMATTER_DANGER)
			distort.icon = 'icons/effects/160x160.dmi'
			distort.icon_state = "SM_delam_1"
			distort.pixel_x = -64
			distort.pixel_y = -64
			light_range = 5
			light_power = 10
			light_color = "#ffb516"
		if(SUPERMATTER_EMERGENCY)
			distort.icon = 'icons/effects/224x224.dmi'
			distort.icon_state = "SM_delam_2"
			distort.pixel_x = -96
			distort.pixel_y = -96
			light_range = 6
			light_power = 10
			light_color = "#ff9208"
		if(SUPERMATTER_DELAMINATING)
			distort.icon = 'icons/effects/288x288.dmi'
			distort.icon_state = "SM_delam_3"
			distort.pixel_x = -128
			distort.pixel_y = -128
			light_range = 7
			light_power = 15
			light_color = "#ff5006"
	return distort

/obj/machinery/power/supermatter_crystal/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE

	update_icon()

	var/speaking

	if(corruptor_attached)
		speaking = "SUPERMATTER CRITICAL FAILURE ENGAGING FAILSAFE." //technically the failsafe is fail-danger, but whatever.
	else
		speaking = "[emergency_alert] The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated."
	radio.talk_into(src, speaking, common_channel, language = get_selected_language())
	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step (-1 SECONDS))
		if(damage < explosion_point && !resonance_cascading) // Cutting it a bit close there engineers
			radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			log_game("The supermatter crystal:[safe_alert] Failsafe has been disengaged.") // yogs start - Logs SM chatter
			investigate_log("The supermatter crystal:[safe_alert] Failsafe has been disengaged.", INVESTIGATE_SUPERMATTER) // yogs end
			final_countdown = FALSE
			update_icon()
			return
		else if((i % (5 SECONDS)) != 0 && i > (5 SECONDS)) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(1 SECONDS)
			continue
		else if(i > 5 SECONDS)
			if(corruptor_attached)
				speaking = "[DisplayTimeText(round(rand()*5*i,1), TRUE)] remain before causality stabilization."
			else
				speaking = "[DisplayTimeText(i, TRUE)] remain before causality stabilization."
			log_game("The supermatter crystal: [DisplayTimeText(i, TRUE)] remain before causality stabilization.") // yogs start - Logs SM chatter
			investigate_log("The supermatter crystal: [DisplayTimeText(i, TRUE)] remain before causality stabilization.", INVESTIGATE_SUPERMATTER)
			if(i == 30 SECONDS)	//Yogs- also adds audio when SM hits countdown
				playsound(src, 'yogstation/sound/voice/sm/fcitadel_30sectosingularity.ogg', 100, FALSE, 100, pressure_affected=FALSE)
			if(i == 15 SECONDS)
				playsound(src, 'yogstation/sound/voice/sm/fcitadel_15sectosingularity.ogg', 100, FALSE, 100, pressure_affected=FALSE)
			if(i == 10 SECONDS)
				playsound(src, 'yogstation/sound/voice/sm/fcitadel_10sectosingularity.ogg', 100, FALSE, 100, pressure_affected=FALSE)
				if(antinoblium_attached && !resonance_cascading) // yogs- resonance cascade!
					priority_announce("RESONANCE CASCADE IMMINENT.", "Anomaly Alert", 'sound/misc/notice1.ogg')
					resonance_cascading = TRUE
					sound_to_playing_players('sound/magic/lightning_chargeup.ogg', 50, FALSE) // yogs end
				if(supermatter_blob)
					if(!check_containment(src, 5))
						priority_announce("LEVEL 5 BIOHAZARD OUTBREAK IMMINENT.", "Anomaly Alert", 'sound/misc/notice1.ogg', color_override="yellow")
					else
						priority_announce("LEVEL 5 CONTROLLED BIOHAZARD CONTAINMENT IMMINENT. ESTABLISHING RESEARCH NODES AROUND CONTAINMENT FIELDS.", "Anomaly Alert", 'sound/misc/notice1.ogg', color_override="green")
		else
			if(corruptor_attached)
				speaking = "[round(i*0.1*rand(),1)]..."
			else
				speaking = "[i*0.1]..."

			log_game("The supermatter crystal: [i*0.1]...") // yogs start - Logs SM chatter
			investigate_log("The supermatter crystal: [i*0.1]...", INVESTIGATE_SUPERMATTER) // yogs end
		radio.talk_into(src, speaking, common_channel)
		sleep(1 SECONDS)

	delamination_event()

/obj/machinery/power/supermatter_crystal/proc/delamination_event()
	if (is_main_engine)
		SSpersistence.rounds_since_engine_exploded = ROUNDCOUNT_ENGINE_JUST_EXPLODED
		for (var/obj/structure/sign/delamination_counter/sign as anything in GLOB.map_delamination_counters)
			sign.update_count(ROUNDCOUNT_ENGINE_JUST_EXPLODED)
	new /datum/supermatter_delamination(power, combined_gas, get_turf(src), explosion_power, gasmix_power_ratio, antinoblium_attached, resonance_cascading, last_rads, supermatter_blob)

	qdel(src)

/obj/machinery/power/supermatter_crystal/proc/pulsewave()
	var/atom/movable/gravity_lens/shockwave = new(get_turf(src))
	shockwave.transform = matrix().Scale(0.5)
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, alpha = 0, transform = matrix().Scale(20), time = 10 SECONDS, easing = QUAD_EASING)
	QDEL_IN(shockwave, 10.5 SECONDS)

/obj/machinery/power/supermatter_crystal/proc/surge(amount)
	surging = amount
	addtimer(CALLBACK(src, PROC_REF(stopsurging)), rand(30 SECONDS, 2 MINUTES))

/obj/machinery/power/supermatter_crystal/proc/stopsurging()
	surging = 0

/obj/machinery/power/supermatter_crystal/process_atmos()
	var/turf/T = loc

	if(isnull(T))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(T)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	for(var/atom/A in T.contents) // Forbids putting things on the SM
		if(A == src)
			continue
		if(!A.density)
			continue
		Consume(A)

	if(power)
		soundloop.volume = clamp((50 + (power / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((damage / 800) * (power / 2500)), 1.0) * 100
		if(damage >= 300)
			playsound(src, "smdelam", max(50, aggression), FALSE, 10)
		else
			playsound(src, "smcalm", max(50, aggression), FALSE, 10)
		var/next_sound = round((100 - aggression) * 5)
		last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)
	if(isclosedturf(T))
		var/turf/did_it_melt = T.Melt()
		if(!isclosedturf(did_it_melt)) //In case some joker finds way to place these on indestructible walls
			visible_message(span_warning("[src] melts through [T]!"))
		return

	//Ok, get the air from the turf

	var/datum/gas_mixture/env = T.return_air()
	var/datum/gas_mixture/removed

	if(produces_gas)
		//Remove gas from surrounding area
		removed = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		removed = new()

	damage_archived = damage

	if(!removed || !removed.total_moles() || isspaceturf(T)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += max((power / 1000) * DAMAGE_INCREASE_MULTIPLIER, 0.1) // always does at least some damage
	else
		if(takes_damage) //causing damage
			damage = max(damage + (max(clamp(removed.total_moles() / 200, 0.5, 1) * removed.return_temperature() - ((T0C + HEAT_PENALTY_THRESHOLD)*dynamic_heat_resistance), 0) * mole_heat_penalty / 150 ) * DAMAGE_INCREASE_MULTIPLIER, 0)
			damage = max(damage + (max(power - POWER_PENALTY_THRESHOLD, 0)/500) * DAMAGE_INCREASE_MULTIPLIER, 0)
			damage = max(damage + (max(combined_gas - MOLE_PENALTY_THRESHOLD, 0)/80) * DAMAGE_INCREASE_MULTIPLIER, 0)

			//healing damage
			if(combined_gas < MOLE_PENALTY_THRESHOLD)
				damage = max(damage + heal_mod * (min(removed.return_temperature() - (T0C + HEAT_PENALTY_THRESHOLD), 0) / 150 ), 0)

			//capping damage
			damage = damage_mod * min(damage_archived + (DAMAGE_HARDCAP * explosion_point),damage)


		// Calculate the gas mix ratio
		combined_gas = max(removed.total_moles(), 0)

		var/plasmacomp = max(removed.get_moles(GAS_PLASMA)/combined_gas, 0)
		var/o2comp = max(removed.get_moles(GAS_O2)/combined_gas, 0)
		var/co2comp = max(removed.get_moles(GAS_CO2)/combined_gas, 0)
		var/n2ocomp = max(removed.get_moles(GAS_NITROUS)/combined_gas, 0)
		var/n2comp = max(removed.get_moles(GAS_N2)/combined_gas, 0)
		var/pluoxiumcomp = max(removed.get_moles(GAS_PLUOXIUM)/combined_gas, 0)
		var/tritiumcomp = max(removed.get_moles(GAS_TRITIUM)/combined_gas, 0)
		var/bzcomp = max(removed.get_moles(GAS_BZ)/combined_gas, 0)
		var/h2ocomp = max(removed.get_moles(GAS_H2O)/combined_gas, 0)
		var/h2comp = max(removed.get_moles(GAS_H2)/combined_gas, 0)
		var/pluoniumcomp = max(removed.get_moles(GAS_PLUONIUM)/combined_gas, 0)
		var/healcomp = max(removed.get_moles(GAS_HEALIUM)/combined_gas, 0)
		var/zaukcomp = max(removed.get_moles(GAS_ZAUKER)/combined_gas, 0)
		var/haloncomp = max(removed.get_moles(GAS_HALON)/combined_gas, 0)
		var/nobliumcomp = max(removed.get_moles(GAS_HYPERNOB)/combined_gas, 0)
		var/antinobliumcomp = max(removed.get_moles(GAS_ANTINOB)/combined_gas, 0)
		var/nitriumcomp = max(removed.get_moles(GAS_NITRIUM)/combined_gas, 0)
		var/miasmacomp = max(removed.get_moles(GAS_MIASMA)/combined_gas, 0)

		if (healcomp >= 0.1)
			heal_mod = (healcomp * HEALIUM_HEAL_MOD) + 1 //Increases healing and healing cap
		else
			heal_mod = 1

		if (zaukcomp >= 0.05)
			damage_mod = (zaukcomp * ZAUKER_DAMAGE_MOD) + 1 //Increases damage taken and damage cap
		else
			damage_mod = 1

		// Mole releated calculations
		var/bzmol = max(removed.get_moles(GAS_BZ), 0)
		var/nitriummol = max(removed.get_moles(GAS_NITRIUM), 0)
		var/antinobmol = max(removed.get_moles(GAS_ANTINOB), 0)
		var/miasmol = max(removed.get_moles(GAS_MIASMA), 0)

		// Power of the gas. Scale of 0 to 1
		gasmix_power_ratio = clamp(plasmacomp + o2comp + co2comp + tritiumcomp + bzcomp + nitriumcomp + antinobliumcomp - pluoxiumcomp - n2comp, 0, 1)

		// How much heat to emit/resist
		dynamic_heat_modifier = max((plasmacomp * PLASMA_HEAT_PENALTY) + (o2comp * OXYGEN_HEAT_PENALTY) + (co2comp * CO2_HEAT_PENALTY) + (tritiumcomp * TRITIUM_HEAT_PENALTY) + (pluoxiumcomp * PLUOXIUM_HEAT_PENALTY) + (n2comp * NITROGEN_HEAT_PENALTY) + (bzcomp * BZ_HEAT_PENALTY) + (h2ocomp * H2O_HEAT_PENALTY) + (haloncomp * HALON_HEAT_PENALTY) + (antinobliumcomp * ANTINOB_HEAT_PENALTY), 0.5)
		dynamic_heat_resistance = max((n2ocomp * N2O_HEAT_RESISTANCE) + (pluoxiumcomp * PLUOXIUM_HEAT_RESISTANCE) + (h2comp * HYDROGEN_HEAT_RESISTANCE) + (pluoniumcomp * PLUONIUM_HEAT_RESISTANCE) + (nobliumcomp * NOBLIUM_HEAT_RESISTANCE), 1)

		// Used to determine radiation output as it concerns things like collecters
		var/power_transmission_bonus = (plasmacomp * PLASMA_TRANSMIT_MODIFIER) + (o2comp * OXYGEN_TRANSMIT_MODIFIER) + (bzcomp * BZ_TRANSMIT_MODIFIER) + (tritiumcomp * TRITIUM_TRANSMIT_MODIFIER) + (pluoxiumcomp * PLUOXIUM_TRANSMIT_MODIFIER) + (pluoniumcomp * PLUONIUM_TRANSMIT_MODIFIER) + (nitriumcomp * NITRIUM_TRANSMIT_MODIFIER) + (antinobliumcomp * ANTINOB_TRANSMIT_MODIFIER)
		// More moles of gases are harder to heat than fewer, so let's scale heat damage around them
		mole_heat_penalty = max(combined_gas / MOLE_HEAT_PENALTY, 0.25)

		if (combined_gas > POWERLOSS_INHIBITION_MOLE_THRESHOLD && co2comp > POWERLOSS_INHIBITION_GAS_THRESHOLD)
			powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling + clamp(co2comp - powerloss_dynamic_scaling, -0.02, 0.02), 0, 1)
		else
			powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling - 0.05,0, 1)

		if(support_integrity >= 10 && (!supermatter_blob || check_containment(src, 5)))
			powerloss_inhibitor = clamp(1-(powerloss_dynamic_scaling * clamp(combined_gas/POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD,1 ,1.5)),0 ,1)

		if(matter_power)
			var/removed_matter = max(matter_power/MATTER_POWER_CONVERSION, 40)
			power = max(power + removed_matter, 0)
			matter_power = max(matter_power - removed_matter, 0)

		if(surging)
			power += surging

		if(gasmix_power_ratio > 0.8)
			// with a perfect gas mix, make the power less based on heat
			icon_state = "[initial(icon_state)]_glow"
			temp_factor = 50
		else
			// in normal mode, base the produced energy around the heat
			temp_factor = 30
			icon_state = initial(icon_state)

		power = clamp((removed.return_temperature() * temp_factor / T0C) * gasmix_power_ratio + power, 0, SUPERMATTER_MAXIMUM_ENERGY) //Total laser power plus an overload

		if(prob(50))
			//1 + (tritRad + pluoxDampen * bzDampen * o2Rad * plasmaRad / (10 - bzrads))
			last_rads = power * (1 + (tritiumcomp * TRITIUM_RADIOACTIVITY_MODIFIER) + (((pluoxiumcomp ** 2) * PLUOXIUM_RADIOACTIVITY_MODIFIER)) * (power_transmission_bonus/(10-(bzcomp * BZ_RADIOACTIVITY_MODIFIER)))) * radmodifier
			radiation_pulse(src, max(last_rads))

		if(nitriummol > NITRO_BALL_MOLES_REQUIRED) // haha funny particles go brrrrr
			var/balls_shot = min(round(nitriummol / NITRO_BALL_MOLES_REQUIRED), NITRO_BALL_MAX_REACT_RATE / NITRO_BALL_MOLES_REQUIRED)
			var/starting_angle = rand(0, 360)
			for(var/i = 0 to balls_shot) //  fires particles in a ring, with some random variation in the angle
				src.fire_nuclear_particle(starting_angle + rand(-180/balls_shot, 180/balls_shot) + (i * 360 / balls_shot))
			removed.set_moles(GAS_NITRIUM, max(nitriummol - (balls_shot * NITRO_BALL_MOLES_REQUIRED), 0)) //converts stimulum into radballs

		if(bzcomp >= 0.4 && prob(50 * bzcomp))
			src.fire_nuclear_particle()			// Start to emit radballs at a maximum of 50% chance per tick
			var/rps = round((bzmol/150), 1) 	// Cause more radballs to be spawned
			for(var/i = 1 to rps)
				if(prob(80))
					src.fire_nuclear_particle()	// Spawn more radballs at 80% chance each

		if(antinobliumcomp >= 0.5 && antinobmol > 100 && nobliumcomp < 0.5 && !antinoblium_attached) // don't put this stuff in the SM
			investigate_log("[src] has reached criticial antinoblium concentration and started a resonance cascade.", INVESTIGATE_SUPERMATTER)
			message_admins("[src] has reached criticial antinoblium concentration and started a resonance cascade.")
			antinoblium_attached = TRUE // oh god oh fuck

		if (miasmacomp >= 0.5 && miasmol > 500 && !supermatter_blob) //requires around 4500 mol of miasma for the blob
			supermatter_blob = TRUE // you are fucked
			damage += 50
			supermatter_zap(src, 10, 7000)

		// adding enough hypernoblium can save it, but only if it hasn't gotten too bad and it wasn't corrupted using the traitor kit
		if(nobliumcomp >= 0.5 && antinoblium_attached && !corruptor_attached && support_integrity > 10 && damage <= damage_archived)
			support_integrity += 2
			if(support_integrity >= 100)
				support_integrity = 100
				antinoblium_attached = FALSE
				radio.use_command = FALSE
			noblium_suppressed = TRUE
		else
			noblium_suppressed = FALSE

		if((supermatter_blob || antinoblium_attached) && !radio.use_command)
			radio.use_command = TRUE

		var/device_energy = power * REACTION_POWER_MODIFIER

		//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
		//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
		//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
		//Since the core is effectively "cold"

		//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
		//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
		removed.set_temperature(removed.return_temperature() + ((device_energy * dynamic_heat_modifier) / THERMAL_RELEASE_MODIFIER))

		removed.set_temperature(max(0, min(removed.return_temperature(), 2500 * dynamic_heat_modifier)))

		//Calculate how much gas to release, antinoblium seeded SM produces much more gas

		if(antinoblium_attached || supermatter_blob)
			removed.adjust_moles(GAS_PLASMA, max(((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER) * (1+(100-support_integrity)/25), 0))
			removed.adjust_moles(GAS_O2, max((((device_energy + removed.return_temperature() * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER) * (1+(100-support_integrity)/25), 0))
		else if(haloncomp >= 0.15)
			removed.adjust_moles(GAS_PLASMA, max((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER, 0))
			removed.adjust_moles(GAS_O2, max(((device_energy + removed.return_temperature() * dynamic_heat_modifier) - T0C) / PLASMA_RELEASE_MODIFIER, 0)) // Supresses Oxygen Generation
		else
			removed.adjust_moles(GAS_PLASMA, max((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER, 0))
			removed.adjust_moles(GAS_O2, max(((device_energy + removed.return_temperature() * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER, 0))

		if(produces_gas)
			env.merge(removed)

	visible_hallucination_pulse(
		center = src,
		radius = HALLUCINATION_RANGE(power),
		hallucination_duration = power * 0.1,
		hallucination_max_duration = 400 SECONDS,
	)

	power -= ((power/500)**3) * powerloss_inhibitor

	// Checks if the status has changed, in order to update the displacement effect
	var/current_status = get_status()
	if(current_status != last_status)
		last_status = current_status
		update_icon(UPDATE_OVERLAYS)

	if(power > POWER_PENALTY_THRESHOLD || damage > damage_penalty_point)
		if(power > POWER_PENALTY_THRESHOLD)
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
			supermatter_zap(src, 5, min(power*2, 20000))
			supermatter_zap(src, 5, min(power*2, 20000))
			if(power > SEVERE_POWER_PENALTY_THRESHOLD)
				supermatter_zap(src, 5, min(power*2, 20000))
				if(power > CRITICAL_POWER_PENALTY_THRESHOLD)
					supermatter_zap(src, 5, min(power*2, 20000))
		else if (damage > damage_penalty_point && prob(20))
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
			supermatter_zap(src, 5, clamp(power*2, 4000, 20000))

		if(prob(15) && (power > POWER_PENALTY_THRESHOLD || combined_gas > MOLE_PENALTY_THRESHOLD || antinoblium_attached || (supermatter_blob && !check_containment(src, 5))))
			supermatter_pull(src, power/750)
		if(prob(5) || (antinoblium_attached || (supermatter_blob && !check_containment(src, 5))) && prob(10))
			supermatter_anomaly_gen(src, ANOMALY_FLUX, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1) || (antinoblium_attached || (supermatter_blob && !check_containment(src, 5))) && prob(10))
			supermatter_anomaly_gen(src, ANOMALY_GRAVITATIONAL, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(2) || prob(0.3) && power > POWER_PENALTY_THRESHOLD || (antinoblium_attached || (supermatter_blob && !check_containment(src, 5))) && prob(10))
			supermatter_anomaly_gen(src, ANOMALY_PYRO, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(0.5) || (antinoblium_attached || (supermatter_blob && !check_containment(src, 5))) && prob(10))
			supermatter_anomaly_gen(src, ANOMALY_RADIATION, rand(5, 10))

	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if(damage_archived < warning_point) //If damage_archive is under the warning point, this is the very first cycle that we've reached said point.
			SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_START_ALARM)
		if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_DELAY)
			alarm()

			if(damage > emergency_point)
				if(corruptor_attached)
					radio.talk_into(src, "[warning_alert] Integrity: [get_fake_integrity()]%!", common_channel)
				else
					radio.talk_into(src, "[emergency_alert] Integrity: [get_integrity()]%.", common_channel)
				SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_ALARM)
				log_game("The supermatter crystal: [emergency_alert] Integrity: [get_integrity()]%") // yogs start - Logs SM chatter
				investigate_log("The supermatter crystal: [emergency_alert] Integrity: [get_integrity()]%", INVESTIGATE_SUPERMATTER) // yogs end
				lastwarning = REALTIMEOFDAY
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", INVESTIGATE_SUPERMATTER)
					message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
					has_reached_emergency = TRUE
			else if(damage >= damage_archived) // The damage is still going up
				if(corruptor_attached)
					radio.talk_into(src, "[warning_alert] Integrity: [get_fake_integrity()]%!", engineering_channel)
				else
					radio.talk_into(src, "[warning_alert] Integrity: [get_integrity()]%.", engineering_channel)
				SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_ALARM)
				log_game("The supermatter crystal: [warning_alert] Integrity: [get_integrity()]%") // yogs start - Logs SM chatter
				investigate_log("The supermatter crystal: [warning_alert] Integrity: [get_integrity()]%", INVESTIGATE_SUPERMATTER) // yogs end
				lastwarning = REALTIMEOFDAY - (WARNING_DELAY * 5)
			else	// Phew, we're safe
				if(corruptor_attached)
					radio.talk_into(src, "[warning_alert] Integrity: [get_fake_integrity()]%!", engineering_channel)
				else
					radio.talk_into(src, "[safe_alert] Integrity: [get_integrity()]%", engineering_channel)
				log_game("The supermatter crystal: [safe_alert] Integrity: [get_integrity()]%") // yogs start - Logs SM chatter
				investigate_log("The supermatter crystal: [safe_alert] Integrity: [get_integrity()]%", INVESTIGATE_SUPERMATTER) // yogs end
				lastwarning = REALTIMEOFDAY

			if(power > POWER_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Hyperstructure has reached dangerous power level.", engineering_channel)
				log_game("The supermatter crystal: Warning: Hyperstructure has reached dangerous power level.") // yogs start - Logs SM chatter
				investigate_log("The supermatter crystal: Warning: Hyperstructure has reached dangerous power level.", INVESTIGATE_SUPERMATTER) // yogs end
				if(powerloss_inhibitor < 0.5)
					radio.talk_into(src, "DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.", engineering_channel)
					log_game("The supermatter crystal: DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.") // yogs start - Logs SM chatter
					investigate_log("The supermatter crystal: DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.", INVESTIGATE_SUPERMATTER) // yogs end

			if(combined_gas > MOLE_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Critical coolant mass reached.", engineering_channel)
				log_game("The supermatter crystal: Warning: Critical coolant mass reached.") // yogs start - Logs SM chatter
				investigate_log("The supermatter crystal: Warning: Critical coolant mass reached.", INVESTIGATE_SUPERMATTER) // yogs end

			if(supermatter_blob)
				if(!check_containment(src, 5))
					radio.talk_into(src, "DANGER: BIOHAZARD DETECTED, VACATE THE CHAMBER IMMEDIATELY.", engineering_channel)
					log_game("The supermatter crystal: DANGER: BIOHAZARD DETECTED, VACATE THE CHAMBER IMMEDIATELY.") // yogs start - Logs SM chatter
					investigate_log("The supermatter crystal: DANGER: BIOHAZARD DETECTED, VACATE THE CHAMBER IMMEDIATELY.", INVESTIGATE_SUPERMATTER) // yogs end
				else
					radio.talk_into(src, "WARNING: CONTROLLED BIOHAZARD DETECTED, PROCEED WITH CAUTION.", engineering_channel)
					log_game("The supermatter crystal: WARNING: CONTROLLED BIOHAZARD DETECTED, PROCEED WITH CAUTION.") // yogs start - Logs SM chatter
					investigate_log("The supermatter crystal: WARNING: CONTROLLED BIOHAZARD DETECTED, PROCEED WITH CAUTION.", INVESTIGATE_SUPERMATTER) // yogs end
				if(damage >= emergency_point)
					radio.talk_into(src, "DANGER: SUPERMATTER BIOHAZARD LEVELS HAVE EXCEEDED SAFETY THRESHOLDS.", common_channel)
					log_game("DANGER: SUPERMATTER BIOHAZARD LEVELS HAVE EXCEEDED SAFETY THRESHOLDS.") // yogs start - Logs SM chatter
					investigate_log("DANGER: SUPERMATTER BIOHAZARD LEVELS HAVE EXCEEDED SAFETY THRESHOLDS.", INVESTIGATE_SUPERMATTER) // yogs end

			if(antinoblium_attached)
				if(support_integrity <= 10)
					radio.talk_into(src, "DANGER: RESONANCE CASCADE IMMINENT.", engineering_channel)
					log_game("The supermatter crystal: DANGER: RESONANCE CASCADE IMMINENT.") // yogs start - Logs SM chatter
					investigate_log("The supermatter crystal: DANGER: RESONANCE CASCADE IMMINENT.", INVESTIGATE_SUPERMATTER) // yogs end
				else if(noblium_suppressed)
					radio.talk_into(src, "Paranoblium interface returning to safe operating parameters.", engineering_channel)
					log_game("The supermatter crystal: DANGER: RESONANCE CASCADE IMMINENT.") // yogs start - Logs SM chatter
					investigate_log("The supermatter crystal: DANGER: RESONANCE CASCADE IMMINENT.", INVESTIGATE_SUPERMATTER) // yogs end

		if(damage > explosion_point)
			countdown()

	//blob SM HAMMM
	if(supermatter_blob)
		if(!check_containment(src, 5))
			powerloss_inhibitor = 0.01
			power += 10000
			if(prob(2))
				empulse(src, 10, 5)
			if(prob(30))
				radiation_pulse(src, 5000, 4)
				pulsewave()
				T.hotspot_expose(max(500+FIRE_MINIMUM_TEMPERATURE_TO_EXIST,T.return_air().return_temperature()), 100)
				playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
				supermatter_zap(src, 5, power)
				for(var/i = 1 to 20)
					fire_nuclear_particle()
		if(istype(T, /turf/open/space) || T.return_air().total_moles() < MOLE_SPACE_THRESHOLD)
			damage += DAMAGE_HARDCAP * explosion_point

	//emagged SM go BRRRRRRR here
	if(antinoblium_attached && !noblium_suppressed)
		if(prob(10+round(damage/(explosion_point/20),1)*3) & support_integrity>0)//radio chatter to make people panic
			switch(support_integrity)
				if(100)
					radio.talk_into(src, "CORRUPTION OF PRIMARY SUPERMATTER SUPPORT INFRASTRUCTURE DETECTED!", engineering_channel)
				if(90)
					radio.talk_into(src, "CHARGE SEQUESTRATION SYSTEM FAILING, ENERGY LEVELS INCREASING!", engineering_channel)
				if(80)
					radio.talk_into(src, "COMPLETE FAILURE OF CHARGE SEQUESTRATION IMMINENT, ACTIVATING EMERGENCY CHARGE DISPERSION SYSTEM!", engineering_channel)
				if(70)
					radio.talk_into(src, "CHARGE DISPERSION SYSTEM ACTIVE. CORRUPTION OF PARANOBLIUM INTERFACE SYSTEM DETECTED, MATTER EMISSION LEVELS RISING.", engineering_channel)
				if(60)
					radio.talk_into(src, "PARANOBLIUM INTERFACE OPERATING AT [round(75+ rand()*10,0.01)]% CAPACITY, MATTER EMISSION FACTOR RISING.", engineering_channel)
				if(50)
					radio.talk_into(src, "COMPLETE FAILURE OF GAMMA RADIATION SUPPRESSION SYSTEM DETECTED, ACTIVATING GAMMA EMISSION BUNDLING AND DISPERSION SYSTEM.", engineering_channel)
				if(40)
					radio.talk_into(src, "DISPERSION SYSTEM ACTIVATION FAILED, BUNDLER NOW FIRING WITHOUT GUIDANCE.", engineering_channel)
					priority_announce("SUPERMATTER INSTABILITY IS AT 60%, PULSEWAVE IMMINENT.", "Anomaly Alert", 'sound/misc/notice1.ogg')
				if(30)
					radio.talk_into(src, "WARNING ENERGY SPIKE IN CRYSTAL WELL DETECTED, ESTIMATED ENERGY OUTPUT EXCEEDS PEAK CHARGE DISPERSION CAPACITY.", engineering_channel)
				if(20)
					radio.talk_into(src, "CRYSTAL WELL DESTABILIZED, ELECTROMAGNETIC PULSES INBOUND, PARANOBLIUM INTERFACE OPERATING AT [round(15+ rand()*10,0.01)]% CAPACITY.", common_channel)
				if(10)
					radio.talk_into(src, "ELECTROMAGNETIC FIELD CONTAINMENT FAILED, PARANOBLIUM INTERFACE NONFUNCTIONAL, RESONANCE CASCADE IMMINENT.", common_channel)
					priority_announce("SUPERMATTER INSTABILITY IS AT 90%, SUPERMATTER SURGE DETECTED, VACATE THE AREA IMMEDIATELY.", "Anomaly Alert", 'sound/misc/notice1.ogg')
				if(6)
					radio.talk_into(src, "ELECTROMAGNETIC PULSES IMMINENT, CONTAINMENT AND COOLING FAILURE IMMINENT.", common_channel)
				if(1)
					priority_announce("COMPLETE DESTABILIZATION OF ALL MAJOR SUPPORT SYSTEMS, MATTER EMISSION FACTOR AT 600%, COMPLETE EVACUATION IS ADVISED.", "Anomaly Alert", 'sound/misc/notice1.ogg')
			support_integrity -= 1
			radiation_pulse(src, (100-support_integrity)*2, 4)
			if(support_integrity<3)
				var/emp_power = round(explosion_power * (1+(1-(support_integrity/3))),1)
				empulse(src, emp_power)
		if(support_integrity<100)
			power += round((100-support_integrity)/2,1)
		if(support_integrity<70)
			if(prob(30+round((100-support_integrity)/2,1)))
				playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
				supermatter_zap(src, 5, min(power*2, 20000))
		if(support_integrity<40)
			if(prob(10))
				T.hotspot_expose(max(((100-support_integrity)*2)+FIRE_MINIMUM_TEMPERATURE_TO_EXIST,T.return_air().return_temperature()), 100)
			if(prob(10+round(support_integrity/10,1)))
				pulsewave()
				var/ballcount = round(10-(support_integrity/10), 1) // Cause more radballs to be spawned
				for(var/i = 1 to ballcount)
					fire_nuclear_particle()
		if(support_integrity<10)
			powerloss_inhibitor = 0.01 //ensure big explosion
			surging = 10000
			if(istype(T, /turf/open/space) || T.return_air().total_moles() < MOLE_SPACE_THRESHOLD)
				damage += DAMAGE_HARDCAP * explosion_point //Can't cheat by spacing the crystal to buy time, it will just delaminate faster
			if(prob(2))
				empulse(src, 10-support_integrity) //EMPs must always be spewing every so often to ensure that containment is guaranteed to fail.
	
	// I FUCKING LOVE DATA!!!!!!
	powerData += power
	if(powerData.len > 100)
		powerData.Cut(1, 2)
	radsData += last_rads
	if(radsData.len > 100)
		radsData.Cut(1, 2)
	tempData += env.return_temperature()
	if(tempData.len > 100)
		tempData.Cut(1, 2)
	kpaData += env.return_pressure()
	if(kpaData.len > 100)
		kpaData.Cut(1, 2)
	molesData += env.total_moles()
	if(molesData.len > 100)
		molesData.Cut(1, 2)

	return 1

/obj/machinery/power/supermatter_crystal/bullet_act(obj/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))
		return FALSE
	if(istype(Proj.firer, /mob/living)) //yogs start - supermatter stuff
		investigate_log("has been hit by [Proj] fired by [key_name(Proj.firer)]", INVESTIGATE_SUPERMATTER) // yogs end
	if(Proj.armor_flag != BULLET)
		power += Proj.damage * config_bullet_energy
		if(!has_been_powered)
			investigate_log("has been powered for the first time.", INVESTIGATE_SUPERMATTER)
			message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
			has_been_powered = TRUE
			var/datum/department_goal/eng/additional_supermatter/goal = locate() in SSYogs.department_goals
			if(goal)
				goal.complete()

	else if(takes_damage)
		damage += Proj.damage * config_bullet_energy
	return BULLET_ACT_HIT

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.", INVESTIGATE_SINGULO)
	investigate_log("Supermatter shard consumed by singularity.", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is actually useful
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[src] is consumed by the singularity!"))
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			SEND_SOUND(M, 'sound/effects/supermatter.ogg') //everyone goan know bout this
			to_chat(M, span_boldannounce("A horrible screeching fills your ears, and a wave of dread washes over you..."))
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/blob_act(obj/structure/blob/B)
	if(B && !isspaceturf(loc)) //does nothing in space
		damage += B.get_integrity() * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
		if(B.get_integrity() > 100)
			B.visible_message(span_danger("\The [B] strikes at \the [src] and flinches away!"),\
			span_italics("You hear a loud crack as you are washed with a wave of heat."))
			B.take_damage(100, BURN)
		else
			B.visible_message(span_danger("\The [B] strikes at \the [src] and rapidly flashes to ash."),\
			span_italics("You hear a loud crack as you are washed with a wave of heat."))
			Consume(B)

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/datum/brain_trauma/mild/reality_dissociation/T = new()
		var/obj/item/organ/brain/B = locate(/obj/item/organ/brain) in C.internal_organs
		B.name = "supermatter-fried [B.name]"
		C.emote("scream")
		C.visible_message(span_danger("[C.name] screams in horror as [C.p_their()] mind is consumed by [src]!"))
		C.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)
		to_chat(C, span_userdanger("That was a really dense idea."))
		switch(rand(1,8))
			if(1 to 3)
				C.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
				C.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
			if(4 to 6)
				C.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
			if(7 to 8)
				C.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_LOBOTOMY)
		C.adjustOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH)

/obj/machinery/power/supermatter_crystal/attack_paw(mob/user)
	dust_mob(user, cause = "monkey attack")

/obj/machinery/power/supermatter_crystal/attack_alien(mob/user)
	dust_mob(user, cause = "alien attack")

/obj/machinery/power/supermatter_crystal/attack_animal(mob/living/simple_animal/S)
	var/murder
	if(!S.melee_damage_upper && !S.melee_damage_lower)
		murder = S.friendly
	else
		murder = S.attacktext
	dust_mob(S, \
	span_danger("[S] unwisely [murder] [src], and [S.p_their()] body burns brilliantly before flashing into ash!"), \
	span_userdanger("You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops."), \
	"simple animal attack")

/obj/machinery/power/supermatter_crystal/attack_robot(mob/user)
	if(Adjacent(user))
		dust_mob(user, cause = "cyborg attack")

/obj/machinery/power/supermatter_crystal/attack_ai(mob/user)
	return

/obj/machinery/power/supermatter_crystal/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incorporeal_move || user.status_flags & GODMODE)
		return

	. = TRUE
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		dust_mob(user, cause = "hand")
		return

	if(!user.is_mouth_covered())
		if(user.combat_mode)
			dust_mob(user,
				"<span class='danger'>As [user] tries to take a bite out of [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash.</span>",
				"<span class='userdanger'>You try to take a bite out of [src], but find [p_them()] far too hard to get anywhere before everything starts burning and your ears fill with ringing!</span>",
				"attempted bite"
			)
			return

		var/obj/item/organ/tongue/licking_tongue = user.getorganslot(ORGAN_SLOT_TONGUE)
		if(licking_tongue)
			dust_mob(user,
				"<span class='danger'>As [user] hesitantly leans in and licks [src] everything goes silent before [user.p_their()] body starts to glow and burst into flames before flashing to ash!</span>",
				"<span class='userdanger'>You tentatively lick [src], but you can't figure out what it tastes like before everything starts burning and your ears fill with ringing!</span>",
				"attempted lick"
			)
			return

	var/obj/item/bodypart/head/forehead = user.get_bodypart(BODY_ZONE_HEAD)
	if(forehead)
		dust_mob(user,
			"<span class='danger'>As [user]'s forehead bumps into [src], inducing a resonance... Everything goes silent before [user.p_their()] [forehead] flashes to ash!</span>",
			"<span class='userdanger'>You feel your forehead bump into [src] and everything suddenly goes silent. As your head fills with ringing you come to realize that that was not a wise decision.</span>",
			"failed lick"
		)
		return

	dust_mob(user,
		"<span class='danger'>[user] leans in and tries to lick [src], inducing a resonance... [user.p_their()] body starts to glow and burst into flames before flashing into dust!</span>",
		"<span class='userdanger'>You lean in and try to lick [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",
		"failed lick"
	)

/obj/machinery/power/supermatter_crystal/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || nom.status_flags & GODMODE)
		return
	if(!vis_msg)
		vis_msg = span_danger("[nom] reaches out and touches [src], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!")
	if(!mob_msg)
		mob_msg = span_userdanger("You reach out and touch [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"")
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, span_italics("You hear an unearthly noise as a wave of heat washes over you."))
	investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_SUPERMATTER)
	Consume(nom)

/obj/machinery/power/supermatter_crystal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(W, /obj/item/melee/roastingstick))
		return ..()
	if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = W
		var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
		if(clumsy)
			var/which_hand = BODY_ZONE_L_ARM
			if(!(user.active_hand_index % 2))
				which_hand = BODY_ZONE_R_ARM
			var/obj/item/bodypart/dust_arm = user.get_bodypart(which_hand)
			dust_arm.dismember()
			user.visible_message(span_danger("The [W] flashes out of existence on contact with \the [src], resonating with a horrible sound..."),\
				span_danger("Oops! The [W] flashes out of existence on contact with \the [src], taking your arm with it! That was clumsy of you!"))
			Consume(dust_arm)
			qdel(W)
			return
		if(cig.lit || user.combat_mode)
			user.visible_message(span_danger("A hideous sound echoes as [W] is ashed out on contact with \the [src]. That didn't seem like a good idea..."))
			Consume(W)
			radiation_pulse(src, 150, 4)
			return ..()
		else
			cig.light()
			user.visible_message(span_danger("As [user] lights \their [W] on \the [src], silence fills the room..."),\
				"[span_danger("Time seems to slow to a crawl as you touch \the [src] with \the [W].")]\n[span_notice("\The [W] flashes alight with an eerie energy as you nonchalantly lift your hand away from \the [src]. Damn.")]")
			playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
			radiation_pulse(src, 50, 3)
			return
	if(istype(W, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = W
		to_chat(user, span_notice("You carefully begin to scrape \the [src] with \the [W]..."))
		if(W.use_tool(src, user, 60, volume=100))
			if (scalpel.usesLeft)
				to_chat(user, span_danger("You extract a sliver from \the [src]. \The [src] begins to react violently!"))
				investigate_log("[key_name(user)] extracts a sliver of \the [src].", INVESTIGATE_SUPERMATTER)//Yogs -- SM sliver logs
				message_admins("[key_name(user)] extracted a sliver of \the [src].")//Yogs -- SM sliver logs
				new /obj/item/nuke_core/supermatter_sliver(drop_location())
				matter_power += 800
				scalpel.usesLeft--
				if (!scalpel.usesLeft)
					to_chat(user, span_notice("A tiny piece of \the [W] falls off, rendering it useless!"))
			else
				to_chat(user, span_notice("You fail to extract a sliver from \The [src]. \the [W] isn't sharp enough anymore!"))
			return
	if(istype(W, /obj/item/hemostat/supermatter))
		to_chat(user, span_boldwarning("[W]'s tongs produce an unhealthy sizzling sound as they come into contact with [src]; it seems you will need to part a sample from [src] with another tool."))
		return
	if(istype(W, /obj/item/supermatter_corruptor))
		if(corruptor_attached)
			to_chat(user, "A corruptor is already attached!")
			return
		to_chat(user, "You attach the corruptor to the support structure, disrupting the paranoblium interface and allowing the addition of the antinoblium shard.")
		corruptor_attached = TRUE
		qdel(W)
		return
	if(istype(W, /obj/item/hemostat/antinoblium))
		var/obj/item/hemostat/antinoblium/cached = W
		if(!cached.shard)
			to_chat(user, "You have nothing to attach to the supermatter!")
			return
		if(!corruptor_attached)
			to_chat(user, "The paranoblium interface prevents you from adding the shard! Attach a corruptor to disrupt it!")
			return
		if(antinoblium_attached)
			to_chat(user, "An antinoblium shard has already been attached to the supermatter crystal!")
			return
		antinoblium_attached = TRUE
		investigate_log("[user] has attached an antinoblium shard to the SM.", INVESTIGATE_SUPERMATTER)
		message_admins("Antinoblium shard has been attached to the SM and is now going BRRRRRR.")
		to_chat(user, "<span class='danger'>You attach the antinoblium shard to the [src], moving your hand away before a sudden gravitational wave pulls the [W] into the crystal as it flashes to ash!")
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)
		radiation_pulse(src, 150, 4)
		empulse(src, EMP_HEAVY, 6)
		qdel(W)
		return
	if(istype(W, /obj/item/demon_core))
		investigate_log("[user] has inserted demon core into the SM, doubling it's rad production.")
		to_chat(user,"<span class='danger'>You insert the demon core into the [src], it begins to glow with dark purple fire, you notice the area around you noticeably heating up...")
		radmodifier *= 2
		add_overlay(mutable_appearance('yogstation/icons/effects/effects.dmi',"tar_shield"))
		qdel(W)
	else if(user.dropItemToGround(W))
		user.visible_message(span_danger("As [user] touches \the [src] with \a [W], silence fills the room..."),\
			"[span_userdanger("You touch \the [src] with \the [W], and everything suddenly goes silent.")]\n[span_notice("\The [W] flashes into dust as you flinch away from \the [src].")]",\
			span_italics("Everything suddenly goes silent."))
		investigate_log("has been attacked ([W]) by [key_name(user)]", INVESTIGATE_SUPERMATTER)
		Consume(W)
		radiation_pulse(src, 150, 4)

/obj/machinery/power/supermatter_crystal/wrench_act(mob/user, obj/item/tool)
	if (moveable)
		default_unfasten_wrench(user, tool, time = 20)
	return TRUE

/obj/machinery/power/supermatter_crystal/Bump(atom/A)
	if (ismovable(A))
		var/atom/movable/AM = A
		Bumped(AM)

/obj/machinery/power/supermatter_crystal/Bumped(atom/movable/AM)
	if(isliving(AM))
		AM.visible_message(span_danger("\The [AM] slams into \the [src] inducing a resonance... [AM.p_their()] body starts to glow and burst into flames before flashing into dust!"),\
		span_userdanger("You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),\
		span_italics("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(AM) && !iseffect(AM))
		AM.visible_message(span_danger("\The [AM] smacks into \the [src] and rapidly flashes to ash."), null,\
		span_italics("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	Consume(AM)

/obj/machinery/power/supermatter_crystal/proc/Consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		if(user.status_flags & GODMODE)
			return
		if(messages_admins || user.client)
			message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_SUPERMATTER)
		user.dust(force = TRUE)
		matter_power += 200
	else if(istype(AM, /obj/singularity))
		return
	else if(isobj(AM))
		if(!iseffect(AM))
			var/suspicion = ""
			if(AM.fingerprintslast)
				suspicion = "last touched by [AM.fingerprintslast]"
				if(messages_admins)
					message_admins("[src] has consumed [AM], [suspicion] [ADMIN_JMP(src)].")
			investigate_log("has consumed [AM] - [suspicion].", INVESTIGATE_SUPERMATTER)
		qdel(AM)
	if(!iseffect(AM))
		matter_power += 200

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(src, 3000, 2, TRUE)
	for(var/mob/living/L in range(10))
		investigate_log("has irradiated [key_name(L)] after consuming [AM].", INVESTIGATE_SUPERMATTER)
		if(L in view())
			L.show_message(span_danger("As \the [src] slowly stops resonating, you find your skin covered in new radiation burns."), MSG_VISUAL,\
				span_danger("The unearthly ringing subsides and you notice you have new radiation burns."), MSG_AUDIBLE)
		else
			L.show_message(span_italics("You hear an unearthly ringing and notice your skin is covered in fresh radiation burns."), MSG_AUDIBLE)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

//Do not blow up our internal radio
/obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
	return

/obj/machinery/power/supermatter_crystal/engine
	is_main_engine = TRUE

/obj/machinery/power/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure."
	icon_state = "darkmatter_shard"
	anchored = FALSE
	gasefficency = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE

/obj/machinery/power/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

// When you wanna make a supermatter shard for the dramatic effect, but
// don't want it exploding suddenly
/obj/machinery/power/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	takes_damage = FALSE
	produces_gas = FALSE
	moveable = FALSE
	anchored = TRUE

/obj/machinery/power/supermatter_crystal/shard/hugbox/fakecrystal //Hugbox shard with crystal visuals, used in the Supermatter/Hyperfractal shuttle
	name = "supermatter crystal"
	icon_state = "darkmatter"

// Base stucture if you want to build a supermatter shard engine
// Will require one supermatter shard
/obj/structure/supermatter_base_structure
	name = "supermatter base structure"
	desc = "A tremendously strong, robust, and environment-resistant structure formed of condensed metallic hydrogen. A supermatter shard can fit inside the condensed hyper-noblium container on top of this structure."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter_base"
	density = TRUE
	max_integrity = 500
	armor = list(MELEE = 70, BULLET = 70, LASER = 70, ENERGY = 70, BOMB = 80, BIO = 70, RAD = 70, FIRE = 10, ACID = 10)
	var/stage = 1

/obj/machinery/power/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 10)
	playsound(src.loc, 'sound/weapons/marauder.ogg', 100, 1, extrarange = 7)
	for(var/atom/movable/P in orange(pull_range,center))
		if(P.anchored || P.move_resist >= MOVE_FORCE_EXTREMELY_STRONG) //move resist memes.
			return
		if(ishuman(P))
			var/mob/living/carbon/human/H = P
			if(H.incapacitated() || !(H.mobility_flags & MOBILITY_STAND) || H.mob_negates_gravity())
				return //You can't knock down someone who is already knocked down or has immunity to gravity
			H.visible_message(span_danger("[H] is suddenly knocked down, as if [H.p_their()] [(H.get_num_legs() == 1) ? "leg had" : "legs have"] been pulled out from underneath [H.p_them()]!"),\
				span_userdanger("A sudden gravitational pulse knocks you down!"),\
				span_italics("You hear a thud."))
			H.apply_effect(40, EFFECT_PARALYZE, 0)
		else //you're not human so you get sucked in
			step_towards(P,center)
			step_towards(P,center)
			step_towards(P,center)
			step_towards(P,center)

/proc/supermatter_anomaly_gen(turf/anomalycenter, type = ANOMALY_FLUX, anomalyrange = 5, has_weak_lifespan = TRUE)
	var/turf/local_turf = pick(RANGE_TURFS(anomalyrange, anomalycenter) - anomalycenter)
	if(!local_turf)
		return

	switch(type)
		if(ANOMALY_FLUX)
			new /obj/effect/anomaly/flux(local_turf, has_weak_lifespan ? rand(250, 300) : null)
		if(ANOMALY_FLUX_EXPLOSIVE)
			new /obj/effect/anomaly/flux/explosion(local_turf, has_weak_lifespan ? rand(250, 300) : null)
		if(ANOMALY_GRAVITATIONAL)
			new /obj/effect/anomaly/grav(local_turf, has_weak_lifespan ? rand(250, 300) : null)
		if(ANOMALY_PYRO)
			new /obj/effect/anomaly/pyro(local_turf, has_weak_lifespan ? rand(250, 300) : null)
		if(ANOMALY_VORTEX)
			new /obj/effect/anomaly/bhole(local_turf, has_weak_lifespan ? rand(250, 300) : null)
		if(ANOMALY_RADIATION)
			new /obj/effect/anomaly/radiation(local_turf, has_weak_lifespan ? rand(250, 300) : null)
		if(ANOMALY_RADIATION_X)
			new /obj/effect/anomaly/radiation/goat(local_turf, has_weak_lifespan ? rand(250, 300) : null)

/obj/machinery/proc/supermatter_zap(atom/zapstart, range = 3, power)
	. = zapstart.dir

	if(power < 1000)
		return

	var/target_atom
	var/mob/living/target_mob
	var/obj/machinery/target_machine
	var/obj/structure/target_structure
	var/list/arctargetsmob = list()
	var/list/arctargetsmachine = list()
	var/list/arctargetsstructure = list()

	if(prob(20)) //let's not hit all the engineers with every beam and/or segment of the arc
		for(var/mob/living/Z in oview(zapstart, range+2))
			arctargetsmob += Z

	if(arctargetsmob.len)
		var/mob/living/H = pick(arctargetsmob)
		var/atom/A = H
		target_mob = H
		target_atom = A
	else
		for(var/obj/machinery/X in oview(zapstart, range+2))
			arctargetsmachine += X

		if(arctargetsmachine.len)
			var/obj/machinery/M = pick(arctargetsmachine)
			var/atom/A = M
			target_machine = M
			target_atom = A
		else
			for(var/obj/structure/Y in oview(zapstart, range+2))
				arctargetsstructure += Y

			if(arctargetsstructure.len)
				var/obj/structure/O = pick(arctargetsstructure)
				var/atom/A = O
				target_structure = O
				target_atom = A

	if(target_atom)
		zapstart.Beam(target_atom, icon_state="nzcrentrs_power", time=5)
		var/zapdir = get_dir(zapstart, target_atom)
		if(zapdir)
			. = zapdir

	if(target_mob)
		target_mob.electrocute_act(rand(5,10), "Supermatter Discharge Bolt", 1, stun = 0)
		if(prob(15))
			supermatter_zap(target_mob, 5, power / 2)
			supermatter_zap(target_mob, 5, power / 2)
		else
			supermatter_zap(target_mob, 5, power / 1.5)

	else if(target_machine)
		if(prob(15))
			supermatter_zap(target_machine, 5, power / 2)
			supermatter_zap(target_machine, 5, power / 2)
		else
			supermatter_zap(target_machine, 5, power / 1.5)

	else if(target_structure)
		if(prob(15))
			supermatter_zap(target_structure, 5, power / 2)
			supermatter_zap(target_structure, 5, power / 2)
		else
			supermatter_zap(target_structure, 5, power / 1.5)

//////////////////////////////////////////////
///////////FOR SUPERMATTER BUILDING///////////
//////////////////////////////////////////////


/obj/structure/supermatter_base_structure/proc/load(obj/item/hemostat/supermatter/T, mob/user)
	if(!istype(T) || !T.sliver)
		return FALSE
	if(stage < 2)
		T.sliver.forceMove(src)
		T.sliver = null
		T.icon_state = "supermatter_tongs"
		stage++
		icon_state = "[initial(icon_state)]_1"
		playsound(src, 'sound/items/deconstruct.ogg', 75)
		user.visible_message(span_notice("You see \the [user] carefully place down the supermatter shard on the [src]."), span_notice("You carefully place down the supermatter shard on the \the [src]."))
	else if(stage >= 2)
		T.sliver.forceMove(src)
		T.sliver = null
		T.icon_state = "supermatter_tongs"
		var/obj/machinery/power/supermatter_crystal/shard/shard = new(loc)
		user.visible_message(span_notice("You see \the [user] carefully place down the supermatter shard on the [src] and you can see \the [shard] engine is charging up."), span_notice("You carefully place down the supermatter shard on the \the [src] and you can see \the [shard] engine is charging up."))
		playsound(src.loc, 'sound/weapons/marauder.ogg', 100, 1, extrarange = 7)
		shard.say(span_danger("Supermatter is being charged up, please stand back."))
		qdel(src)
		addtimer(CALLBACK(shard, TYPE_PROC_REF(/obj/machinery/power/supermatter_crystal/shard, trigger)), 60)
	return TRUE

/obj/machinery/power/supermatter_crystal/shard/proc/trigger()
	var/area/A = get_area(loc)
	playsound(src, 'sound/machines/supermatter_alert.ogg', 75)
	radio.talk_into(src, "Alert, new crystalline hyperstructure has been established in [A.map_name]", engineering_channel)
	for(var/i=1 to 10)
		addtimer(CALLBACK(src, PROC_REF(chargedUp_zap)), 30)

/obj/machinery/power/supermatter_crystal/shard/proc/chargedUp_zap()
	supermatter_zap(src, 7, 3000)
	playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)

/obj/structure/supermatter_base_structure/attackby(obj/item/hemostat/supermatter/tongs, mob/user)
	if(istype(tongs))
		load(tongs, user)
	else
		return ..()

/atom/movable/distortion_effect
	name = ""
	plane = GRAVITY_PULSE_PLANE
	// Changing the colour of this based on the parent will cause issues with the displacement effect
	// so we need to ensure that it always has the default colour (clear).
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/96x96.dmi'
	icon_state = "SM_base"
	pixel_x = -32
	pixel_y = -32

#undef HALLUCINATION_RANGE
