/datum/chatOutput/proc/sendLobbyMusic(music)
	if(!music)
		return
	var/list/music_data = list("lobbyMusic" = url_encode(url_encode(music)))
	ehjax_send(data = music_data)

/datum/chatOutput/proc/stopLobbyMusic()
	ehjax_send(data = "stopLobbyMusic")