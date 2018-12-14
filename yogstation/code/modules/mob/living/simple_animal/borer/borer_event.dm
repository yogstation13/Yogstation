/datum/round_event_control/borer
	name = "Borer"
	typepath = /datum/round_event/borer
	weight = 15
	max_occurrences = 1
	min_players = 20

	earliest_start = 12000

/datum/round_event/borer
	announceWhen = 3000 //Borers get 5 minutes till the crew tries to murder them.
	var/spawned = 0

	var/spawncount

/datum/round_event/borer/announce()
	if(spawned)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg') //Borers seem like normal xenomorphs.


/datum/round_event/borer/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue

		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent

	if(!vents.len)
		return kill()


	var/total_humans = 0
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.stat != DEAD)
			total_humans++

	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as a borer?", ROLE_BORER, null, FALSE, 200)
	if(!candidates.len)
		return kill()

	for(var/client/C in candidates)
		if(!(C.prefs.toggles & MIDROUND_ANTAG))
			candidates -= C

	spawncount = round(2 + total_humans / 10)	// 2 + 1 for every 10 alive humans
	spawncount = CLAMP(spawncount, 0, candidates.len)
	spawncount = CLAMP(spawncount, 0, vents.len)
	total_borer_hosts_needed += spawncount

	while(spawncount > 0)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates) //So as to not spawn the same person twice

		var/mob/living/simple_animal/borer/borer = new(vent.loc)
		borer.transfer_personality(C)

		spawned++
		spawncount--

		log_game("[borer]/([borer.ckey]) was spawned as a cortical borer.")
		message_admins("[borer]/[borer.ckey] was spawned as a cortical borer.")