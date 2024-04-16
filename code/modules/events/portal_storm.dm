/datum/round_event/portal_storm
	startWhen = 7
	endWhen = 999
	announceWhen = 1

	var/list/boss_spawn = list()
	var/list/boss_types = list() //only configure this if you have hostiles
	var/number_of_bosses
	var/next_boss_spawn
	var/list/hostiles_spawn = list()
	var/list/hostile_types = list()
	var/number_of_hostiles
	var/mutable_appearance/storm

/datum/round_event_control/portal_storm_syndicate
	name = "Portal Storm: Syndicate Shocktroops"
	typepath = /datum/round_event/portal_storm/syndicate_shocktroop
	weight = 2
	min_players = 15
	earliest_start = 30 MINUTES

/datum/round_event/portal_storm/syndicate_shocktroop
	boss_types = list(/mob/living/simple_animal/hostile/syndicate/melee/space/stormtrooper = 2)
	hostile_types = list(/mob/living/simple_animal/hostile/syndicate/melee/space = 8,\
						/mob/living/simple_animal/hostile/syndicate/ranged/space = 2)

/datum/round_event_control/portal_storm_narsie
	name = "Portal Storm: Constructs"
	typepath = /datum/round_event/portal_storm/portal_storm_narsie
	weight = 0
	max_occurrences = 0

/datum/round_event/portal_storm/portal_storm_narsie
	boss_types = list(/mob/living/simple_animal/hostile/construct/builder = 6)
	hostile_types = list(/mob/living/simple_animal/hostile/construct/armored/hostile = 8,\
						/mob/living/simple_animal/hostile/construct/wraith/hostile = 6)

/datum/round_event/portal_storm/setup()
	storm = mutable_appearance('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
	storm.color = "#00FF00"

	number_of_bosses = 0
	for(var/boss in boss_types)
		number_of_bosses += boss_types[boss]

	number_of_hostiles = 0
	for(var/hostile in hostile_types)
		number_of_hostiles += hostile_types[hostile]

	while(number_of_bosses > boss_spawn.len)
		boss_spawn += get_random_station_turf()

	while(number_of_hostiles > hostiles_spawn.len)
		hostiles_spawn += get_random_station_turf()

	next_boss_spawn = startWhen + CEILING(2 * number_of_hostiles / number_of_bosses, 1)

/datum/round_event/portal_storm/announce(fake)
	set waitfor = 0
	sound_to_playing_players('sound/magic/lightning_chargeup.ogg', volume = 50)
	sleep(8 SECONDS)
	priority_announce("Massive bluespace anomaly detected en route to [station_name()]. Brace for impact.")
	sleep(2 SECONDS)
	sound_to_playing_players('sound/magic/lightningbolt.ogg', volume = 50)

/datum/round_event/portal_storm/tick()
	var/turf/T = get_safe_random_station_turf()

	if(spawn_hostile())
		var/type = pick(hostile_types)
		hostile_types[type] = hostile_types[type] - 1
		spawn_mob(T, type, hostiles_spawn)
		if(!hostile_types[type])
			hostile_types -= type

	if(spawn_boss())
		var/type = pick(boss_types)
		boss_types[type] = boss_types[type] - 1
		spawn_mob(T, type, boss_spawn)
		if(!boss_types[type])
			boss_types -= type

	time_to_end()

/datum/round_event/portal_storm/proc/spawn_mob(turf/T, type, spawn_list)
	if(!type)
		log_game("Portal Storm failed to spawn mob due to an invalid mob type.")
		CRASH("Cannot spawn null type!")
	if(!T)
		log_game("Portal Storm failed to spawn mob due to an invalid location.")
		CRASH("Cannot spawn mobs on null turf!")
	new type(T)
	spawn_effects(T)

/datum/round_event/portal_storm/proc/spawn_effects(turf/T)
	if(!T)
		log_game("Portal Storm failed to spawn effect due to an invalid location.")
		return
	T = get_step(T, SOUTHWEST) //align center of image with turf
	flick_overlay_static(storm, T, 15)
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), 1)

/datum/round_event/portal_storm/proc/spawn_hostile()
	if(!hostile_types || !hostile_types.len)
		return 0
	return ISMULTIPLE(activeFor, 2)

/datum/round_event/portal_storm/proc/spawn_boss()
	if(!boss_types || !boss_types.len)
		return 0

	if(activeFor == next_boss_spawn)
		next_boss_spawn += CEILING(number_of_hostiles / number_of_bosses, 1)
		return 1

/datum/round_event/portal_storm/proc/time_to_end()
	if(!hostile_types.len && !boss_types.len)
		endWhen = activeFor

	if(!number_of_hostiles && number_of_bosses)
		endWhen = activeFor

// Resonance cascade event, happens after an antinoblium delamination. Better call the deathsquad.
/datum/round_event_control/resonance_cascade
	name = "Resonance Cascade"
	typepath = /datum/round_event/portal_storm/resonance_cascade
	weight = 0
	max_occurrences = 0
	random = FALSE // No.
	max_alert = SEC_LEVEL_DELTA

/datum/round_event/portal_storm/resonance_cascade
	boss_types = list(
		/mob/living/simple_animal/hostile/megafauna/bubblegum = 1,
		/mob/living/simple_animal/hostile/megafauna/dragon = 1,
		/mob/living/simple_animal/hostile/megafauna/stalwart = 1,
		/mob/living/simple_animal/hostile/megafauna/colossus = 1,
		/mob/living/simple_animal/hostile/megafauna/hierophant = 1,
		/mob/living/simple_animal/hostile/megafauna/legion = 1,
		/mob/living/simple_animal/hostile/retaliate/goat/king = 1,
		/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon = 4,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner = 6,
		/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner = 6,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother = 5,
		/mob/living/simple_animal/hostile/asteroid/elite/herald = 5,
		/mob/living/simple_animal/hostile/asteroid/elite/legionnaire = 5,
		/mob/living/simple_animal/hostile/asteroid/elite/pandora = 5,
		/mob/living/simple_animal/hostile/space_dragon = 5
	)
	hostile_types = list(
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril = 25,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 25,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 25,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver = 25
	)
	var/list/anomaly_types = list(
		ANOMALY_FLUX_EXPLOSIVE = 150,
		ANOMALY_RADIATION = 130,
		ANOMALY_RADIATION_X = 5,
		ANOMALY_VORTEX = 130,
		ANOMALY_PYRO = 140,
		ANOMALY_HALLUCINATION = 140,
		ANOMALY_GRAVITATIONAL = 160,
	)
	endWhen = INFINITY // keep going until it's done

/datum/round_event/portal_storm/resonance_cascade/start()
	. = ..()
	var/list/nether_areas = GLOB.generic_event_spawns
	for(var/i in 1 to 50)
		var/area/target_event_spawn = pick_n_take(nether_areas)
		if(!target_event_spawn)
			return

		var/obj/structure/spawner/nether/doom = new(target_event_spawn.loc)
		doom.max_integrity = 250
		doom.spawn_time = 20 SECONDS

	for(var/obj/machinery/power/apc/A in GLOB.apcs_list)
		if(!is_station_level(A.z))
			continue
		if(prob(75))
			A.overload_lighting()
		A.emp_act(EMP_HEAVY) // stationwide blackout
		if(prob(25)) // chance of some fun effects
			if(prob(20))
				A.visible_message(span_userdanger("[A] overloads and blows up!"))
				A.atom_break()
				explosion(A, 0, 0, 2, flame_range=3)
			else
				A.visible_message(span_userdanger("[A] overloads and makes a huge arc!"))
				tesla_zap(A, 5, 10000) // woe
	message_centcom("Alert, a large scale of abnormal activity has been detected on [station_name()]. Investigate and send the special forces to the station immediately.", "Central Command Higher Dimensional Affairs")
	priority_announce("Unknown anomalous portals detected on a large scale of the station. There is no additional data.", "Central Command Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES)
	addtimer(CALLBACK(src, PROC_REF(call_shuttle)), 4 SECONDS) //Wait till the annoucement finishes till the the next one so the sounds dont overlap each other

/datum/round_event/portal_storm/resonance_cascade/proc/call_shuttle()
	SSshuttle.emergency.request(null, reason = "Shuttle has been automatically called due to the event, standing by.") // can't call the shuttle if all the APCs blew up, so give the crew some help

/datum/round_event/portal_storm/resonance_cascade/announce(fake)
	if(fake) // no point in trying to fake it, has much more impact if it's only the real thing
		return
	priority_announce("Attention all personnel, this is an emergency announcement on [station_name()]. \
		An evacuation is immediately underway due to abnormal hostile activity detected on the premises. \
		A distress signal has been sent to Central Command to alert them of the situation. In addition to that, \
		we have observed a substantial number of meteors approaching the station on a large scale. \
		Please remain calm and follow the evacuation procedures provided. \
		Proceed to the designated evacuation points swiftly and orderly. To ensure your safety, \
		please avoid areas with abnormal activity and refrain from going outside the station to minimize the risk of collisions with meteors. \
		Security personnel are present to assist and ensure your safety. \
		Cooperate with their instructions and refrain from engaging with any hostiles. \
		Central Command is actively responding and coordinating a comprehensive emergency response. \
		Your safety is our utmost priority during this evacuation. \
		Stay vigilant, report any suspicious activity, and await further instructions at the designated evacuation points. \
		Assistance is on the way.",
		title = "Central Command Higher Dimensional Affairs",
		sound = 'sound/misc/airraid.ogg',
	)

/datum/round_event/portal_storm/resonance_cascade/tick()
	var/turf/T = get_safe_random_station_turf()

	if(spawn_hostile())
		var/type = pick(hostile_types)
		hostile_types[type] = hostile_types[type] - 1
		spawn_mob(T, type, hostiles_spawn)
		if(!hostile_types[type])
			hostile_types -= type

	if(spawn_boss())
		var/type = pick(boss_types)
		boss_types[type] = boss_types[type] - 1
		spawn_mob(T, type, boss_spawn)
		if(!boss_types[type])
			boss_types -= type

	var/anomaly = pick(anomaly_types)
	anomaly_types[anomaly] = anomaly_types[anomaly] - 1
	supermatter_anomaly_gen(T, anomaly, rand(5, 10), has_weak_lifespan = TRUE)
	if(!anomaly_types[anomaly])
		anomaly_types -= anomaly

	time_to_end()
