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
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 12,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver = 12
	)
	hostile_types = list(
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril = 24,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 24,
	)
	endWhen = INFINITY // keep going until it's done

/datum/round_event/portal_storm/resonance_cascade/start()
	. = ..()
	for(var/obj/machinery/power/apc/A in GLOB.apcs_list)
		if(!is_station_level(A.z))
			continue
		A.overload_lighting()
		A.emp_act(EMP_HEAVY) // stationwide blackout
		if(prob(25)) // chance of some fun effects
			if(prob(20))
				A.visible_message(span_userdanger("[A] overloads and blows up!"))
				A.obj_break()
				explosion(A, 0, 0, 2, flame_range=3)
			else
				A.visible_message(span_userdanger("[A] overloads and makes a huge arc!"))
				tesla_zap(A, 5, 10000) // woe
	SSshuttle.emergency.request(null) // can't call the shuttle if all the APCs blew up, so give the crew some help

/datum/round_event/portal_storm/resonance_cascade/announce(fake)
	if(fake) // no point in trying to fake it, has much more impact if it's only the real thing
		return
	priority_announce(readable_corrupted_text("Massive energy surge detected on [station_name()]. Immediate evacuation is recommended."), sound='sound/misc/airraid.ogg')

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

	time_to_end()
