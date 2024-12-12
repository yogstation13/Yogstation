/datum/heretic_knowledge/ultimate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// there's literally a big unique announcement saying "HEY THIS PERSON'S AN ASCENDED HERETIC", no reason to not have them in the orbit menu
	heretic_datum.show_to_ghosts = TRUE
	heretic_datum.antagpanel_category = "Ascended Heretics"
	var/static/have_set_lambda = FALSE
	if(!have_set_lambda)
		var/ascended_heretics = 1
		for(var/datum/antagonist/heretic/heretic in GLOB.antagonists)
			var/mob/living/heretic_body = heretic.owner?.current
			if(QDELETED(heretic_body) || heretic_body == user || !heretic.ascended || heretic_body.stat == DEAD)
				continue
			ascended_heretics++
		if(ascended_heretics >= 3)
			have_set_lambda = TRUE
			message_admins("Alert level automatically being raised to Lambda in 5 seconds due to the presence of three or more living ascended heretics")
			addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_LAMBDA), 5 SECONDS, TIMER_UNIQUE)
