/datum/vote/wanna_do
	name = "What do you want to do"
	message = "An admin wants to know what you wanna do!"
	count_method = VOTE_COUNT_METHOD_MULTI

/// Gamemode vote, sorta

/datum/vote/wanna_do/New()
	. = ..()

	default_choices = list()

	for(var/datum/round_event_control/antagonist/solo/event as anything in subtypesof(/datum/round_event_control/antagonist/solo))
		if(!initial(event.roundstart))
			continue
		if(!initial(event.name))
			continue
		default_choices |= initial(event.name)
	
	sort_list(default_choices, cmp = /proc/cmp_text_dsc)

/datum/vote/wanna_do/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(!.)
		return FALSE

	// Vote only for admins to start.
	// (Either an admin makes it, or otherwise.)
	return forced
