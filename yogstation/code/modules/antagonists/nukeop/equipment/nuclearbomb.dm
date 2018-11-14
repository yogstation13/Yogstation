/obj/machinery/nuclearbomb/selfdestruct
	var/nuke_ops = FALSE

/obj/machinery/nuclearbomb/selfdestruct/get_cinematic_type(off_station)
	if(nuke_ops)
		var/datum/game_mode/nuclear/NM = SSticker.mode
		switch(off_station)
			if(0)
				if(istype(NM) && !NM.nuke_team.syndies_escaped())
					return CINEMATIC_ANNIHILATION
				else
					return CINEMATIC_NUKE_WIN
			if(1)
				return CINEMATIC_NUKE_MISS
			if(2)
				return CINEMATIC_NUKE_FAR
		return CINEMATIC_NUKE_FAR
	return ..()