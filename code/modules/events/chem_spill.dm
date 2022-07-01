/datum/round_event_control/chem_spill
	name = "Chemical Spill: Normal"
	typepath = /datum/round_event/chem_spill
	weight = 20
	max_occurrences = 3
	min_players = 10
	max_alert = SEC_LEVEL_DELTA

/datum/round_event/chem_spill
	announceWhen	= 1
	startWhen		= 1
	endWhen			= 35
	var/interval 	= 2
	var/list/filters  = list()
	var/randomProbability = 25
	var/reagentsAmount = 50
	var/list/saferChems = list(/datum/reagent/water,/datum/reagent/carbon,/datum/reagent/consumable/flour,/datum/reagent/space_cleaner,/datum/reagent/consumable/nutriment,/datum/reagent/consumable/condensedcapsaicin,/datum/reagent/drug/mushroomhallucinogen,/datum/reagent/lube,/datum/reagent/glitter/pink,/datum/reagent/cryptobiolin,
						 /datum/reagent/toxin/plantbgone,/datum/reagent/blood,/datum/reagent/medicine/charcoal,/datum/reagent/drug/space_drugs,/datum/reagent/medicine/morphine,/datum/reagent/water/holywater,/datum/reagent/consumable/ethanol,/datum/reagent/consumable/hot_coco,/datum/reagent/toxin/acid,/datum/reagent/toxin/mindbreaker,/datum/reagent/toxin/rotatium,/datum/reagent/bluespace,
						 /datum/reagent/pax,/datum/reagent/consumable/laughter,/datum/reagent/concentrated_barbers_aid,/datum/reagent/colorful_reagent,/datum/reagent/peaceborg/confuse,/datum/reagent/peaceborg/tire,/datum/reagent/consumable/sodiumchloride,/datum/reagent/consumable/ethanol/beer,/datum/reagent/hair_dye,/datum/reagent/consumable/sugar,/datum/reagent/glitter/white,/datum/reagent/growthserum)
	//needs to be chemid unit checked at some point

/datum/round_event/chem_spill/announce()
	priority_announce("Due to a chemical spill, your pool[filters.len > 1 ? "s" : ""] may have been contaminated", "Hazmat alert")

/datum/round_event/chem_spill/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/pool_filter/filter in GLOB.pool_filters)
		var/turf/T = get_turf(filter)
		if(T && is_station_level(T.z))
			filters += filter
	if(!filters.len)
		return kill()

/datum/round_event/chem_spill/start()
	for(var/obj/machinery/pool_filter/filter in filters)
		if(filter && filter.loc)
			var/datum/reagents/R = filter.reagents
			if (prob(randomProbability))
				R.add_reagent(get_random_reagent_id(), reagentsAmount)
			else
				R.add_reagent(pick(saferChems), reagentsAmount)
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
