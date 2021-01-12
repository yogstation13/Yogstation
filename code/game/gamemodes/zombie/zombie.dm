#define ZOMBIE_SCALING_COEFFICIENT 18.5 //Roughly one new zombie at roundstart per this many players

GLOBAL_LIST_EMPTY(zombies)

/proc/isinfected(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/zombie)


/datum/game_mode/zombie
	name = "zombie"
	config_tag = "zombie"
	report_type = "zombie"
	antag_flag = ROLE_ZOMBIE
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Medical Officer")
	required_players = 40
	required_enemies = 3
	recommended_enemies = 3
	enemy_minimum_age = 14

	announce_span = "zombie"
	announce_text = "Some crew members have been infected with a zombie virus!\n\
	<span class='danger'>Zombies</span>: Take over the station!.\n\
	<span class='notice'>Crew</span>: Kill the zombies and escape!."

	var/list/people_to_infect = list() //the zombies we'll infect at roundstart

	var/datum/team/zombie/main_team

	var/actual_roundstart_zombies = 0


/datum/game_mode/zombie/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	//Scaling!
	recommended_enemies = 1 + round(num_players() / ZOMBIE_SCALING_COEFFICIENT) //Minimum 1 enemy, at 40 pop (1 + 40/18.5) = 2.16161, rounded to 1+2 = 3
	var/remaining = (num_players() % ZOMBIE_SCALING_COEFFICIENT) * 10 / 2.5 //Basically the % of how close the population is toward adding another zombie. Division is on purpose.
	//12% chance of 4 zombies at 40 players,
	//72% at 55 players.
	if(prob(remaining))
		recommended_enemies++

	for(var/zombies = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/zombie = antag_pick(antag_candidates)
		antag_candidates -= zombie
		people_to_infect += zombie
		zombie.special_role = ROLE_ZOMBIE
		zombie.restricted_roles = restricted_jobs

	if(people_to_infect.len >= required_enemies)
		return TRUE
	else
		setup_error = "Not enough zombie candidates."
		return FALSE

/datum/game_mode/zombie/proc/can_evolve_tier_2()
	var/count = 0
	for(var/Z in GLOB.zombies)
		var/datum/mind/zombie = Z
		if(!zombie.current)
			continue
		var/mob/living/carbon/human/H = zombie.current
		if(H)
			if(H.stat == DEAD || QDELETED(H))
				continue
			if(istype(H.dna.species, /datum/species/zombie/infectious/gamemode/necromancer))
				count++
			else if(istype(H.dna.species, /datum/species/zombie/infectious/gamemode/coordinator))
				count++

	if(count < actual_roundstart_zombies)
		return TRUE
	return FALSE

/datum/game_mode/zombie/post_setup()
	main_team = new

	main_team.setup_objectives()

	for(var/M in people_to_infect)
		var/datum/mind/minds = M
		var/datum/antagonist/zombie/antag = add_zombie(minds)
		if(!istype(antag))
			continue
		actual_roundstart_zombies++
		antag.start_timer()

	addtimer(CALLBACK(src, .proc/call_shuttle), 60 MINUTES) //Shuttle called after 1 hour if it hasn't been
	. = ..()

/datum/game_mode/zombie/proc/call_shuttle()
	priority_announce("Foreign Biosignatures present onboard station. Activating automatic evacuation system...")
	SSshuttle.emergencyNoRecall = TRUE
	if(EMERGENCY_IDLE_OR_RECALLED)
		SSshuttle.emergency.request(null, set_coefficient=0.5)

/datum/game_mode/zombie/proc/add_zombie(datum/mind/zombie_mind)
	if (!istype(zombie_mind))
		return FALSE

	if(!main_team)
		return FALSE

	return zombie_mind.add_antag_datum(/datum/antagonist/zombie, main_team)

/datum/game_mode/zombie/check_finished()
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(station_was_nuked)
		return TRUE
	return FALSE

/datum/game_mode/zombie/generate_report()
	return "We have lost contact with some local mining outposts. Our rescue teams have found nothing but decaying and rotting corpses. On one of the ships, a body in the morgue 'woke' up and started attacking the crew \
			People seem to 'turn' when attacked by these... Creatures.. We currently estimate their threat level to be VERY HIGH. If the virus somehow makes it onboard your station, send a report to Central Command immediately.\
			The only way to truly kill them is to chop their heads off. We have spotted abnormal evolutions amongst the creatures, suggesting that they have the ability to adapt to the people fighting them. Keep your guard up crew."

#undef ZOMBIE_SCALING_COEFFICIENT