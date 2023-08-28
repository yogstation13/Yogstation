/datum/controller/subsystem/processing/quirks/proc/checkquirks(mob/living/user,client/cli) // Returns true when the player isn't trying to fuckin scum the mood pref stuff to exploit

	var/points = 0;
	var/good_quirks = 0;

	for(var/V in cli.prefs.all_quirks)
		var/datum/quirk/Q = quirks[V]
		if(Q)
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
