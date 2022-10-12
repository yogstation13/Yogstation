/*
 * 		MONSTER HUNTERS:
 * 	Their job is to hunt Monsters.
 * 	They spawn by default 35 minutes into a Bloodsucker round,
 * 	They also randomly spawn in other rounds, as some unique flavor.
 * 	They can also be used as Admin-only antags during rounds such as;
 * 	- Changeling murderboning rounds
 * 	- Lategame Cult round
 * 	- Ect.
 */

/// The default, for Bloodsucker rounds.
/datum/round_event_control/bloodsucker_hunters
	name = "Spawn Monster Hunter - Bloodsucker"
	typepath = /datum/round_event/bloodsucker_hunters
	max_occurrences = 1 // We have to see how Bloodsuckers are in game to decide if having more than 1 is beneficial.
	weight = 20
	min_players = 10
	earliest_start = 35 MINUTES
	gamemode_whitelist = list("bloodsucker","traitorsucker")

/datum/round_event/bloodsucker_hunters
	fakeable = FALSE
	var/cancel_me = TRUE

/datum/round_event/bloodsucker_hunters/start()
	for(var/mob/living/carbon/human/all_players in GLOB.player_list)
		if(IS_BLOODSUCKER(all_players))
			message_admins("BLOODSUCKER NOTICE: Monster Hunters found a valid Bloodsucker.")
			cancel_me = FALSE
			break
	if(cancel_me)
		kill()
		return
	for(var/mob/living/carbon/human/all_players in shuffle(GLOB.player_list))
		if(!all_players.client || !all_players.mind || !(ROLE_MONSTERHUNTER in all_players.client.prefs.be_special))
			continue
		if(all_players.client.prefs.yogtoggles & QUIET_ROUND)
			continue
		if(all_players.stat == DEAD)
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.nonhuman_positions)) // Only crewmembers on-station.
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.command_positions))
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.security_positions))
			continue
		if(IS_BLOODSUCKER(all_players) || IS_VASSAL(all_players) || IS_HERETIC(all_players) || iscultist(all_players) || iswizard(all_players) || is_servant_of_ratvar(all_players) || all_players.mind.has_antag_datum(/datum/antagonist/changeling))
			continue
		if(!all_players.getorgan(/obj/item/organ/brain))
			continue
		all_players.mind.add_antag_datum(/datum/antagonist/monsterhunter)
		message_admins("BLOODSUCKER NOTICE: [all_players] has awoken as a Monster Hunter.")
		announce_to_ghosts(all_players)
		break

/// Randomly spawned Monster hunters during TraitorChangeling, Changeling, Heretic and Cult rounds.
/datum/round_event_control/monster_hunters
	name = "Spawn Monster Hunter"
	typepath = /datum/round_event/monster_hunters
	max_occurrences = 1
	weight = 7
	min_players = 10
	earliest_start = 25 MINUTES
	gamemode_whitelist = list("traitorchan","changeling","heresy","cult","clockwork_cult")

/datum/round_event/monster_hunters
	fakeable = FALSE
	var/cancel_me = TRUE

/datum/round_event/monster_hunters/start()
	for(var/mob/living/carbon/human/all_players in GLOB.player_list)
		if(iscultist(all_players) || IS_HERETIC(all_players) || iswizard(all_players) || is_servant_of_ratvar(all_players) || all_players.mind.has_antag_datum(/datum/antagonist/changeling))
			message_admins("MONSTERHUNTER NOTICE: Monster Hunters found a valid Monster.")
			cancel_me = FALSE
			break
	if(cancel_me)
		kill()
		return
	for(var/mob/living/carbon/human/all_players in shuffle(GLOB.player_list))
		/// From obsessed
		if(!all_players.client || !all_players.mind || !(ROLE_MONSTERHUNTER in all_players.client.prefs.be_special))
			continue
		if(all_players.stat == DEAD)
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.nonhuman_positions)) // Only crewmembers on-station.
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.command_positions))
			continue
		if(!SSjob.GetJob(all_players.mind.assigned_role) || (all_players.mind.assigned_role in GLOB.security_positions))
			continue
		/// Bobux no IS_CHANGELING
		if(IS_HERETIC(all_players) || iscultist(all_players) || iswizard(all_players) || is_servant_of_ratvar(all_players) || all_players.mind.has_antag_datum(/datum/antagonist/changeling))
			continue
		if(!all_players.getorgan(/obj/item/organ/brain))
			continue
		all_players.mind.add_antag_datum(/datum/antagonist/monsterhunter)
		message_admins("MONSTERHUNTER NOTICE: [all_players] has awoken as a Monster Hunter.")
		announce_to_ghosts(all_players)
		break
