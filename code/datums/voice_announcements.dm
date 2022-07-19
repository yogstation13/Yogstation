GLOBAL_LIST_EMPTY(voice_announce_list)

/datum/voice_announce
	var/id
	var/client/client
	var/is_ai = FALSE
	var/started_playing = FALSE
	var/duration = 300
	var/canceled = FALSE
	var/was_queried = FALSE

/datum/voice_announce/New(client/client)
	. = ..()
	src.client = client
	id = "[client.ckey]_[GenerateToken()]"

/datum/voice_announce/Destroy()
	GLOB.voice_announce_list -= id
	. = ..()

/datum/voice_announce/proc/open()
	if(SScommunications.last_voice_announce_open + 30 > world.time)
		// Keep cheeky fucks from trying to waste resources by spamming the button
		return
	var/url_base = CONFIG_GET(string/voice_announce_url_base)
	var/dir = CONFIG_GET(string/voice_announce_dir)
	if(!url_base || !dir)
		return

	if(is_banned_from(client.ckey, "Voice Announcements"))
		to_chat(client, "<span class='warning>You are banned from making voice announcements.</span>")
		return

	SScommunications.last_voice_announce_open = world.time

	GLOB.voice_announce_list[id] = src
	usr << link(url_base + "[CONFIG_GET(string/serversqlname)]/[id]")
	addtimer(CALLBACK(src, .proc/timeout1), 15 SECONDS)
	addtimer(CALLBACK(src, .proc/timeout2), 5 MINUTES)

/datum/voice_announce/proc/timeout1()
	if(!was_queried && !started_playing)
		qdel(src)

/datum/voice_announce/proc/timeout2()
	if(!started_playing)
		qdel(src)

/datum/voice_announce/Topic(href, href_list)
	. = ..()
	if(href_list["stop_announce"] && started_playing && !canceled && check_rights(NONE))
		SEND_SOUND(world, sound(null, channel = CHANNEL_VOICE_ANNOUNCE))
		canceled = TRUE
		log_admin("[key_name(usr)] has canceled the voice announcement")
		message_admins("[key_name_admin(usr)] has canceled the voice announcement")


/datum/voice_announce/proc/do_announce_sound(sound/sound1, sound/sound2, sounds_delay, z_level)
	started_playing = TRUE
	// Play for admins
	for(var/mob/M in GLOB.player_list)
		if(M.client && M.client.holder && M.can_hear() && (M.client.prefs.toggles & SOUND_ANNOUNCEMENTS) && (M.client.prefs.toggles & SOUND_VOX))
			var/turf/T = get_turf(M)
			if(T.z == z_level)
				SEND_SOUND(M, sound1)
	sleep(sounds_delay)
	for(var/mob/M in GLOB.player_list)
		if(M.client && M.client.holder && M.can_hear() && (M.client.prefs.toggles & SOUND_ANNOUNCEMENTS) && (M.client.prefs.toggles & SOUND_VOX))
			var/turf/T = get_turf(M)
			if(T.z == z_level)
				SEND_SOUND(M, sound2)
	sleep(3 SECONDS)
	if(canceled)
		return
	// Play for everyone else
	for(var/mob/M in GLOB.player_list)
		if(M.client && !M.client.holder && M.can_hear() && (M.client.prefs.toggles & SOUND_ANNOUNCEMENTS) && (M.client.prefs.toggles & SOUND_VOX))
			var/turf/T = get_turf(M)
			if(T.z == z_level)
				SEND_SOUND(M, sound1)
	sleep(sounds_delay)
	if(canceled)
		return
	for(var/mob/M in GLOB.player_list)
		if(M.client && !M.client.holder && M.can_hear() && (M.client.prefs.toggles & SOUND_ANNOUNCEMENTS) && (M.client.prefs.toggles & SOUND_VOX))
			var/turf/T = get_turf(M)
			if(T.z == z_level)
				SEND_SOUND(M, sound2)
	sleep(duration)
	qdel(src)

/datum/voice_announce/proc/check_valid()
	if(client == null)
		return FALSE
	if(is_banned_from(client.ckey, "Voice Announcements"))
		to_chat(client, "<span class='warning>You are banned from making voice announcements.</span>")
		return FALSE
	return TRUE

/datum/voice_announce/proc/announce(snd)
	stack_trace("announce() is unimplemented")

/datum/voice_announce/proc/handle_announce(ogg_filename, base_filename, ip, duration)
	src.duration = duration
	GLOB.voice_announce_list -= id
	var/ogg_file = file("[CONFIG_GET(string/voice_announce_dir)]/[ogg_filename]")
	var/base_file = file("[CONFIG_GET(string/voice_announce_dir)]/[base_filename]")
	if(check_valid())
		var/snd = fcopy_rsc(ogg_file)
		fdel(ogg_file)
		fcopy(base_file, "[GLOB.log_directory]/[base_filename]")
		fdel(base_file)

		log_admin("[key_name(client)] has made a voice announcement via [ip], saved to [base_filename]")
		message_admins("[key_name_admin(client)] has made a voice announcement. ((<a href='?src=[REF(src)]&stop_announce=1'>CANCEL</a>))")

		announce(snd)
	else
		fdel(ogg_file)
		fdel(base_file)

/datum/voice_announce/ai
	is_ai = TRUE

/datum/voice_announce/ai/check_valid()
	if(!..())
		return FALSE
	var/mob/living/silicon/ai/M = client.mob
	if(!istype(M))
		return FALSE
	if(GLOB.announcing_vox > world.time || M.control_disabled || M.incapacitated())
		return FALSE
	return TRUE

/datum/voice_announce/ai/announce(snd)
	set waitfor = 0
	
	GLOB.announcing_vox = world.time + 600

	var/turf/mob_turf = get_turf(client.mob)
	var/z_level = mob_turf.z
	
	var/sound/sound1 = sound('sound/vox/doop.ogg')
	var/sound/sound2 = sound(snd, channel = CHANNEL_VOICE_ANNOUNCE, volume = 70)
	do_announce_sound(sound1, sound2, 5, z_level)

/datum/voice_announce/command
	var/obj/machinery/computer/communications/comms_console

/datum/voice_announce/command/New(client/client, obj/machinery/computer/communications/console)
	. = ..()
	comms_console = console

/datum/voice_announce/command/check_valid()
	if(!..())
		return FALSE
	var/mob/living/user = client.mob
	if(!SScommunications.can_announce(user, issilicon(user)))
		return FALSE
	if(!istype(user) || !user.canUseTopic(comms_console, !issilicon(user)))
		return FALSE
	return TRUE

/datum/voice_announce/command/announce(snd)
	set waitfor = 0
	var/turf/console_turf = get_turf(comms_console)
	var/z_level = console_turf.z
	SScommunications.nonsilicon_message_cooldown = world.time + 300
	var/mob/living/user = client.mob
	deadchat_broadcast(" made a priority announcement from [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user)
	var/sound/sound1 = sound('sound/misc/announce.ogg')
	var/sound/sound2 = sound(snd, channel = CHANNEL_VOICE_ANNOUNCE, volume = 70)
	do_announce_sound(sound1, sound2, 15, z_level)
