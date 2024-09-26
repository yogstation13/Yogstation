//Used to manage sending droning sounds to various clients
//currently is just for combat music


SUBSYSTEM_DEF(droning)
	name = "Droning"
	flags = SS_NO_INIT|SS_NO_FIRE|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME


/datum/controller/subsystem/droning/proc/play_combat_music(music = null, client/dreamer)
	if(!music || !dreamer)
		return

	var/sound/combat_music = sound(pick(music), repeat = TRUE, wait = 0, channel = CHANNEL_AMBIENT_EFFECTS, volume = 25)
	var/sound/sound_killer = sound()
	sound_killer.channel = CHANNEL_AMBIENT_EFFECTS
	SEND_SOUND(dreamer, sound_killer) //first clears the sound channel from ambient music
	SEND_SOUND(dreamer, combat_music) //then starts playing music
	dreamer.droning_sound = combat_music
	dreamer.last_droning_sound = combat_music.file

/datum/controller/subsystem/droning/proc/kill_droning(client/victim)
	if(!victim?.droning_sound)
		return
	var/sound/sound_killer = sound()
	sound_killer.channel = CHANNEL_AMBIENT_EFFECTS
	SEND_SOUND(victim, sound_killer)
	victim.droning_sound = null
	victim.last_droning_sound = null
