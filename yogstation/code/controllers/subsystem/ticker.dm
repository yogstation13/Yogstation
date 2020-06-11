/datum/controller/subsystem/ticker
	var/selected_lobby_music

/datum/controller/subsystem/ticker/proc/choose_lobby_music()
	//Add/remove songs from this list individually, rather than multiple at once. This makes it easier to judge PRs that change the list, since PRs that change it up heavily are less likely to meet broad support
	//Add a comment after the song link in the format [Artist - Name]
	var/list/songs = list("https://www.youtube.com/watch?v=s7dTBoW5H9k", 	// Electric Light Orchestra - Mr. Blue Sky
		"https://www.youtube.com/watch?v=WEhS9Y9HYjU", 						// Noel Harrison - The Windmills of Your Mind
		"https://www.youtube.com/watch?v=UPHmazxB38g", 						// MashedByMachines - Sector11
		"https://soundcloud.com/jeffimam/title-plasma-attack", 				// Jeff Imam - Title - Plasma Attack
		"https://www.youtube.com/watch?v=KaOC9danxNo", 						// David Bowie - Space Oddity (Cover by Chris Hadfield)
		"https://www.youtube.com/watch?v=f2cGxy-ZHIs", 						// Ólafur Arnalds - So Close (feat. Arnór Dan)
		"https://www.youtube.com/watch?v=UaD4AiqYDyA", 						// X-CEED - Flip-Flap
		"https://www.youtube.com/watch?v=a90kqxX3jPg",						// Monster860 - Orion Trail
		"https://www.youtube.com/watch?v=icy4-CQHVh4", 						// Joseph "Zhaytee" Toscano - Absconditus
		"https://www.youtube.com/watch?v=dCPWE4WexM8", 						// Hiroaki Yoshida, Hitomi Komatsu - Robocop Theme (Remix by Cboyardee)
		"https://www.youtube.com/watch?v=3W7mwRpUbqQ", 						// Stellardrone - Comet Haley
		"https://www.youtube.com/watch?v=YKVmXn-Gv0M", 						// Jeroen Tel - Tintin on the Moon (Remix by Cuboos)
		"https://www.youtube.com/watch?v=GISnTECX8Eg",						// Chris Remo - Space Asshole
		"https://www.youtube.com/watch?v=le1eD6I7k4s",						// Ronald Jenkee - Piano Wire
		"https://www.youtube.com/watch?v=qx8hrhBZJ98",						// Tonio Delafuente - Epic of Manas
		"https://www.youtube.com/watch?v=r-eMVfiT8_c",						// Kelly Bailey - Nuclear Missile Jam/Something Secret Steers Us (Remix)
		"https://www.youtube.com/watch?v=WcWix770cvQ",						// Wintergatan - Local Cluster
		"https://www.youtube.com/watch?v=w5hBQDepXOE",						// Michael Giacchino - Main Theme (STAR TREK Beyond)
		"https://www.youtube.com/watch?v=orT5RN3Zwak",						// Kirk Franklin - Revolution
		"https://www.youtube.com/watch?v=d2xkpz-26jM",						// Admiral Hippie - Clown.wmv
	    "https://www.youtube.com/watch?v=UlHGGKgzgzI",                      // Elbow - Leaders of the Free World
	    "https://www.youtube.com/watch?v=ysPtBjY8o_A",						// Chris Christodoulou - Risk of Rain Coalescence
	    "https://www.youtube.com/watch?v=SQOdPQQf2Uo",						// Star Trek The Motion Picture: Main Theme Album Style Edit
		"https://www.youtube.com/watch?v=NQPUMvP2fyM",						// Chris Remo - The Wizard
		"https://www.youtube.com/watch?v=nRjLv1L0WF8",						// Blue Oyster Cult - Sole Survivor
		"https://www.youtube.com/watch?v=51Uw-9lNl08",						// fIREHOSE - Brave Captain
		"https://www.youtube.com/watch?v=RnQofA9CNww")						// minomus of DOMU - Winds of Fjords

	selected_lobby_music = pick(songs)

	if(SSevents.holidays) // What's this? Events are initialized before tickers? Let's do something with that!
		for(var/holidayname in SSevents.holidays)
			var/datum/holiday/holiday = SSevents.holidays[holidayname]
			if(LAZYLEN(holiday.lobby_music))
				selected_lobby_music = pick(holiday.lobby_music)
				break

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(world, "<span class='boldwarning'>Youtube-dl was not configured.</span>")
		log_world("Could not play lobby song because youtube-dl is not configured properly, check the config.")
		return

	var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" -g --no-playlist -- \"[selected_lobby_music]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	if(errorlevel)
		to_chat(world, "<span class='boldwarning'>Youtube-dl failed.</span>")
		log_world("Could not play lobby song [selected_lobby_music]: [stderr]")
		return

	return stdout
