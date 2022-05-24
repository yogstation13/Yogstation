SUBSYSTEM_DEF(shitter)
	name = "Shitter Detection"
	priority = FIRE_PRIORITY_SHITTER
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 10 SECONDS


/datum/controller/subsystem/shitter/fire(resumed = 0)
	for(var/mob/M in GLOB.player_list)
		if(!M.mind)
			continue
		if(!M.client)
			continue

		var/client/shitter_person = M.client
		
		var/list/play_records = shitter_person.prefs.exp
		if (!play_records.len)
			shitter_person.set_exp_from_db()
			play_records = shitter_person.prefs.exp
			if (!play_records.len)
				continue

		if(play_records[EXP_TYPE_LIVING] >= SHITTER_PLAYTIME_CUTOFF)
			continue

		if(M.mind.shitter_score >= MAX_SHITTER_SCORE)
			M.ghostize(FALSE)
			var/datum/preferences/P = shitter_person.prefs
			P.muted |= MUTE_ALL
			continue

		M.mind.shitter_score -= SHITTER_BLEEDOFF
		if(M.mind.shitter_score < 0)
			M.mind.shitter_score = 0

