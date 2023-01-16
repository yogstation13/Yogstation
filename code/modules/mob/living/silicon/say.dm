/mob/living/proc/robot_talk(message)
	log_talk(message, LOG_SAY)

	var/designation = "Default Cyborg"
	var/spans = list(SPAN_ROBOT)

	if(issilicon(src))
		var/mob/living/silicon/player = src
		designation = trim_left(player.designation + " " + player.job)

	if(isAI(src))
		// AIs are loud and ugly
		spans |= SPAN_COMMAND

	var/quoted_message = say_quote(
		message,
		spans
	)

	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			if(isAI(M))
				to_chat(
					M,
					span_binarysay("\
						Robotic Talk, \
						<a href='?src=[REF(M)];track=[html_encode(name)]'>[span_name("[name] ([designation])")]</a> \
						[span_message("[quoted_message]")]\
					")
				)
			else
				to_chat(
					M,
					span_binarysay("\
						Robotic Talk, \
						[span_name("[name]")] [span_message("[quoted_message]")]\
					")
				)

		if(isobserver(M))
			var/following = src

			// If the AI talks on binary chat, we still want to follow
			// its camera eye, like if it talked on the radio

			if(isAI(src))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj

			var/follow_link = FOLLOW_LINK(M, following)

			to_chat(
				M,
				span_binarysay("\
					[follow_link] \
					Robotic Talk, \
					[span_name("[name]")] [span_message("[quoted_message]")]\
				")
			)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/lingcheck()
	return 0 //Borged or AI'd lings can't speak on the ling channel.

/mob/living/silicon/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(. != 0)
		return .

	if(message_mods[MODE_HEADSET])
		if(radio)
			radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE

	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return 0
