/mob/camera/flocktrace
	name = "Flocktrace"
	real_name = "Flocktrace"
	desc = "Something like a digital pilot, capable of controling flockdrones."
	initial_language_holder = /datum/language_holder/flock

/mob/camera/flocktrace/Initialize()
	. = ..()
	var/obj/item/radio/headset/silicon/ai/radio = new(src)
	radio.wires.cut(WIRE_TX) 

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

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	src.log_talk(message, LOG_SAY)

	var/message_a = say_quote(message)
	var/rendered = span_swarmer("\[Flock Communication\] [name] [message_a]")

	for(var/mob/M in GLOB.mob_list)
		if(isflockdrone(M) || isflocktrace(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/flocktrace/flockmind
	name = "Flockmind"
	real_name = "Flockmind"
	desc = "The overmind of the flock."

/mob/camera/flocktrace/flockmind/New()
	. = ..()
	if(!GLOB.flock)
		var/datum/team/flock/team = new(mind)
		team.overmind = src
		GLOB.flock = team
	else
		var/datum/team/flock/team = GLOB.flock
		team.overmind = src