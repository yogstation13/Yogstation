/datum/game_mode/royale
	name = "battle royale"
	config_tag = "royale"
	restricted_jobs = list("AI", "Cyborg", "Captain", "Warden", "Head of Personnel", "Head of Security") //in this gamemode, this is the list of jobs you don't want people to use at all.

	announce_span = "danger"
	announce_text = ""

	var/check_counter = 0
	var/finished = FALSE
	var/mob/living/carbon/human/sole_survivor
	var/borderstage = 0
	var/stage_interval = 3000
	var/list/randomweathers = list("royale north", "royale south", "royale east")


/datum/game_mode/royale/pre_setup()
	for(var/J in restricted_jobs)
		var/datum/job/job = SSjob.GetJob(J)
		job.spawn_positions = 0
		job.total_positions = 0

	return TRUE

/datum/game_mode/royale/post_setup()
	for(var/S in GLOB.generic_event_spawns)
		var/obj/effect/landmark/event_spawn/E = S
		E.spawnroyale(FALSE)

	SSshuttle.registerHostileEnvironment(src)
	addtimer(CALLBACK(src, .proc/shrinkborders), 10)

/datum/game_mode/royale/process()
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			SSticker.mode.check_win()
		check_counter = 0
	return FALSE

/datum/game_mode/royale/check_win()
	var/list/living_players = list()
	for(var/mob/M in GLOB.mob_living_list)
		if(istype(M, /mob/living/carbon/human) && M.ckey && M.client && M.mind && M.stat != DEAD && !(get_area(src) in get_areas(/area/space)) && !(get_area(src) in get_areas(/area/space)))
			living_players += M

	if(living_players.len == 1)
		sole_survivor = living_players[1]
		finished = TRUE
	else if(!living_players.len)
		finished = TRUE

/datum/game_mode/royale/check_finished()
	if(finished)

		if(sole_survivor)
			priority_announce("A winner has been chosen of the [GLOB.round_id]\th monthly battle royale! \n \n The winner is: [sole_survivor.real_name]", "Nanotrasen Battle Royale Committee")

		else
			priority_announce("Unfortunately, all participants of the [GLOB.round_id]\th monthly battle royale have abandoned their mortal coils, and as such no winner has been chosen.", "Nanotrasen Battle Royale Committee")

		return TRUE
	return ..()

/datum/game_mode/royale/proc/shrinkborders()
	switch(borderstage)
		if(0)
			SSweather.run_weather("royale start",2)
		if(1)
			SSweather.run_weather("royale maint", 2)
		if(2 to 4)
			var/weather = pick(randomweathers)
			SSweather.run_weather(weather, 2)
			randomweathers -= weather

		if(5)
			SSweather.run_weather("royale west", 2)
		if(6)
			SSweather.run_weather("royale centre", 2)

	borderstage++
	if(borderstage <= 6)
		addtimer(CALLBACK(src, .proc/shrinkborders), stage_interval)