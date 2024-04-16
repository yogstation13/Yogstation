/datum/controller/subsystem/processing/quirks/proc/checkquirks(mob/living/user,client/cli) // Returns true when the player isn't trying to fuckin scum the mood pref stuff to exploit
	var/mob/living/carbon/human/U = user
	U.mood_enabled = !CONFIG_GET(flag/disable_human_mood) || cli.prefs.read_preference(/datum/preference/toggle/mood_enabled) // Marks whether this player had moods enabled in preferences at the time of spawning (helps prevent exploitation)
	
	var/ismoody = (!CONFIG_GET(flag/disable_human_mood) || (cli.prefs.read_preference(/datum/preference/toggle/mood_enabled))) // If moods are globally enabled, or this guy does indeed have his mood pref set to Enabled
	
	var/points = 0;
	var/good_quirks = 0;

	for(var/V in cli.prefs.all_quirks)
		var/datum/quirk/Q = quirks[V]
		if(Q)
			if(initial(Q.mood_quirk) && !ismoody)
				to_chat(cli, span_danger("You cannot have the quirk '[V]' with mood disabled! You shall receive no quirks this round."))
				message_admins("[key_name(cli)] just tried to exploit the mood pref system to get bonus points for their quirks.")
				return FALSE
			points += initial(Q.value)
			if(initial(Q.value) > 0)
				good_quirks += 1
	
	if(points > 0)
		to_chat(cli, span_danger("You have a negative quirk point balance. Due to this, quirks will be disabled for this round."))
		message_admins("[key_name(cli)] joined with negative quirk point balance, likely trying to exploit the quirk system.")
		return FALSE
	if(good_quirks > MAX_QUIRKS)
		to_chat(cli, span_danger("You have too many good quirks, Due to this, quirks will be disabled for this round."))
		message_admins("[key_name(cli)] joined with [good_quirks]/[MAX_QUIRKS] good quirks.")
	return TRUE
