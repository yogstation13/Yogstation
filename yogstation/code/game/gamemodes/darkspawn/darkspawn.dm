/datum/game_mode
	var/list/datum/mind/darkspawn = list()
	var/list/datum/mind/veils = list()
	//var/required_succs = 15 //How many succs are needed (this is changed in pre_setup, so it scales based on pop)
	var/sacrament_done = FALSE //If at least one darkspawn has finished the Sacrament

/datum/game_mode/darkspawn
	name = "darkspawn"
	config_tag = "darkspawn"
	antag_flag = ROLE_DARKSPAWN
	required_players = 26
	required_enemies = 3
	recommended_enemies = 3
	enemy_minimum_age = 15
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")

/datum/game_mode/darkspawn/announce()
	to_chat(world, "<b>The current game mode is - Darkspawn!</b>")
	to_chat(world, "<b>There are alien <span class='velvet'>darkspawn</span> on the station. Crew: Kill the darkspawn before they can complete the Sacrament. Darkspawn: Consume enough lucidity to complete the Sacrament and become the ultimate lifeform.</b>")

/datum/game_mode/darkspawn/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	var/darkbois = max(3, round(num_players()/14))
	while(darkbois)
		var/datum/mind/darkboi = pick(antag_candidates)
		darkspawn += darkboi
		antag_candidates -= darkboi
		darkboi.special_role = "Darkspawn"
		darkboi.restricted_roles = restricted_jobs
		darkbois--
	return TRUE

/datum/game_mode/darkspawn/generate_report()
	return "Sightings of strange alien creatures have been observed in your area. These aliens appear to be searching for specific patterns of brain activity, with their method for doing so causing victims to lapse into a short coma. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Investigate all reports of odd or suspicious sightings in maintenance."

/datum/game_mode/darkspawn/post_setup()
	for(var/T in darkspawn)
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
			if((dark_mind) && (dark_mind.current.stat != DEAD) && ishuman(dark_mind.current))
				return FALSE
	return TRUE

/datum/game_mode/darkspawn/check_finished()
	. = ..()
	if(check_darkspawn_death())
		return TRUE

/datum/game_mode/proc/auto_declare_completion_darkspawn()
	var/text = ""
	if(darkspawn.len)
		text += "<br><span class='big'><b>The darkspawn were:</b></span>"
		for(var/D in darkspawn)
			var/datum/mind/darkboi = D
			text += printplayer(darkboi)
		text += "<br>"
		/*if(veils.len)
			text += "<br><span class='big'><b>The veils were:</b></span>"
			for(var/V in veils)
				var/datum/mind/veil = V
				text += printplayer(veil)*/
	text += "<br>"
	to_chat(world, text)

/datum/game_mode/darkspawn/set_round_result()
	..()
	if(check_darkspawn_victory())
		SSticker.mode_result = "win - the darkspawn have completed the Sacrament"
	else
		SSticker.mode_result = "loss - staff stopped the darkspawn"

/datum/game_mode/proc/update_darkspawn_icons_added(datum/mind/darkspawn_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_DARKSPAWN]
	hud.join_hud(darkspawn_mind.current)
	set_antag_hud(darkspawn_mind.current, "darkspawn")

/datum/game_mode/proc/update_darkspawn_icons_removed(datum/mind/darkspawn_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_DARKSPAWN]
	hud.leave_hud(darkspawn_mind.current)
	set_antag_hud(darkspawn_mind.current, null)

/mob/living/proc/add_darkspawn()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/darkspawn)

/mob/living/proc/remove_darkspawn()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/darkspawn)