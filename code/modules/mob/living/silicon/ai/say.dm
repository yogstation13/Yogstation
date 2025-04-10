/mob/living/silicon/ai/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(parent && istype(parent) && parent.stat != DEAD) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message, language)
		return
	..(message)

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
	var/M = speaker.GetJob()
	if(M)
		return "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/IsVocal()
	return !CONFIG_GET(flag/silent_ai)

/mob/living/silicon/ai/radio(message, list/message_mods = list(), list/spans, language)
	if(incapacitated())
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, span_danger("Your radio transmitter is offline!"))
		return FALSE
	..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, language)


	message = trim(message)

	if (!message)
		return

	var/obj/machinery/holopad/T = current
	if(istype(T) && T.masters[src])//If there is a hologram and its master is the user.
		var/turf/padturf = get_turf(T)
		var/padloc
		if(padturf)
			padloc = AREACOORD(padturf)
		else
			padloc = "(UNKNOWN)"
		var/obj/effect/overlay/hologram = T.masters[src]
		src.log_talk(message, LOG_SAY, tag="HOLOPAD in [padloc]")
		hologram.say("[message]")
		send_speech(message, 7, T, MODE_ROBOT, message_language = language)
		to_chat(src, "<i><span class='game say'>Holopad transmitted, [span_name("[real_name]")] <span class='message robot'>\"[message]\"</span></span></i>")
	else
		to_chat(src, "No holopad connected.")


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
#define VOX_DELAY 600
/mob/living/silicon/ai/verb/announcement_help()

	set name = "Announcement Help"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"

	if(incapacitated())
		return

	var/dat = {"
	<font class='bad'>WARNING:</font> Misuse of the announcement system will get you job banned.<BR><BR>
	Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR>
	<UL><LI>You can also click on the word to PREVIEW it.</LI>
	<LI>You can only say 30 words for every announcement.</LI>
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI>
	<LI>Numbers are in word format, e.g. eight, sixty, etc </LI>
	<LI>Sound effects begin with an 's' before the actual word, e.g. scensor</LI>
	<LI>Use Ctrl+F to see if a word exists in the list.</LI></UL><HR>
	"}

	var/index = 0
	for(var/word in GLOB.vox_sounds)
		index++
		dat += "<A href='byond://?src=[REF(src)];say_word=[word]'>[capitalize(word)]</A>"
		if(index != GLOB.vox_sounds.len)
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/ai/proc/voice_announce()
	if(GLOB.announcing_vox > world.time)
		to_chat(src, span_notice("Please wait [DisplayTimeText(GLOB.announcing_vox - world.time)]."))
		return
	if(incapacitated())
		return
	if(control_disabled)
		to_chat(src, span_warning("Wireless interface disabled, unable to interact with announcement PA."))
		return

	var/datum/voice_announce/ai/announce_datum = new(client)
	announce_datum.open()

GLOBAL_VAR_INIT(announcing_vox, 0)

/mob/living/silicon/ai/proc/announcement()
	if(GLOB.announcing_vox > world.time)
		to_chat(src, span_notice("Please wait [DisplayTimeText(GLOB.announcing_vox - world.time)]."))
		return

	var/list/types_list = list("Victor (male)", "Verity (female)", "Oscar (military)") //Victor is vox_sounds_male, Verity is vox_sounds, Oscar is vox_sounds_military
	if(!is_banned_from(ckey, "Voice Announcements"))
		types_list += "Use Microphone"
	var/voxType = input(src, "Which voice?", "VOX") in types_list 

	if(voxType == "Use Microphone")
		voice_announce()
		return

	var/message = input(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", src.last_announcement) as text

	last_announcement = message

	if(!message || GLOB.announcing_vox > world.time)
		return

	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, span_warning("Wireless interface disabled, unable to interact with announcement PA."))
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!GLOB.vox_sounds[word] && voxType == "Verity (female)") //yogs start - male vox
			incorrect_words += word
		if(!GLOB.vox_sounds_male[word] && voxType == "Victor (male)")
			incorrect_words += word  //yogs end- male vox
		if(!GLOB.vox_sounds_military[word] && voxType == "Oscar (military)")
			incorrect_words += word

	if(incorrect_words.len)
		to_chat(src, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	GLOB.announcing_vox = world.time + VOX_DELAY

	log_game("[key_name(src)] made a vocal announcement with the following message: [message].")
	var/z_coord = z
	if(istype(loc, /obj/machinery/ai/data_core))
		z_coord = loc.z

	for(var/word in words)
		play_vox_word(word, z_coord, null, voxType) //yogs - male vox


/proc/play_vox_word(word, z_level, mob/only_listener, voxType = "Verity (female)", pitch = 0) // Yogs -- Pitch variation

	word = lowertext(word)

	if( (GLOB.vox_sounds[word] && voxType == "Verity (female)") || (GLOB.vox_sounds_male[word] &&voxType == "Victor (male)") || (GLOB.vox_sounds_military[word] &&voxType == "Oscar (military)") ) //yogs - male vox

		var/sound_file //yogs start - male vox

		if(voxType == "Verity (female)")
			sound_file = GLOB.vox_sounds[word]
		else if(voxType == "Victor (male)")
			sound_file = GLOB.vox_sounds_male[word] //yogs end - male vox
		else
			sound_file = GLOB.vox_sounds_military[word]

		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX)
		voice.status = SOUND_STREAM
		voice.frequency = pitch //Yogs -- Pitch variation

 		// If there is no single listener, broadcast to everyone in the same z level 
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/M in GLOB.player_list)
				if(M.client && M.can_hear() && (M.client.prefs.toggles & SOUND_ANNOUNCEMENTS) && (M.client.prefs.toggles & SOUND_VOX))
					var/turf/T = get_turf(M)
					if(T.z == z_level)
						SEND_SOUND(M, voice)
		else
			SEND_SOUND(only_listener, voice)
		return 1
	return 0

#undef VOX_DELAY
#endif

/mob/living/silicon/ai/could_speak_language(datum/language/dt)
	if(is_servant_of_ratvar(src))
		// Ratvarian AIs can only speak Ratvarian
		. = ispath(dt, /datum/language/ratvar)
	else
		. = ..()
