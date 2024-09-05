/datum/controller/subsystem/ticker
	var/selected_lobby_music

/datum/controller/subsystem/ticker/proc/choose_lobby_music()
	//Add/remove songs from this list individually, rather than multiple at once. This makes it easier to judge PRs that change the list, since PRs that change it up heavily are less likely to meet broad support
	//Add a comment after the song link in the format [Artist - Name]
	var/list/songs = list(
		'sound/ambience/vaguevoices.ogg',						// Half-Life 2 Hazardous Environments
		'sound/ambience/resurrectedteleport.ogg', 						// Half-Life 2 Black Mesa Inbound
		'sound/ambience/calabiyaumodel.ogg'						// Half-Life 2 Tau-9
		)
	selected_lobby_music = pick(songs)

/*
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(world, span_boldwarning("Youtube-dl was not configured."))
		log_world("Could not play lobby song because youtube-dl is not configured properly, check the config.")
		return


	var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[selected_lobby_music]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	if(!errorlevel)
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(src, span_boldwarning("Youtube-dl JSON parsing FAILED:"), confidential=TRUE)
			to_chat(src, span_warning("[e]: [stdout]"), confidential=TRUE)
			return
		if(data["title"])
			login_music_data["title"] = data["title"]
			login_music_data["url"] = data["url"]

	if(errorlevel)
		to_chat(world, span_boldwarning("Youtube-dl failed."))
		log_world("Could not play lobby song [selected_lobby_music]: [stderr]")
		return
	return stdout
*/
