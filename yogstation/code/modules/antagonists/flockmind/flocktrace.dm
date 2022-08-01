/mob/camera/flocktrace
	name = "Flocktrace"
	real_name = "Flocktrace"
	desc = "Something like a digital pilot, capable of controling flockdrones."
	initial_language_holder = /datum/language_holder/flock
	var/datum/flock_command/stored_action = null

/mob/camera/flocktrace/Initialize()
	. = ..()
	var/obj/item/radio/headset/silicon/ai/radio = new(src)
	radio.wires.cut(WIRE_TX) 
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

/mob/camera/flocktrace/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	if (!message)
		return

	ping_flock(message, src)

/mob/camera/flocktrace/flockmind
	name = "Flockmind"
	real_name = "Flockmind"
	desc = "The overmind of the flock."

/mob/camera/flocktrace/flockmind/New()
	. = ..()
	var/datum/team/flock/team = get_flock_team(mind)
	team.overmind = src