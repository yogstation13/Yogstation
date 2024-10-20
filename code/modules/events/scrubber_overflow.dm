#define BASE_EVAPORATION_MULTIPLIER 10

/// List of chems deemed "safer" for random generation, used by scrubber_overflow.dm and chem_spill.dm
/proc/get_random_safe_chem()
	var/list/chems = list(
	/datum/reagent/water,
	/datum/reagent/carbon,
	/datum/reagent/consumable/flour,
	/datum/reagent/space_cleaner,
	/datum/reagent/consumable/nutriment,
	/datum/reagent/consumable/condensedcapsaicin,
	/datum/reagent/drug/mushroomhallucinogen,
	/datum/reagent/lube,
	/datum/reagent/glitter/pink,
	/datum/reagent/cryptobiolin,
	/datum/reagent/toxin/plantbgone,
	/datum/reagent/blood,
	/datum/reagent/medicine/charcoal,
	/datum/reagent/drug/space_drugs,
	/datum/reagent/medicine/morphine,
	/datum/reagent/water/holywater,
	/datum/reagent/consumable/ethanol,
	/datum/reagent/consumable/hot_coco,
	/datum/reagent/toxin/acid,
	/datum/reagent/toxin/mindbreaker,
	/datum/reagent/toxin/rotatium,
	/datum/reagent/bluespace,
	/datum/reagent/pax,
	/datum/reagent/consumable/laughter,
	/datum/reagent/concentrated_barbers_aid,
	/datum/reagent/baldium,
	/datum/reagent/colorful_reagent,
	/datum/reagent/peaceborg/confuse,
	/datum/reagent/peaceborg/tire,
	/datum/reagent/consumable/sodiumchloride,
	/datum/reagent/consumable/ethanol/beer,
	/datum/reagent/hair_dye,
	/datum/reagent/consumable/sugar,
	/datum/reagent/glitter/white,
	/datum/reagent/growthserum
	)
	return pick(chems)

/datum/round_event_control/scrubber_overflow
	name = "Scrubber Overflow: Normal"
	typepath = /datum/round_event/scrubber_overflow
	weight = 10
	max_occurrences = 3
	min_players = 10
	description = "The scrubbers release a tide of mostly harmless froth."
	admin_setup = list(/datum/event_admin_setup/listed_options/scrubber_overflow)
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/scrubber_overflow
	shared_occurence_type = SHARED_SCRUBBERS

/datum/round_event/scrubber_overflow
	announce_when = 1
	start_when = 5
	/// The probability that the ejected reagents will be dangerous
	var/danger_chance = 1
	/// Amount of reagents ejected from each scrubber
	var/reagents_amount = 100
	/// How quickly things evaporate
	var/evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER
	/// Probability of an individual scrubber overflowing
	var/overflow_probability = 50
	/// Specific reagent to force all scrubbers to use, null for random reagent choice
	var/datum/reagent/forced_reagent_type
	/// A list of scrubbers that will have reagents ejected from them
	var/list/scrubbers = list()

/datum/round_event/scrubber_overflow/announce_deadchat(random, cause)
	if(!forced_reagent_type)
		//nothing out of the ordinary, so default announcement
		return ..()
	deadchat_broadcast(" has just been[random ? " randomly" : ""] triggered[cause ? " by [cause]" : ""]!", "<b>Scrubber Overflow: [initial(forced_reagent_type.name)]</b>", message_type=DEADCHAT_ANNOUNCEMENT)

/datum/round_event/scrubber_overflow/announce(fake)
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "[command_name()] Engineering Division")

/datum/round_event/scrubber_overflow/setup()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/scrubber_turf = get_turf(temp_vent)
		if(!scrubber_turf)
			continue
		if(!is_station_level(scrubber_turf.z))
			continue
		if(temp_vent.welded)
			continue
		if(!prob(overflow_probability))
			continue
		scrubbers += temp_vent

	if(!scrubbers.len)
		return kill()
	setup = TRUE //MONKESTATION ADDITION

/datum/round_event_control/scrubber_overflow/canSpawnEvent(players_amt, allow_magic = FALSE, fake_check = FALSE) //MONKESTATION ADDITION: fake_check = FALSE
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/scrubber_turf = get_turf(temp_vent)
		if(!scrubber_turf)
			continue
		if(!is_station_level(scrubber_turf.z))
			continue
		if(temp_vent.welded)
			continue
		return TRUE //there's at least one. we'll let the codergods handle the rest with prob() i guess.
	return FALSE

/// proc that will run the prob check of the event and return a safe or dangerous reagent based off of that.
/datum/round_event/scrubber_overflow/proc/get_overflowing_reagent(dangerous)
	return dangerous ? get_random_reagent_id() : get_random_safe_chem()

/datum/round_event/scrubber_overflow/start()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/vent as anything in scrubbers)
		if(QDELETED(vent) || vent.welded) // in case it was welded after setup() but before we got to it here
			continue
		var/turf/vent_turf = get_turf(vent)
		if(!isopenturf(vent_turf) || QDELING(vent_turf))
			continue
		var/dangerous = prob(danger_chance)
		var/reagent_type = forced_reagent_type || get_overflowing_reagent(dangerous)
		if(dangerous)
			new /mob/living/simple_animal/cockroach(vent_turf)
			new /mob/living/simple_animal/cockroach(vent_turf)
		vent_turf.add_liquid(reagent_type, reagents_amount, no_react = TRUE)
		if(vent_turf.liquids?.liquid_group)
			vent_turf.liquids.liquid_group.always_evaporates = TRUE
			vent_turf.liquids.liquid_group.evaporation_multiplier += evaporation_multiplier
		CHECK_TICK

/datum/round_event_control/scrubber_overflow/threatening
	name = "Scrubber Overflow: Threatening"
	typepath = /datum/round_event/scrubber_overflow/threatening
	weight = 4
	min_players = 25
	max_occurrences = 1
	earliest_start = 35 MINUTES
	description = "The scrubbers release a tide of moderately harmless froth."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4

/datum/round_event/scrubber_overflow/threatening
	danger_chance = 10
	reagents_amount = 150
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5

/datum/round_event_control/scrubber_overflow/catastrophic
	name = "Scrubber Overflow: Catastrophic"
	typepath = /datum/round_event/scrubber_overflow/catastrophic
	weight = 2
	min_players = 35
	max_occurrences = 1
	earliest_start = 45 MINUTES
	description = "The scrubbers release a tide of mildly harmless froth."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 6

/datum/round_event/scrubber_overflow/catastrophic
	danger_chance = 30
	reagents_amount = 200
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 2

/datum/round_event_control/scrubber_overflow/every_vent
	name = "Scrubber Overflow: Every Vent"
	typepath = /datum/round_event/scrubber_overflow/every_vent
	weight = 0
	max_occurrences = 0
	description = "The scrubbers release a tide of mostly harmless froth, but every scrubber is affected."

/datum/round_event/scrubber_overflow/every_vent
	overflow_probability = 100
	reagents_amount = 150
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5

/datum/event_admin_setup/listed_options/scrubber_overflow
	normal_run_option = "Random Reagents"
	special_run_option = "Random Single Reagent"

/datum/event_admin_setup/listed_options/scrubber_overflow/get_list()
	return sort_list(subtypesof(/datum/reagent), /proc/cmp_typepaths_asc)

/datum/event_admin_setup/listed_options/scrubber_overflow/apply_to_event(datum/round_event/scrubber_overflow/event)
	if(chosen == special_run_option)
		chosen = event.get_overflowing_reagent(dangerous = prob(event.danger_chance))
	event.forced_reagent_type = chosen


/datum/round_event_control/scrubber_overflow/beer // Used when the beer nuke "detonates"
	name = "Scrubber Overflow: Beer"
	typepath = /datum/round_event/scrubber_overflow/beer
	weight = 0

/datum/round_event/scrubber_overflow/beer
	overflow_probability = 100
	reagents_amount = 100
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5
	forced_reagent_type = /datum/reagent/consumable/ethanol/beer
