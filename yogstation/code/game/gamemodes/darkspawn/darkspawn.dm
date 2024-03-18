/datum/game_mode
	var/sacrament_done = FALSE //If at least one darkspawn has finished the Sacrament

/datum/game_mode/darkspawn
	name = "darkspawn"
	config_tag = "darkspawn"
	antag_flag = ROLE_DARKSPAWN
	required_players = 10
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 15
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician") //Added Brig Physician
	title_icon = "ss13" //to do, give them a new title icon
	round_ends_with_antag_death = TRUE
	var/list/datum/mind/darkspawns = list()
	var/datum/team/darkspawn/team

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Gamemode Setup-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/darkbois = max(required_enemies, round((num_players())/10)) //scaling number of darkspawns, but at least 1

	team = new
	while(darkbois)
		var/datum/mind/darkboi = antag_pick(antag_candidates)
		antag_candidates -= darkboi
		darkspawns += darkboi
		darkboi.restricted_roles = restricted_jobs
		darkbois--
	team.update_objectives()
	GLOB.thrallnet.name = "Thrall net"

	if(!team || !LAZYLEN(darkspawns))
		setup_error = "Error setting up darkspawns"
		return FALSE
	return TRUE

/datum/game_mode/darkspawn/post_setup()
	for(var/datum/mind/darkboi as anything in darkspawns)
		if(darkboi.current.add_darkspawn())
			log_game("[darkboi.key] (ckey) has been selected as a darkspawn.")
			darkboi.special_role = "Darkspawn"
	. = ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Non-Secret mode stuff-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/announce()
	to_chat(world, "<b>The current game mode is - Darkspawn!</b>")
	to_chat(world, "<b>There are [span_velvet("darkspawn")] on the station. Crew: Kill the darkspawn before they can complete the Sacrament. Darkspawn: Consume enough lucidity to complete the Sacrament and ascend once again.</b>")

/datum/game_mode/darkspawn/generate_report()
	return "Sightings of strange alien creatures have been observed in your area. These aliens appear to be searching for specific patterns of brain activity, with their method for doing so causing victims to lapse into a short coma. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Investigate all reports of odd or suspicious sightings in maintenance, and be on the lookout for anyone sympathizing with these aliens, as they may be compromised"

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Game end checks---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/are_special_antags_dead()
	for(var/datum/mind/dark_mind as anything in team.members)
		if(dark_mind?.current?.stat != DEAD) //they can be borgs, their mind is all that really matters
			return FALSE
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------After game end stuff--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/set_round_result()
	..()
	if(sacrament_done)
		SSticker.mode_result = "win - the darkspawn have completed the sacrament"
	else
		SSticker.mode_result = "loss - staff stopped the darkspawn"

/datum/game_mode/darkspawn/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Darkspawn:</h1>"
	len_before_addition = round_credits.len
	if(team)
		for(var/datum/mind/current in team.members)
			round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The Darkspawn have moved to the shadows!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Mob assign procs---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/proc/add_darkspawn()
	if(!istype(mind))
		return FALSE		
	return mind.add_antag_datum(/datum/antagonist/darkspawn)

/mob/living/proc/remove_darkspawn()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/darkspawn)

/mob/living/proc/add_veil()
	if(!istype(mind))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		src.visible_message(span_warning("[src] seems to resist an unseen force!"))
		to_chat(src, "<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \n\
		A mind brushes against your own. You dream.\n\
		Of a vast, empty Void in the deep of space.\n\
		Something lies in the Void. Ancient. Unknowable. It watches you with hungry eyes. \n\
		Eyes filled with stars.</b>\n\
		[span_boldwarning("The creature's gaze swallows the universe into blackness.")])\n\
		[span_boldwarning("It cannot be permitted to succeed.")]")
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/veil)

/mob/living/proc/remove_veil()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/veil)
