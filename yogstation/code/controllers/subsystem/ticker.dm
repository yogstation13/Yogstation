/datum/controller/subsystem/ticker
	var/selected_lobby_music

/datum/controller/subsystem/ticker/proc/choose_lobby_music()
	//Add/remove songs from this list individually, rather than multiple at once. This makes it easier to judge PRs that change the list, since PRs that change it up heavily are less likely to meet broad support
	//Add a comment after the song link in the format [Artist - Name]
	var/list/songs = list("https://www.youtube.com/watch?v=lIrum6iFz6U", 	// Electric Light Orchestra - Mr. Blue Sky
		"https://www.youtube.com/watch?v=Ae2N5310MXE",						// SolusLunes - Endless Space
		"https://www.youtube.com/watch?v=WEhS9Y9HYjU", 						// Noel Harrison - The Windmills of Your Mind
		"https://www.youtube.com/watch?v=UPHmazxB38g", 						// MashedByMachines - Sector11
		"https://soundcloud.com/jeffimam/title-plasma-attack",				// Jeff Imam - Title - Plasma Attack
		"https://www.youtube.com/watch?v=KaOC9danxNo", 						// David Bowie - Space Oddity (Cover by Chris Hadfield)
		"https://www.youtube.com/watch?v=f2cGxy-ZHIs", 						// Ólafur Arnalds - So Close (feat. Arnór Dan)
		"https://www.youtube.com/watch?v=UaD4AiqYDyA", 						// X-CEED - Flip-Flap
		"https://www.youtube.com/watch?v=a90kqxX3jPg",						// Monster860 - Orion Trail 
		"https://www.youtube.com/watch?v=dOtCvh-kIUM",						// Snooty Fox - Ritchie Everett
		"https://www.youtube.com/watch?v=zKxwED8-Hws",						// Monster860 - Journey to Cygni
		"https://www.youtube.com/watch?v=icy4-CQHVh4", 						// Joseph "Zhaytee" Toscano - Absconditus
		"https://www.youtube.com/watch?v=dCPWE4WexM8", 						// Hiroaki Yoshida, Hitomi Komatsu - Robocop Theme (Remix by Cboyardee)
		"https://www.youtube.com/watch?v=3W7mwRpUbqQ", 						// Stellardrone - Comet Haley
		"https://www.youtube.com/watch?v=BY-1SrsLER0", 						// Jeroen Tel - Tintin on the Moon  (Noisemaker's Remix)
		"https://www.youtube.com/watch?v=YKVmXn-Gv0M", 						// Jeroen Tel - Tintin on the Moon (Remix by Cuboos)
		"https://www.youtube.com/watch?v=GISnTECX8Eg",						// Chris Remo - Space Asshole
		"https://www.youtube.com/watch?v=le1eD6I7k4s",						// Ronald Jenkee - Piano Wire
		"https://www.youtube.com/watch?v=r-eMVfiT8_c",						// Kelly Bailey - Nuclear Missile Jam/Something Secret Steers Us (Remix)
		"https://www.youtube.com/watch?v=WcWix770cvQ",						// Wintergatan - Local Cluster
		"https://www.youtube.com/watch?v=w5hBQDepXOE",						// Michael Giacchino - Main Theme (STAR TREK Beyond)
		"https://www.youtube.com/watch?v=orT5RN3Zwak",						// Kirk Franklin - Revolution
		"https://www.youtube.com/watch?v=d2xkpz-26jM",						// Admiral Hippie - Clown.wmv
		"https://www.youtube.com/watch?v=UlHGGKgzgzI",						// Elbow - Leaders of the Free World
		"https://www.youtube.com/watch?v=ysPtBjY8o_A",						// Chris Christodoulou - Risk of Rain Coalescence
		"https://www.youtube.com/watch?v=SQOdPQQf2Uo",						// Star Trek The Motion Picture: Main Theme Album Style Edit
		"https://www.youtube.com/watch?v=NQPUMvP2fyM",						// Chris Remo - The Wizard
		"https://www.youtube.com/watch?v=nRjLv1L0WF8",						// Blue Oyster Cult - Sole Survivor
		"https://www.youtube.com/watch?v=51Uw-9lNl08",						// fIREHOSE - Brave Captain
		"https://www.youtube.com/watch?v=RnQofA9CNww",						// minomus of DOMU - Winds of Fjords
		"https://www.youtube.com/watch?v=xhlH91k-86E",						// J.G. Thirlwell - In a Spaceage Mood
		"https://www.youtube.com/watch?v=Ld6TfpgJg7g",						// Tom Kane - Freeway Jazz
		"https://www.youtube.com/watch?v=ZhhQrFfzFM4",						// Carpenter Brut - Escape from Midwich Valley
		"https://www.youtube.com/watch?v=dLrdSC9MVb4",						// Tally Hall - Turn the Lights Off
		"https://www.youtube.com/watch?v=YGulLVWu-s0",						// God Hand "Rock a Bay"
		"https://www.youtube.com/watch?v=IhEqUKBTffU",						// Streets Of Rogue - 5-1
		"https://www.youtube.com/watch?v=fXvxnDmwB_I",						// Rain World THS - Action Scene
		"https://www.youtube.com/watch?v=1ye2nI7L_0g",						//The Kinks - Apeman
		"https://www.youtube.com/watch?v=iZB8XXYePy0",						//The Kinks - Super Sonic Ship
		"https://www.youtube.com/watch?v=tRcPA7Fzebw",						//David Bowie - Starman
		"https://www.youtube.com/watch?v=FH2EgYq_NCY",						//Lou Reed - Satellite of Love
		"https://www.youtube.com/watch?v=AumYP6Np1eI")						// Ataraxia - Deja Vu

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

	var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[selected_lobby_music]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	if(!errorlevel)
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(src, "<span class='boldwarning'>Youtube-dl JSON parsing FAILED:</span>", confidential=TRUE)
			to_chat(src, "<span class='warning'>[e]: [stdout]</span>", confidential=TRUE)
			return
		if(data["title"])
			login_music_data["title"] = data["title"]
			login_music_data["url"] = data["url"]
	
	if(errorlevel)
		to_chat(world, "<span class='boldwarning'>Youtube-dl failed.</span>")
		log_world("Could not play lobby song [selected_lobby_music]: [stderr]")
		return
	return stdout
