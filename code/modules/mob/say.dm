//Speech verbs.
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	var/oldmsg = message //yogs start - pretty filter
	message = pretty_filter(message)
	if(oldmsg != message)
		to_chat(usr, "<span class='notice'>You fumble over your words. <a href='https://forums.yogstation.net/index.php?pages/rules/'>See rule 0.1.1</a>.</span>")
		message_admins("[key_name(usr)] just tripped a pretty filter: '[oldmsg]'.")
		return
	if(isliving(src))
		message = minor_filter(to_utf8(message)) //yogs end - pretty filter

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	if(message)
		say(message)


/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"

	var/oldmsg = message //yogs start - pretty filter
	message = pretty_filter(message)
	if(oldmsg != message)
		to_chat(usr, "<span class='notice'>You fumble over your words. <a href='https://forums.yogstation.net/index.php?pages/rules/'>See rule 0.1.1</a>.</span>")
		message_admins("[key_name(usr)] just tripped a pretty filter: '[oldmsg]'.")
		return
	message = to_utf8(minor_filter(message)) //yogs end - pretty filter

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	whisper(message)

/mob/proc/whisper(message, datum/language/language=null)
	say(message, language) //only living mobs actually whisper, everything else just talks

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	usr.emote("me",1,message,TRUE)

/mob/proc/say_dead(var/message)
	var/name = real_name
	var/alt_name = ""

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	var/jb = is_banned_from(ckey, "OOC")
	if(QDELETED(src))
		return

	if(jb)
		to_chat(src, "<span class='danger'>You have been banned from deadchat.</span>")
		return



	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='danger'>You cannot talk in deadchat (muted).</span>")
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

	var/spanned = say_quote(message)
	var/source = "<span class='game'><span class='prefix'>DEAD:</span> <span class='name'>[(src.client.prefs.chat_toggles & GHOST_CKEY) ? "" : "([K]) "][name]</span>[alt_name]" // yogs - i have no clue
	var/rendered = " <span class='message'>[emoji_parse(spanned)]</span></span>"
	log_talk(message, LOG_SAY, tag="DEAD")
	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = key)

/mob/proc/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

/mob/proc/hivecheck()
	return 0

/mob/proc/lingcheck()
	return LINGHIVE_NONE

/mob/proc/get_message_mode(message)
	var/key = message[1]
	if(key == "#")
		return MODE_WHISPER
	else if(key == ";")
		return MODE_HEADSET
	else if((length(message) > (length(key) + 1)) && (key in GLOB.department_radio_prefixes))
		var/key_symbol = lowertext(message[length(key) + 1])
		return GLOB.department_radio_keys[key_symbol]
