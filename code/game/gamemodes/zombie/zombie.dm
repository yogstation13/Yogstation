

/datum/game_mode
	var/list/datum/mind/zombies = list()

/proc/iszombo(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/zombie)


/datum/game_mode/zombie
	name = "zombie"
	config_tag = "zombie"
	report_type = "zombie"
	antag_flag = ROLE_BLOB
	false_report_weight = 0
	restricted_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Medical Officer")
	protected_jobs = list()
	required_players = 1
	required_enemies = 1
	recommended_enemies =1
	enemy_minimum_age = 0

	announce_span = "hey"
	announce_text = " hrtSie!\n\
	<span class='cult'>Cultists</span>:reyu ill.\n\
	<span class='notice'>htr</span>: Prevent htr out."

	var/list/cultists_to_cult = list() //the cultists we'll convert

	var/datum/team/zombie/main


/datum/game_mode/zombie/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	//cult scaling goes here
	recommended_enemies = 3


	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = antag_pick(antag_candidates)
		antag_candidates -= cultist
		cultists_to_cult += cultist
		cultist.special_role = ROLE_BLOB
		cultist.restricted_roles = restricted_jobs
		//log_game("[key_name(cultist)] has been selected as a cultist") | yogs - redundant

	if(cultists_to_cult.len>=required_enemies)
		return TRUE
	else
		setup_error = "Not enough cultist candidates"
		return FALSE


/datum/game_mode/zombie/post_setup()
	cult = new

	for(var/datum/mind/cult_mind in cultists_to_cult)
		add_zombie(cult_mind, 0, equip=TRUE, cult_team = main)

	main.setup_objectives() //Wait until all cultists are assigned to make sure none will be chosen as sacrifice.

	. = ..()

/datum/game_mode/proc/add_zombie(datum/mind/cult_mind, stun , equip = FALSE, datum/team/cult/cult_team = null)
	if (!istype(cult_mind))
		return FALSE

	var/datum/antagonist/zombie/new_cultist = new()

	if(cult_mind.add_antag_datum(new_cultist, cult_team))
		return TRUE


/datum/game_mode/zombie/proc/check_cult_victory()
	return FALSE
