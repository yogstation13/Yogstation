/datum/round_event_control/antagonist/solo/nuclear_operative/clown
	name = "Circus Assault"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_CLOWNOP
	antag_datum = /datum/antagonist/nukeop/clownop
	typepath = /datum/round_event/antagonist/solo/nuclear_operative/clown
	shared_occurence_type = SHARED_HIGH_THREAT
	title_icon = null
	weight = 1 //these are meant to be very rare

/datum/round_event/antagonist/solo/nuclear_operative/clown
	boss_type = /datum/antagonist/nukeop/leader/clownop

/datum/round_event/antagonist/solo/nuclear_operative/clown/setup()
	for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
		if(istype(S, /obj/machinery/nuclearbomb/syndicate/bananium))
			continue
		var/turf/T = get_turf(S)
		if(T)
			qdel(S)
			new /obj/machinery/nuclearbomb/syndicate/bananium(T)
	return ..()
