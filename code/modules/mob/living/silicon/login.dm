/mob/living/silicon/Login()
	mind?.remove_antags_for_borging()
	return ..()


/mob/living/silicon/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || (client.prefs?.toggles & DEADMIN_POSITION_SILICON))
		return client.holder.auto_deadmin()
	return ..()

/// Remove the antagonists that should not persist when being borged
/datum/mind/proc/remove_antags_for_borging()
	remove_antag_datum(/datum/antagonist/cult)

	var/datum/antagonist/rev/revolutionary = has_antag_datum(/datum/antagonist/rev)
	revolutionary?.remove_revolutionary(borged = TRUE)

	if(istype(current, /mob/living/brain))
		var/mob/living/brain/current_brain = current
		if(current_brain.container && !istype(current_brain.container.laws, /datum/ai_laws/ratvar))
			var/datum/antagonist/clockcult/clock_datum = has_antag_datum(/datum/antagonist/clockcult)
			clock_datum.silent = TRUE
			clock_datum.on_removal()
