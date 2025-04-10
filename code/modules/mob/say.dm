//Speech verbs.

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	create_typing_indicator()
	window_typing = TRUE

	var/message = input("", "Say \"text\"") as null|text

	window_typing = FALSE
	remove_typing_indicator()

	if (message)
		say_verb(message)

///Say verb
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	//yogs start - pretty filter
	if(isnotpretty(message))
		if(client.prefs.muted & MUTE_IC)
			return
		client.handle_spam_prevention("PRETTY FILTER", MUTE_ALL) // Constant message mutes someone faster for not pretty messages
		to_chat(usr, span_notice("You fumble over your words. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>."))
		var/log_message = "[key_name(usr)] just tripped a pretty filter: '[message]'."
		message_admins(log_message)
		log_say(log_message)
		return
	if(isliving(src))
		message = minor_filter(message) //yogs end - pretty filter

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return
	if(message)
		say(message)

///Whisper verb
/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"

	//yogs start - pretty filter
	if(isnotpretty(message))
		if(client.prefs.muted & MUTE_IC)
			return
		client.handle_spam_prevention("PRETTY FILTER", MUTE_ALL) // Constant message mutes someone faster for not pretty messages
		to_chat(usr, span_notice("You fumble over your words. <a href='https://forums.yogstation.net/help/rules/#rule-0_1'>See rule 0.1</a>."))
		var/log_message = "[key_name(usr)] just tripped a pretty filter: '[message]'."
		message_admins(log_message)
		log_say(log_message)
		return
	message = minor_filter(message) //yogs end - pretty filter

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return
	whisper(message)

/**
 * Whisper a message.
 *
 * Basic level implementation just speaks the message, nothing else.
 */
/mob/proc/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	if(!message)
		return
	say(message, language = language)

/mob/verb/me_wrapper()
	set name = ".me"
	set hidden = TRUE

	create_typing_indicator()
	window_typing = TRUE

	var/message = input("", "Me \"text\"") as null|text

	window_typing = FALSE
	remove_typing_indicator()

	if (message)
		me_verb(message)

///The me emote verb
/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	usr.emote("me",1,message,TRUE)

///Speak as a dead person (ghost etc)
/mob/proc/say_dead(message)
	var/name = real_name
	var/alt_name = ""

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	var/jb = is_banned_from(ckey, "DEAD")
	if(QDELETED(src))
		return

	if(jb)
		to_chat(src, span_danger("You have been banned from deadchat."))
		return



	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, span_danger("You cannot talk in deadchat (muted)."))
			return

		if(src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	var/mob/dead/observer/O = src
	if(isobserver(src) && O.deadchat_name)
		name = "[O.deadchat_name]"
	else
		if(mind && mind.name)
			name = "[mind.name]"
		else
			name = real_name
		if(name != real_name)
			alt_name = " (died as [real_name])"

	var/K

	if(key)
		K = src.key

	var/spanned = say_quote(say_emphasis(message))
	var/source = "<span class='game'>[span_prefix("DEAD:")] [span_name("[(src.client.prefs.chat_toggles & GHOST_CKEY) ? "" : "([K]) "][name]")][alt_name]" // yogs - i have no clue
	var/rendered = " [span_message("[emoji_parse(spanned)]")]</span>"
	log_talk(message, LOG_SAY, tag="DEAD")
	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = key)

///Check if this message is an emote
/mob/proc/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

///Check if the mob has a hivemind channel
/mob/proc/hivecheck()
	return 0

///Check if the mob has a ling hivemind
/mob/proc/lingcheck()
	return LINGHIVE_NONE

///The amount of items we are looking for in the message
#define MESSAGE_MODS_LENGTH 6

/**
  * Extracts and cleans message of any extenstions at the begining of the message
  * Inserts the info into the passed list, returns the cleaned message
  *
  * Result can be
  * * SAY_MODE (Things like aliens, channels that aren't channels)
  * * MODE_WHISPER (Quiet speech)
  * * MODE_SING (Singing)
  * * MODE_HEADSET (Common radio channel)
  * * RADIO_EXTENSION the extension we're using (lots of values here)
  * * RADIO_KEY the radio key we're using, to make some things easier later (lots of values here)
  * * LANGUAGE_EXTENSION the language we're trying to use (lots of values here)
  */
/mob/proc/get_message_mods(message, list/mods)
	for(var/I in 1 to MESSAGE_MODS_LENGTH)
		var/key = message[1]
		var/chop_to = 2 //By default we just take off the first char
		if(key == MODE_KEY_WHISPER && !mods[WHISPER_MODE])
			mods[WHISPER_MODE] = MODE_WHISPER
		else if(key == MODE_KEY_SING && !mods[MODE_SING])
			mods[MODE_SING] = TRUE
		else if(key == MODE_KEY_HEADSET && !mods[MODE_HEADSET])
			mods[MODE_HEADSET] = TRUE
		else if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION] && (lowertext(message[1 + length(key)]) in (GLOB.department_radio_keys + GLOB.special_radio_keys)))
			mods[RADIO_KEY] = lowertext(message[1 + length(key)])
			mods[RADIO_EXTENSION] = GLOB.department_radio_keys[mods[RADIO_KEY]]
			chop_to = length(key) + 2
		else if(key == LANGUAGE_EXTENSION_KEY && !mods[LANGUAGE_EXTENSION])
			for(var/ld in GLOB.all_languages)
				var/datum/language/LD = ld
				if(initial(LD.key) == message[1 + length(message[1])])
					// No, you cannot speak in xenocommon just because you know the key
					if(!can_speak_language(LD))
						return message
					mods[LANGUAGE_EXTENSION] = LD
					chop_to = length(key) + length(initial(LD.key)) + 1
			if(!mods[LANGUAGE_EXTENSION])
				return message
		else
			return message
		message = trim_left(copytext_char(message, chop_to))
		if(!message)
			return
	return message
