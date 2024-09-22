/datum/round_event_control/antagonist/solo/traitor
	antag_flag = ROLE_TRAITOR
	tags = list(TAG_COMBAT, TAG_CREW_ANTAG)
	antag_datum = /datum/antagonist/traitor
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("AI", "Cyborg", "Synthetic")
	weight = 15

/datum/round_event_control/antagonist/solo/traitor/midround
	name = "Sleeper Agents (Traitors)"
	prompted_picking = TRUE
	min_players = 5

/datum/round_event_control/antagonist/solo/traitor/roundstart
	name = "Traitors"
	roundstart = TRUE
	title_icon = "traitor"
	typepath = /datum/round_event/antagonist/solo/traitor //yogs change: uses a different typepath so antag spawning can be treated differently
	earliest_start = 0 SECONDS


//yogs change, delayed awakening
/datum/round_event/antagonist/solo/traitor/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/round_event/antagonist/solo/traitor, add_traitor_delayed), antag_mind, null), rand(1 MINUTES, (3 MINUTES + 10 SECONDS)))

/datum/round_event/antagonist/solo/traitor/proc/add_traitor_delayed(datum/mind/traitor, datum/antagonist/cached_antag = null)
	if(!cached_antag)
		cached_antag = new antag_datum()
		cached_antag.awake_stage = ANTAG_ASLEEP
	cached_antag.awake_stage++
	switch(cached_antag.awake_stage)
		if(ANTAG_FIRST_WARNING)
			traitor.current.playsound_local(get_turf(traitor.current), 'sound/ambience/antag/telegraph1.ogg', 100, FALSE, pressure_affected = FALSE)
			to_chat(traitor.current, span_danger("You don't feel good.."))
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/round_event/antagonist/solo/traitor, add_traitor_delayed), traitor, cached_antag), 1 MINUTES)
		if(ANTAG_SECOND_WARNING)
			traitor.current.playsound_local(get_turf(traitor.current), 'sound/ambience/antag/telegraph2.ogg', 100, FALSE, pressure_affected = FALSE)
			to_chat(traitor.current, span_danger("Remembering a tune, you slowly find the melody. Coded phrases and dark rooms flutter behind your eyelids. What could it mean? You should probably keep this to yourself."))
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/round_event/antagonist/solo/traitor, add_traitor_delayed), traitor, cached_antag), 1 MINUTES)
		if(ANTAG_AWAKE)
			traitor.current.playsound_local(get_turf(traitor.current), 'sound/ambience/antag/tatoralert_buildup.ogg', 100, FALSE, pressure_affected = FALSE)
			addtimer(CALLBACK(traitor, TYPE_PROC_REF(/datum/mind, add_antag_datum), cached_antag), 2 SECONDS)
