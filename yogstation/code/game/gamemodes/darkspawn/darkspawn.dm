/datum/game_mode
	var/sacrament_done = FALSE //If at least one darkspawn has finished the Sacrament

/datum/game_mode/darkspawn
	name = "darkspawn"
	config_tag = "darkspawn"
	antag_flag = ROLE_DARKSPAWN
	required_players = 15
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 15
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician") //Added Brig Physician
	title_icon = "ss13"
	var/datum/team/darkspawn/team

/datum/game_mode/darkspawn/announce()
	to_chat(world, "<b>The current game mode is - Darkspawn!</b>")
	to_chat(world, "<b>There are alien [span_velvet("darkspawn")] on the station. Crew: Kill the darkspawn before they can complete the Sacrament. Darkspawn: Consume enough lucidity to complete the Sacrament and become the ultimate lifeform.</b>")

/datum/game_mode/darkspawn/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/darkbois = max(required_enemies, round((num_players()-5)/10)) //scaling number of darkspawns, but at least 1

	team = new
	while(darkbois)
		var/datum/mind/darkboi = antag_pick(antag_candidates)
		antag_candidates -= darkboi
		darkboi.special_role = "Darkspawn"
		darkboi.restricted_roles = restricted_jobs
		darkbois--

	team.update_objectives()
	GLOB.thrallnet.name = "Thrall net"
	return TRUE

/datum/game_mode/darkspawn/generate_report()
	return "Sightings of strange alien creatures have been observed in your area. These aliens appear to be searching for specific patterns of brain activity, with their method for doing so causing victims to lapse into a short coma. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Investigate all reports of odd or suspicious sightings in maintenance, and be on the lookout for anyone sympathizing with these aliens, as they may be compromised"

/datum/game_mode/darkspawn/post_setup()
	for(var/T in team.members)
		var/datum/mind/darkboi = T
		log_game("[darkboi.key] (ckey) has been selected as a darkspawn.")
		darkboi.current.add_darkspawn()
	. = ..()
	return

/datum/game_mode/darkspawn/proc/check_darkspawn_victory()
	return sacrament_done

/datum/game_mode/darkspawn/proc/check_darkspawn_death()
	for(var/DM in get_antag_minds(/datum/antagonist/darkspawn))
		var/datum/mind/dark_mind = DM
		if(istype(dark_mind))
			if((dark_mind) && (dark_mind.current.stat != DEAD) && !issilicon(dark_mind))
				return FALSE
	return TRUE

/datum/game_mode/darkspawn/check_finished()
	. = ..()
	if(. && check_darkspawn_death())
		return TRUE

/datum/game_mode/darkspawn/set_round_result()
	..()
	if(check_darkspawn_victory())
		SSticker.mode_result = "win - the darkspawn have completed the Sacrament"
	else
		SSticker.mode_result = "loss - staff stopped the darkspawn"

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

/datum/game_mode/darkspawn/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Darkspawn:</h1>"
	len_before_addition = round_credits.len
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The Darkspawn have moved to the shadows!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
