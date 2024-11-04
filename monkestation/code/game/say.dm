/mob/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if(client && (radio_freq && (radio_freq == FREQ_COMMON || radio_freq < MIN_FREQ)))
		var/atom/movable/virtualspeaker/vspeaker = speaker
		if(isAI(vspeaker.source))
			playsound_local(
				get_turf(src),
				'goon/sounds/radio_ai.ogg',
				vol = 170,
				vary = TRUE,
				pressure_affected = FALSE,
				use_reverb = FALSE,
				mixer_channel = CHANNEL_MOB_SOUNDS
			)
