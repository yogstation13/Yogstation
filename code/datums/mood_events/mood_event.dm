/datum/mood_event
	var/description ///For descriptions, use the span classes bold nicegreen, nicegreen, none, warning and boldwarning in order from great to horrible.
	var/mood_change = 0
	var/timeout = 0
	var/hidden = FALSE//Not shown on examine
	var/category //string of what category this mood was added in as
	var/special_screen_obj //if it isn't null, it will replace or add onto the mood icon with this (same file). see happiness drug for example
	var/special_screen_replace = TRUE //if false, it will be an overlay instead
	var/datum/component/mood/owner
	/// List of required jobs for this mood event.
	var/list/required_job = list()

/datum/mood_event/New(mob/M, param)
	owner = M
	if(length(required_job) > 0)
		var/mob/living/living_human = owner.parent
		if(living_human && living_human.mind && !(find_job(living_human.mind) in required_job))
			qdel(src)
			return
	add_effects(param)

/datum/mood_event/Destroy()
	remove_effects()
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/remove_effects()
	return
