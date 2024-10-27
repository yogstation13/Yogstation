/datum/round_event_control/chem_spill
	name = "Chemical Spill: Normal"
	description = "The pool will be filled with random chemicals."
	typepath = /datum/round_event/chem_spill
	weight = 20
	max_occurrences = 3
	min_players = 10
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event/chem_spill
	announce_when	= 1
	start_when		= 1
	end_when			= 35
	var/interval 	= 2
	var/list/filters  = list()
	var/randomProbability = 25
	var/reagentsAmount = 50
	//needs to be chemid unit checked at some point

/datum/round_event/chem_spill/announce()
	priority_announce("Due to a chemical spill, your pool[filters.len > 1 ? "s" : ""] may have been contaminated", "Hazmat alert")

/datum/round_event/chem_spill/setup()
	end_when = rand(25, 100)
	for(var/obj/machinery/pool_filter/filter in GLOB.pool_filters)
		var/turf/T = get_turf(filter)
		if(T && is_station_level(T.z))
			filters += filter
	if(!filters.len)
		return kill()
	setup = TRUE //storytellers

/datum/round_event/chem_spill/start()
	for(var/obj/machinery/pool_filter/filter in filters)
		if(filter && filter.loc)
			var/datum/reagents/R = filter.reagents
			if (prob(randomProbability))
				R.add_reagent(get_random_reagent_id(), reagentsAmount)
			else
				R.add_reagent(get_random_safe_chem(), reagentsAmount)
		CHECK_TICK

/datum/round_event_control/chem_spill/threatening
	name = "Chemical Spill: Threatening"
	typepath = /datum/round_event/chem_spill/threatening
	weight = 10
	min_players = 25
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/chem_spill/threatening
	randomProbability = 50
	reagentsAmount = 75

/datum/round_event_control/chem_spill/catastrophic
	name = "Chemical Spill: Catastrophic"
	typepath = /datum/round_event/chem_spill/catastrophic
	weight = 5
	min_players = 35
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/chem_spill/catastrophic
	randomProbability = 75
	reagentsAmount = 100
