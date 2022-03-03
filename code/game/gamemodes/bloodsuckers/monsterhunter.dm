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
	weight = 2000
	min_players = 10
	earliest_start = 35 MINUTES
	alert_observers = FALSE
	gamemode_whitelist = list("bloodsucker", "traitorsucker")

/datum/round_event/bloodsucker_hunters
	fakeable = FALSE

/datum/round_event/bloodsucker_hunters/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || !(ROLE_MONSTERHUNTER in H.client.prefs.be_special))
			continue
		if(H.stat == DEAD)
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.nonhuman_positions)) // Only crewmembers on-station.
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.command_positions))
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.security_positions))
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/vassal))
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/bloodsucker))
			continue
		if(!H.getorgan(/obj/item/organ/brain))
			continue
		H.mind.add_antag_datum(/datum/antagonist/monsterhunter)
		message_admins("BLOODSUCKER NOTICE: [H] has awoken as a Monster Hunter.")
		announce_to_ghosts(H)
		break

/// Randomly spawned Monster hunters during TraitorChangeling, Changeling, Heretic and Cult rounds.
/datum/round_event_control/monster_hunters
	name = "Spawn Monster Hunter"
	typepath = /datum/round_event/monster_hunters
	max_occurrences = 1
	weight = 7
	min_players = 10
	earliest_start = 25 MINUTES
	alert_observers = TRUE
	gamemode_whitelist = list("traitorchan","changeling","heresy","cult","clockwork_cult")

/datum/round_event/monster_hunters
	fakeable = FALSE

/datum/round_event/monster_hunters/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || !(ROLE_MONSTERHUNTER in H.client.prefs.be_special))
			continue
		if(H.stat == DEAD)
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.nonhuman_positions))
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.command_positions))
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in GLOB.security_positions))
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/changeling))
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/clockcult))
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/heretic))
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/cult))
			continue
		if(!H.getorgan(/obj/item/organ/brain))
			continue
		H.mind.add_antag_datum(/datum/antagonist/monsterhunter)
		message_admins("MONSTERHUNTER NOTICE: [H] has awoken as a Monster Hunter.")
		announce_to_ghosts(H)
		break