#define ZOMBIE_SCALING_COEFFICIENT 18.5 //Roughly one new zombie at roundstart per this many players


/datum/game_mode
	var/list/datum/mind/zombies = list()

/proc/isinfected(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/zombie)


/datum/game_mode/zombie
	name = "zombie"
	config_tag = "zombie"
	report_type = "zombie"
	antag_flag = ROLE_ZOMBIE
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Medical Officer")
	protected_jobs = list()
	required_players = 40
	required_enemies = 3
	recommended_enemies = 3
	enemy_minimum_age = 14

	announce_span = "zombie"
	announce_text = "Some crew members have been infected with a zombie virus!\n\
	<span class='cult'>Zombies</span>: Take over the station!.\n\
	<span class='notice'>Crew</span>: Kill the zombies and escape!."

	var/list/people_to_infect = list() //the cultists we'll convert

	var/datum/team/zombie/main_team


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


/datum/game_mode/zombie/post_setup()
	main_team = new

	main_team.setup_objectives()

	for(var/datum/mind/minds in people_to_infect)
		var/datum/antagonist/zombie/antag = add_zombie(minds)
		if(!istype(antag))
			continue
		antag.start_timer()

	addtimer(CALLBACK(src, .proc/call_shuttle), 90 MINUTES) //Shuttle called after 1.5 hours if it hasn't been
	. = ..()

/datum/game_mode/zombie/proc/call_shuttle()
	if(EMERGENCY_IDLE_OR_RECALLED)
		priority_announce("Foreign Biosignatures present onboard station. Activating automatic evacuation system...")
		SSshuttle.emergency.request(null, set_coefficient=0.5)
		SSshuttle.emergencyNoRecall = TRUE

/datum/game_mode/zombie/proc/add_zombie(datum/mind/zombie_mind)
	if (!istype(zombie_mind))
		return FALSE

	if(!main_team)
		return FALSE

	var/datum/antagonist/zombie/new_zombie = new()

	return zombie_mind.add_antag_datum(new_zombie, main_team)

/datum/game_mode/zombie/check_finished()
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(station_was_nuked)
		return TRUE
	return FALSE


#undef ZOMBIE_SCALING_COEFFICIENT