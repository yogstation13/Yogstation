
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	persistent = TRUE
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	minimum_required_age = 0
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("Cyborg")
	required_candidates = 1
	weight = 5
	cost = 8	// Avoid raising traitor threat above 10, as it is the default low cost ruleset.
	scaling_cost = 9
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	antag_cap = list("denominator" = 24)
	var/autotraitor_cooldown = (15 MINUTES)
	COOLDOWN_DECLARE(autotraitor_cooldown_check)

/datum/dynamic_ruleset/roundstart/traitor/pre_execute(population)
	. = ..()
	COOLDOWN_START(src, autotraitor_cooldown_check, autotraitor_cooldown)
	var/num_traitors = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_traitors)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_TRAITOR
		M.mind.restricted_roles = restricted_roles
		log_game("[key_name(M)] has been selected as a Traitor")
	return TRUE

/datum/dynamic_ruleset/roundstart/traitor/rule_process()
	if (COOLDOWN_FINISHED(src, autotraitor_cooldown_check))
		COOLDOWN_START(src, autotraitor_cooldown_check, autotraitor_cooldown)
		log_game("DYNAMIC: Checking if we can turn someone into a traitor.")
		mode.picking_specific_rule(/datum/dynamic_ruleset/midround/autotraitor)

//////////////////////////////////////////
//                                      //
//           BLOOD BROTHERS             //
//                                      //
//////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitorbro
	name = "Blood Brothers"
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother/
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 2
	weight = 4
	cost = 10
	scaling_cost = 10
	requirements = list(40,30,30,20,20,15,15,15,10,10)
	antag_cap = 2	// Can pick 3 per team, but rare enough it doesn't matter.
	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 // Hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2

/datum/dynamic_ruleset/roundstart/traitorbro/pre_execute(population)
	. = ..()
	var/num_teams = (get_antag_cap(population)/min_team_size) * (scaled_times + 1) // 1 team per scaling
	for(var/j = 1 to num_teams)
		if(candidates.len < min_team_size || candidates.len < required_candidates)
			break
		var/datum/team/brother_team/team = new
		var/team_size = prob(10) ? min(3, candidates.len) : 2
		for(var/k = 1 to team_size)
			var/mob/bro = pick_n_take(candidates)
			assigned += bro.mind
			team.add_member(bro.mind)
			bro.mind.special_role = "brother"
			bro.mind.restricted_roles = restricted_roles
		pre_brother_teams += team
	return TRUE

/datum/dynamic_ruleset/roundstart/traitorbro/execute()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
		team.update_name()
	mode.brother_teams += pre_brother_teams
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	antag_flag = ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 10
	requirements = list(75,70,60,50,40,20,20,10,10,10)
	antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/pre_execute(population)
	. = ..()
	var/num_changelings = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_changelings)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_CHANGELING
	return TRUE

/datum/dynamic_ruleset/roundstart/changeling/execute()
	for(var/datum/mind/changeling in assigned)
		var/datum/antagonist/changeling/new_antag = new antag_datum()
		changeling.add_antag_datum(new_antag)
	return TRUE

//////////////////////////////////////////////
//                                          //
//              ELDRITCH CULT               //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/heretics
	name = "Heretics"
	antag_flag = ROLE_HERETIC
	antag_datum = /datum/antagonist/heretic
	protected_roles = list("Chaplain","Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 1
	weight = 3
	cost = 15
	scaling_cost = 9
	requirements = list(101,101,101,40,35,20,20,15,10,10)
	antag_cap = list("denominator" = 24)


/datum/dynamic_ruleset/roundstart/heretics/pre_execute(population)
	. = ..()
	var/num_ecult = get_antag_cap(population) * (scaled_times + 1)

	for (var/i = 1 to num_ecult)
		if(candidates.len <= 0)
			break
		var/mob/picked_candidate = pick_n_take(candidates)
		assigned += picked_candidate.mind
		picked_candidate.mind.restricted_roles = restricted_roles
		picked_candidate.mind.special_role = ROLE_HERETIC
	return TRUE

/datum/dynamic_ruleset/roundstart/heretics/execute()

	for(var/c in assigned)
		var/datum/mind/cultie = c
		var/datum/antagonist/heretic/new_antag = new antag_datum()
		cultie.add_antag_datum(new_antag)

	return TRUE

//////////////////////////////////////////////
//                                          //
//               WIZARDS                    //
//                                          //
//////////////////////////////////////////////

// Dynamic is a wonderful thing that adds wizards to every round and then adds even more wizards during the round.
/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	persistent = TRUE
	antag_flag = ROLE_WIZARD
	antag_datum = /datum/antagonist/wizard
	flags = LONE_RULESET
	minimum_required_age = 14
	restricted_roles = list("Head of Security", "Captain") // Just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 1
	weight = 2
	cost = 20
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	var/list/roundstart_wizards = list()

/datum/dynamic_ruleset/roundstart/wizard/acceptable(population=0, threat=0)
	if(GLOB.wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/wizard/pre_execute()
	if(GLOB.wizardstart.len == 0)
		return FALSE

	mode.antags_rolled += 1
	var/mob/M = pick_n_take(candidates)
	if (M)
		assigned += M.mind
		M.mind.assigned_role = ROLE_WIZARD
		M.mind.special_role = ROLE_WIZARD

	return TRUE

/datum/dynamic_ruleset/roundstart/wizard/execute()
	for(var/datum/mind/M in assigned)
		M.current.forceMove(pick(GLOB.wizardstart))
		M.add_antag_datum(new antag_datum())
	return TRUE

//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	antag_flag = ROLE_CULTIST
	antag_datum = /datum/antagonist/cult
	minimum_required_age = 14
	restricted_roles = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician")
	required_candidates = 2
	weight = 3
	cost = 20
	requirements = list(100,90,80,60,40,30,10,10,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 20, "offset" = 1)
	var/datum/team/cult/main_cult

/datum/dynamic_ruleset/roundstart/bloodcult/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	. = ..()

/datum/dynamic_ruleset/roundstart/bloodcult/pre_execute(population)
	. = ..()
	var/cultists = get_antag_cap(population)
	for(var/cultists_number = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_CULTIST
		M.mind.restricted_roles = restricted_roles
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	main_cult = new
	for(var/datum/mind/M in assigned)
		var/datum/antagonist/cult/new_cultist = new antag_datum()
		new_cultist.cult_team = main_cult
		new_cultist.give_equipment = TRUE
		M.add_antag_datum(new_cultist)
	main_cult.setup_objectives()
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/round_result()
	..()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	minimum_required_age = 14
	restricted_roles = list("Head of Security", "Captain") // Just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 5
	weight = 3
	cost = 25
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 18, "offset" = 1)
	var/datum/team/nuclear/nuke_team
	minimum_players = 36

/datum/dynamic_ruleset/roundstart/nuclear/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	. = ..()

/datum/dynamic_ruleset/roundstart/nuclear/pre_execute(population)
	. = ..()
	// If ready() did its job, candidates should have 5 or more members in it
	var/operatives = get_antag_cap(population)
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.assigned_role = "Nuclear Operative"
		M.mind.special_role = "Nuclear Operative"
	return TRUE

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	var/leader = TRUE
	for(var/datum/mind/M in assigned)
		if (leader)
			leader = FALSE
			var/datum/antagonist/nukeop/leader/new_op = M.add_antag_datum(antag_leader_datum)
			nuke_team = new_op.nuke_team
		else
			var/datum/antagonist/nukeop/new_op = new antag_datum()
			M.add_antag_datum(new_op)
	return TRUE

/datum/dynamic_ruleset/roundstart/nuclear/round_result()
	var result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

//////////////////////////////////////////////
//                                          //
//               REVS		                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/revs
	name = "Revolution"
	persistent = TRUE
	antag_flag = ROLE_REV_HEAD
	antag_datum = /datum/antagonist/rev/head
	minimum_required_age = 14
	restricted_roles = list("Security Officer", "Warden", "Detective", "AI", "Cyborg", "Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Shaft Miner", "Mining Medic", "Brig Physician")
	required_candidates = 3
	weight = 1
	delay = 7 MINUTES
	cost = 101
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	antag_cap = 3
	flags = HIGH_IMPACT_RULESET
	blocking_rules = list(/datum/dynamic_ruleset/latejoin/provocateur)
	// I give up, just there should be enough heads with 35 players...
	minimum_players = 35
	var/datum/team/revolution/revolution
	var/finished = FALSE

/datum/dynamic_ruleset/roundstart/revs/pre_execute(population)
	. = ..()
	var/max_candidates = get_antag_cap(population)
	for(var/i = 1 to max_candidates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = antag_flag
	return TRUE

/datum/dynamic_ruleset/roundstart/revs/execute()
	revolution = new()
	for(var/datum/mind/M in assigned)
		if(check_eligible(M))
			var/datum/antagonist/rev/head/new_head = new antag_datum()
			new_head.give_flash = TRUE
			new_head.give_hud = TRUE
			new_head.remove_clumsy = TRUE
			M.add_antag_datum(new_head,revolution)
		else
			assigned -= M
			log_game("DYNAMIC: [ruletype] [name] discarded [M.name] from head revolutionary due to ineligibility.")
	if(revolution.members.len)
		revolution.update_objectives()
		revolution.update_heads()
		SSshuttle.registerHostileEnvironment(src)
		return TRUE
	log_game("DYNAMIC: [ruletype] [name] failed to get any eligible headrevs. Refunding [cost] threat.")
	return FALSE

/datum/dynamic_ruleset/roundstart/revs/clean_up()
	qdel(revolution)
	..()

/datum/dynamic_ruleset/roundstart/revs/rule_process()
	if(!revolution)
		log_game("DYNAMIC: Something went horrifically wrong with [name] - and the antag datum could not be created. Notify coders.")
		return
	if(check_rev_victory())
		finished = REVOLUTION_VICTORY
		return RULESET_STOP_PROCESSING
	else if (check_heads_victory())
		finished = STATION_VICTORY
		SSshuttle.clearHostileEnvironment(src)
		revolution.save_members()
		for(var/datum/mind/M in revolution.members)	// Remove antag datums and prevents podcloned or exiled headrevs restarting rebellions.
			if(M.has_antag_datum(/datum/antagonist/rev/head))
				var/datum/antagonist/rev/head/R = M.has_antag_datum(/datum/antagonist/rev/head)
				R.remove_revolutionary(FALSE, "gamemode")
				if(M.current)
					var/mob/living/carbon/C = M.current
					if(istype(C) && C.stat == DEAD)
						C.makeUncloneable()
			if(M.has_antag_datum(/datum/antagonist/rev))
				var/datum/antagonist/rev/R = M.has_antag_datum(/datum/antagonist/rev)
				R.remove_revolutionary(FALSE, "gamemode")
		priority_announce("It appears the mutiny has been quelled. Please return yourself and your incapacitated colleagues to work. \
			We have remotely blacklisted the head revolutionaries in your medical records to prevent accidental revival.", null, null, null, "Central Command Loyalty Monitoring Division")
		return RULESET_STOP_PROCESSING

/// Checks for revhead loss conditions and other antag datums.
/datum/dynamic_ruleset/roundstart/revs/proc/check_eligible(var/datum/mind/M)
	var/turf/T = get_turf(M.current)
	if(!considered_afk(M) && considered_alive(M) && is_station_level(T.z) && !M.antag_datums?.len && !HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return TRUE
	return FALSE

/datum/dynamic_ruleset/roundstart/revs/check_finished()
	if(finished == REVOLUTION_VICTORY)
		return TRUE
	else
		return ..()

/datum/dynamic_ruleset/roundstart/revs/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in revolution.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/revs/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in revolution.head_revolutionaries())
		var/turf/T = get_turf(rev_mind.current)
		if(!considered_afk(rev_mind) && considered_alive(rev_mind) && is_station_level(T.z))
			if(ishuman(rev_mind.current) || ismonkey(rev_mind.current))
				return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/revs/round_result()
	if(finished == REVOLUTION_VICTORY)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if(finished == STATION_VICTORY)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE

// Admin only rulesets. The threat requirement is 101 so it is not possible to roll them.

//////////////////////////////////////////////
//                                          //
//               EXTENDED                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	antag_flag = null
	antag_datum = null
	restricted_roles = list()
	required_candidates = 0
	weight = 1
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET

/datum/dynamic_ruleset/roundstart/extended/pre_execute()
	message_admins("Starting a round of extended.")
	log_game("Starting a round of extended.")
	mode.spend_roundstart_budget(mode.round_start_budget)
	mode.spend_midround_budget(mode.mid_round_budget)
	mode.threat_log += "[worldtime2text()]: Extended ruleset set threat to 0."
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CLOCKCULT                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/clockcult
	name = "Clockcult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	antag_datum = /datum/antagonist/clockcult
	protected_roles = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Brig Physician")
	restricted_roles = list("Chaplain", "Captain")
	required_candidates = 4
	weight = 1
	cost = 40
	requirements = list(100,90,80,70,60,50,30,30,30,30)
	antag_cap = list(4,4,4,5,5,6,6,7,7,8) //this isn't used but having it probably stops a runtime
	flags = HIGH_IMPACT_RULESET
	minimum_players = 38
	var/ark_time

//FIX(?) CLOCKCULT XOXEYOS 3/13/2021 IF IT ALL GOES TO SHIT!
/datum/dynamic_ruleset/roundstart/clockcult/pre_execute()
	var/starter_servants = 4
	var/number_players = mode.roundstart_pop_ready
	if(number_players > 30)
		number_players -= 30
		starter_servants += round(number_players / 10)
	starter_servants = min(starter_servants, 8)
	for (var/i in 1 to starter_servants)
		var/mob/servant = pick_n_take(candidates)
		assigned += servant.mind
		servant.mind.assigned_role = ROLE_SERVANT_OF_RATVAR
		servant.mind.special_role = ROLE_SERVANT_OF_RATVAR
	ark_time = 30 + round((number_players / 5))
	ark_time = min(ark_time, 35)
	return TRUE

/datum/dynamic_ruleset/roundstart/clockcult/execute()
	var/list/spread_out_spawns = GLOB.servant_spawns.Copy()
	for(var/datum/mind/servant in assigned)
		var/mob/S = servant.current
		if(!spread_out_spawns.len)
			spread_out_spawns = GLOB.servant_spawns.Copy()
		log_game("[key_name(servant)] was made an initial servant of Ratvar")
		var/turf/T = pick_n_take(spread_out_spawns)
		S.forceMove(T)
		greet_servant(S)
		equip_servant(S)
		add_servant_of_ratvar(S, TRUE)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar //that's a mouthful
	G.final_countdown(ark_time)
	return TRUE

/datum/dynamic_ruleset/roundstart/clockcult/proc/greet_servant(mob/M) //Description of their role
	if(!M)
		return 0
	to_chat(M, "<span class='bold large_brass'>You are a servant of Ratvar, the Clockwork Justiciar!</span>")
	to_chat(M, span_brass("You have approximately <b>[ark_time]</b> minutes until the Ark activates."))
	to_chat(M, span_brass("Unlock <b>Script</b> scripture by converting a new servant."))
	to_chat(M, span_brass("<b>Application</b> scripture will be unlocked halfway until the Ark's activation."))
	M.playsound_local(get_turf(M), 'sound/ambience/antag/clockcultalr.ogg', 100, FALSE, pressure_affected = FALSE)
	return 1

/datum/dynamic_ruleset/roundstart/clockcult/proc/equip_servant(mob/living/M) //Grants a clockwork slab to the mob, with one of each component
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	L.equipOutfit(/datum/outfit/servant_of_ratvar)
	var/obj/item/clockwork/slab/S = new
	var/slot = "At your feet"
	var/list/slots = list("In your left pocket" = SLOT_L_STORE, "In your right pocket" = SLOT_R_STORE, "In your backpack" = SLOT_IN_BACKPACK, "On your belt" = SLOT_BELT)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		slot = H.equip_in_one_of_slots(S, slots)
		if(slot == "In your backpack")
			slot = "In your [H.back.name]"
	if(slot == "At your feet")
		if(!S.forceMove(get_turf(L)))
			qdel(S)
	if(S && !QDELETED(S))
		to_chat(L, "<span class='bold large_brass'>There is a paper in your backpack! It'll tell you if anything's changed, as well as what to expect.</span>")
		to_chat(L, "<span class='alloy'>[slot] is a <b>clockwork slab</b>, a multipurpose tool used to construct machines and invoke ancient words of power. If this is your first time \
		as a servant, you can find a concise tutorial in the Recollection category of its interface.</span>")
		to_chat(L, "<span class='alloy italics'>If you want more information, you can read <a href=\"https://wiki.yogstation.net/wiki/Clockwork_Cult\">the wiki page</a> to learn more.</span>")
		return TRUE
	return FALSE

/datum/dynamic_ruleset/roundstart/clockcult/round_result()
	if(GLOB.clockwork_gateway_activated)
		SSticker.news_report = CLOCK_SUMMON
		SSticker.mode_result = "win - servants completed their objective (summon ratvar)"
	else
		SSticker.news_report = CULT_FAILURE
		SSticker.mode_result = "loss - servants failed their objective (summon ratvar)"

//////////////////////////////////////////////
//                                          //
//               CLOWN OPS                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops
	name = "Clown Ops"
	antag_datum = /datum/antagonist/nukeop/clownop
	antag_leader_datum = /datum/antagonist/nukeop/leader/clownop
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = HIGH_IMPACT_RULESET

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops/pre_execute()
	. = ..()
	if(.)
		for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
			var/turf/T = get_turf(S)
			if(T)
				qdel(S)
				new /obj/machinery/nuclearbomb/syndicate/bananium(T)
		for(var/datum/mind/V in assigned)
			V.assigned_role = "Clown Operative"
			V.special_role = "Clown Operative"

//////////////////////////////////////////////
//                                          //
//               DEVIL                      //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/devil
	name = "Devil"
	antag_flag = ROLE_DEVIL
	antag_datum = /datum/antagonist/devil
	restricted_roles = list("Lawyer", "Curator", "Chaplain", "Head of Security", "Captain", "AI")
	required_candidates = 1
	weight = 1
	cost = 60
	flags = LONE_RULESET
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	antag_cap = list("denominator" = 30)

/datum/dynamic_ruleset/roundstart/devil/pre_execute(population)
	. = ..()
	var/num_devils = get_antag_cap(population) * (scaled_times + 1)

	for(var/j = 0, j < num_devils, j++)
		if (!candidates.len)
			break
		var/mob/devil = pick_n_take(candidates)
		assigned += devil.mind
		devil.mind.special_role = ROLE_DEVIL
		devil.mind.restricted_roles = restricted_roles

		log_game("[key_name(devil)] has been selected as a devil")
	return TRUE

/datum/dynamic_ruleset/roundstart/devil/execute()
	for(var/datum/mind/devil in assigned)
		add_devil(devil.current, ascendable = TRUE)
		add_devil_objectives(devil,2)
	return TRUE

/datum/dynamic_ruleset/roundstart/devil/proc/add_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	var/datum/antagonist/devil/D = devil_mind.has_antag_datum(/datum/antagonist/devil)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		D.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type
		else
			objective.find_target()

//////////////////////////////////////////////
//                                          //
//               MONKEY                     //
//                                          //
//////////////////////////////////////////////

/*/datum/dynamic_ruleset/roundstart/monkey
	name = "Monkey"
	antag_flag = ROLE_MONKEY
	antag_datum = /datum/antagonist/monkey/leader
	restricted_roles = list("Cyborg", "AI")
	required_candidates = 1
	weight = 1
	cost = 70
	requirements = list(100,100,95,90,85,80,80,80,80,70)
	flags = LONE_RULESET
	var/players_per_carrier = 25
	var/monkeys_to_win = 1
	var/escaped_monkeys = 0
	var/datum/team/monkey/monkey_team

/datum/dynamic_ruleset/roundstart/monkey/pre_execute(population)
	. = ..()
	var/carriers_to_make = get_antag_cap(population) * (scaled_times + 1)

	for(var/j = 0, j < carriers_to_make, j++)
		if (!candidates.len)
			break
		var/mob/carrier = pick_n_take(candidates)
		assigned += carrier.mind
		carrier.mind.special_role = "Monkey Leader"
		carrier.mind.restricted_roles = restricted_roles
		log_game("[key_name(carrier)] has been selected as a Jungle Fever carrier")
	return TRUE

/datum/dynamic_ruleset/roundstart/monkey/execute()
	for(var/datum/mind/carrier in assigned)
		var/datum/antagonist/monkey/M = add_monkey_leader(carrier)
		if(M)
			monkey_team = M.monkey_team
	return TRUE

/datum/dynamic_ruleset/roundstart/monkey/proc/check_monkey_victory()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if (M.HasDisease(D))
			if(M.onCentCom() || M.onSyndieBase())
				escaped_monkeys++
	if(escaped_monkeys >= monkeys_to_win)
		return TRUE
	else
		return FALSE

// This does not get called. Look into making it work.
/datum/dynamic_ruleset/roundstart/monkey/round_result()
	if(check_monkey_victory())
		SSticker.mode_result = "win - monkey win"
	else
		SSticker.mode_result = "loss - staff stopped the monkeys"*/

//////////////////////////////////////////////
//                                          //
//               METEOR                     //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/meteor
	name = "Meteor"
	persistent = TRUE
	required_candidates = 0
	weight = 1
	cost = 75
	requirements = list(100,100,100,100,100,100,100,100,99,98)
	flags = LONE_RULESET
	var/meteordelay = 2000
	flags = LONE_RULESET
	var/nometeors = 0
	var/rampupdelta = 5

/datum/dynamic_ruleset/roundstart/meteor/rule_process()
	if(nometeors || meteordelay > world.time - SSticker.round_start_time)
		return

	var/list/wavetype = GLOB.meteors_normal
	var/meteorminutes = (world.time - SSticker.round_start_time - meteordelay) / 10 / 60

	if (prob(meteorminutes))
		wavetype = GLOB.meteors_threatening

	if (prob(meteorminutes/2))
		wavetype = GLOB.meteors_catastrophic

	var/ramp_up_final = clamp(round(meteorminutes/rampupdelta), 1, 10)

	spawn_meteors(ramp_up_final, wavetype)

//////////////////////////////////////////////
//                                          //
//               SHADOWLINGS                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/shadowling
	name = "Shadowling"
	antag_flag = ROLE_SHADOWLING
	antag_datum = /datum/antagonist/shadowling
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician")
	restricted_roles = list("Cyborg", "AI")
	required_candidates = 3
	weight = 3
	cost = 30
	requirements = list(90,80,80,70,60,40,30,30,20,10)
	flags = HIGH_IMPACT_RULESET
	minimum_players = 30
	antag_cap = 3
	var/datum/team/shadowling/shadowling

/datum/dynamic_ruleset/roundstart/shadowling/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	. = ..()

/datum/dynamic_ruleset/roundstart/shadowling/pre_execute(population) /// DON'T BREAK PLEASE - Xoxeyos 3/13/2021
	. = ..()
	var/shadowlings = get_antag_cap(population)
	for(var/shadowling_number = 1 to shadowlings)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_SHADOWLING
		M.mind.restricted_roles = restricted_roles
		log_game("[key_name(M)] has been selected as a Shadowling")
	return TRUE

/datum/dynamic_ruleset/roundstart/shadowling/proc/check_shadow_death()
	return FALSE

//Xoxeyos Here, I've added this Shadowling shit in, I have no idea what I'm doing, if there were mistakes made
//feel free to make changes, if it crashes, or just doesn't give anyone roles.

//////////////////////////////////////////////
//                                          //
//                VAMPIRE                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampire"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	protected_roles = list("Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Security Officer", "Chaplain", "Detective", "Warden", "Brig Physician")
	restricted_roles = list("Cyborg", "AI")
	required_candidates = 3
	weight = 3
	cost = 8
	scaling_cost = 9
	requirements = list(80,70,60,50,50,45,30,30,25,20)
	antag_cap = list("denominator" = 24)
	minimum_players = 30
	antag_cap = list(3,3,3,3,3,3,3,3,3,4)
	var/autovamp_cooldown = (15 MINUTES)
	COOLDOWN_DECLARE(autovamp_cooldown_check)

/datum/dynamic_ruleset/roundstart/vampire/pre_execute(population)
	. = ..()
	COOLDOWN_START(src, autovamp_cooldown_check, autovamp_cooldown)
	var/num_vampires = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_vampires)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_VAMPIRE
		M.mind.restricted_roles = restricted_roles
	return TRUE

/datum/dynamic_ruleset/roundstart/vampire/rule_process()
	if (COOLDOWN_FINISHED(src, autovamp_cooldown_check))
		COOLDOWN_START(src, autovamp_cooldown_check, autovamp_cooldown)
		mode.picking_specific_rule(/datum/dynamic_ruleset/midround/autovamp)

//////////////////////////////////////////////
//                                          //
//                RAGIN' MAGES				//
//                                          //
//////////////////////////////////////////////

// Dynamic is a wonderful thing that adds wizards to every round and then adds even more wizards during the round.
/datum/dynamic_ruleset/roundstart/wizard/ragin
	name = "Ragin' Mages"
	antag_flag = ROLE_RAGINMAGES
	antag_datum = /datum/antagonist/wizard/
	flags = LONE_RULESET
	minimum_required_age = 14
	restricted_roles = list("Head of Security", "Captain") // Just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 1
	weight = 1
	cost = 100
	requirements = list(100,100,100,100,90,90,85,85,85,80)
	antag_cap = list(5,5,5,5,5,5,5,5,5,5)
	roundstart_wizards = list()

/datum/dynamic_ruleset/roundstart/wizard/ragin/pre_execute()
	if(GLOB.wizardstart.len == 0)
		return FALSE

	for(var/i in antag_cap[indice_pop])
		var/mob/M = pick_n_take(candidates)
		if (M)
			assigned += M.mind
			M.mind.assigned_role = ROLE_RAGINMAGES
			M.mind.special_role = ROLE_RAGINMAGES
		else
			break

	return TRUE

//////////////////////////////////////////////
//                                          //
//              BULLSHIT MAGES				//
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard/ragin/bullshit
	name = "Bullshit Mages"
	antag_flag = ROLE_BULLSHITMAGES
	antag_datum = /datum/antagonist/wizard/
	flags = LONE_RULESET
	minimum_required_age = 14
	restricted_roles = list()
	required_candidates = 4
	weight = 1
	cost = 101
	minimum_players = 40
	requirements = list(100,100,100,100,100,100,100,100,100,100)
	antag_cap = list(999,999,999,999,999)
	
/datum/dynamic_ruleset/roundstart/wizard/ragin/bullshit/pre_execute()
	. = ..()
	if(.)
		log_admin("Shit is about to get wild. -Bullshit Wizards")

		return TRUE

//////////////////////////////////////////////
//                                          //
//                DARKSPAWN                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/darkspawn
	name = "Darkspawn"
	antag_flag = ROLE_DARKSPAWN
	antag_datum = /datum/antagonist/darkspawn/
	minimum_required_age = 20
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician")
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 3
	weight = 3
	cost = 20
	scaling_cost = 20
	antag_cap = 3
	requirements = list(80,75,70,65,50,30,30,30,25,20)
	minimum_players = 35

/datum/dynamic_ruleset/roundstart/darkspawn/pre_execute(population)
	. = ..()
	var/num_darkspawn = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_darkspawn)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_DARKSPAWN
		M.mind.restricted_roles = restricted_roles
		log_game("[key_name(M)] has been selected as a Darkspawn")
	return TRUE

//////////////////////////////////////////////
//                                          //
//               BLOODSUCKER                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodsucker
	name = "Bloodsuckers"
	antag_flag = ROLE_BLOODSUCKER
	antag_datum = /datum/antagonist/bloodsucker
	protected_roles = list(
		"Captain", "Head of Personnel", "Head of Security",
		"Warden", "Security Officer", "Detective", "Brig Physician",
		"Curator"
	)
	restricted_roles = list("AI", "Cyborg")
	required_candidates = 1
	weight = 5
	cost = 10
	scaling_cost = 9
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	antag_cap = list("denominator" = 24)
	minimum_players = 25

/datum/dynamic_ruleset/roundstart/bloodsucker/trim_candidates()
	. = ..()
	for(var/mob/living/player in candidates)
		if(player?.client?.prefs.pref_species && (NOBLOOD in player.client.prefs.pref_species.species_traits))
			candidates.Remove(player)

/datum/dynamic_ruleset/roundstart/bloodsucker/pre_execute(population)
	. = ..()
	var/num_bloodsuckers = get_antag_cap(population) * (scaled_times + 1)

	for(var/i = 1 to num_bloodsuckers)
		if(candidates.len <= 0)
			break
		var/mob/selected_mobs = pick_n_take(candidates)
		assigned += selected_mobs.mind
		selected_mobs.mind.restricted_roles = restricted_roles
		selected_mobs.mind.special_role = ROLE_BLOODSUCKER
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodsucker/execute()
	for(var/assigned_bloodsuckers in assigned)
		var/datum/mind/bloodsuckermind = assigned_bloodsuckers
		if(!bloodsuckermind.make_bloodsucker(assigned_bloodsuckers))
			assigned -= assigned_bloodsuckers
	return TRUE

//////////////////////////////////////////////
//                                          //
//         Internal Affairs Agents          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/iaa
	name = "Internal Affairs Agents"
	persistent = TRUE
	antag_flag = ROLE_INTERNAL_AFFAIRS
	antag_datum = /datum/antagonist/traitor/internal_affairs
	minimum_required_age = 0
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("Cyborg", "AI")
	required_candidates = 1
	weight = 5
	cost = 10
	scaling_cost = 9
	requirements = list(25,25,25,25,25,25,25,25,25,25)
	antag_cap = list("denominator" = 24)

/datum/dynamic_ruleset/roundstart/iaa/pre_execute(population)
	. = ..()
	var/num_traitors = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_traitors)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_INTERNAL_AFFAIRS
		M.mind.restricted_roles = restricted_roles
		log_game("[key_name(M)] has been selected as a Internal Affairs Agent")
	return TRUE
