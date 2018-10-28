/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music) //wait for SSticker init to set the login music
	UNTIL(chatOutput.loaded)

	if(prefs && (prefs.toggles & SOUND_LOBBY))
		chatOutput.sendLobbyMusic(SSticker.login_music)