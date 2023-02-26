/client/proc/stand_proud()
	set category = "Admin.Round Interaction"
	set name = "Toggle Stands Mode"

	if(!check_rights_for(src, R_FUN))
		return

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame.", confidential=TRUE)
		return

	if(SSticker.stand_proud)
		SSticker.stand_proud = 0
		to_chat(usr, "Stand mode disabled.", confidential=TRUE)
		message_admins(span_adminnotice("[key_name_admin(usr)] has toggled off holoparasite mode."))
	else
		SSticker.stand_proud = 1
		to_chat(usr, "Stand mode disabled. Half of all players will be spawned as holoparasites.", confidential=TRUE)
		message_admins(span_adminnotice("[key_name_admin(usr)] has toggled on holoparasite mode. Half of all players will be spawned as holoparasites."))

/mob/living/proc/assign_random_stand(mob/stand_player, reason = "random generation proc")
	var/mob/original_stand_player_mob = stand_player

	// Generate stand
	var/points = 15
	var/list/categories = list("Damage", "Defense", "Speed", "Potential", "Range") // will be shuffled every iteration
	var/list/majors = subtypesof(/datum/guardian_ability/major) - typesof(/datum/guardian_ability/major/special)
	var/list/major_weighted = list()
	for (var/M in majors)
		var/datum/guardian_ability/major/major = new M
		major_weighted[major] = major.arrow_weight
	var/datum/guardian_ability/major/major_ability = pickweight(major_weighted)
	var/datum/guardian_stats/stats = new
	stats.ability = major_ability
	stats.ability.master_stats = stats
	points -= major_ability.cost
	if(prob(15) && points >= 3)
		points -= 3
		stats.ranged = TRUE
	while(points > 0)
		if (!categories.len)
			break
		shuffle_inplace(categories)
		var/cat = pick(categories)
		points--
		switch(cat)
			if ("Damage")
				stats.damage++
				if (stats.damage >= 5)
					categories -= "Damage"
			if ("Defense")
				stats.defense++
				if (stats.defense >= 5)
					categories -= "Defense"
			if ("Speed")
				stats.speed++
				if (stats.speed >= 5)
					categories -= "Speed"
			if ("Potential")
				stats.potential++
				if (stats.potential >= 5)
					categories -= "Potential"
			if ("Range")
				stats.range++
				if (stats.range >= 5)
					categories -= "Range"
	
	// Create and assign stand
	var/mob/living/simple_animal/hostile/guardian/G = new(src, "magic")
	G.summoner = mind
	G.key = stand_player.key
	G.mind.enslave_mind_to_creator(src)
	G.RegisterSignal(src, COMSIG_MOVABLE_MOVED, /mob/living/simple_animal/hostile/guardian.proc/OnMoved)
	var/datum/antagonist/guardian/S = new
	S.stats = stats
	S.summoner = mind
	G.mind.add_antag_datum(S)
	G.stats = stats
	G.stats.Apply(G)
	G.show_detail()
	log_game("[key_name(src)] has summoned [key_name(G)], a holoparasite, via [reason].")
	to_chat(src, span_holoparasite("<font color=\"[G.namedatum.color]\"><b>[G.real_name]</b></font> has been summoned!"))
	add_verb(src, list(/mob/living/proc/guardian_comm, /mob/living/proc/guardian_recall, /mob/living/proc/guardian_reset, /mob/living/proc/finduser))
	update_sight()

	// Clean up the mob we left behind
	if(isliving(original_stand_player_mob))
		var/mob/dead/ghost = original_stand_player_mob.ghostize(FALSE)
		if(!ghost || !istype(ghost))
			return
		
		if(original_stand_player_mob.mind && original_stand_player_mob.mind.assigned_role)
			//Handle job slot/tater cleanup.
			var/job = original_stand_player_mob.mind.assigned_role
			SSjob.FreeRole(job)
			if(LAZYLEN(original_stand_player_mob.mind.objectives))
				original_stand_player_mob.mind.objectives.Cut()
				original_stand_player_mob.mind.special_role = null
			/// Chaplain Stuff
			var/datum/job/role = GetJob(job)
			if(original_stand_player_mob.mind.assigned_role == "Chaplain" && role?.current_positions < 1)
				GLOB.religion = null	/// Clears the religion for the next chaplain
		
		for(var/medrecord in GLOB.data_core.medical)
			var/datum/data/record/R = medrecord
			if((R.fields["name"] == original_stand_player_mob.real_name))
				qdel(R)
		for(var/secrecord in GLOB.data_core.security)
			var/datum/data/record/T = secrecord
			if((T.fields["name"] == original_stand_player_mob.real_name))
				qdel(T)
		for(var/genrecord in GLOB.data_core.general)
			var/datum/data/record/G = genrecord
			if((G.fields["name"] == original_stand_player_mob.real_name))
				qdel(G)
		
		original_stand_player_mob.dust()
