/datum/round_event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/round_event/spider_infestation
	weight = 5
	max_occurrences = 1
	min_players = 25
	description = "Spawns spider eggs, ready to hatch."
	min_wizard_trigger_potency = 5
	max_wizard_trigger_potency = 7
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event/spider_infestation
	announce_when	= 400

	var/spawncount = 1


/datum/round_event/spider_infestation/setup()
	announce_when = rand(announce_when, announce_when + 50)
	spawncount = rand(5, 8)
	setup = TRUE //storytellers

/datum/round_event/spider_infestation/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)


/datum/round_event/spider_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent

	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		var/spawn_type = /obj/structure/spider/spiderling
		if(prob(66))
			spawn_type = /obj/structure/spider/spiderling/nurse
		announce_to_ghosts(spawn_atom_to_turf(spawn_type, vent, 1, FALSE))
		vents -= vent
		spawncount--
