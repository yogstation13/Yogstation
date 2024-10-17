/datum/round_event_control/electrical_storm
	name = "Electrical Storm"
	typepath = /datum/round_event/electrical_storm
	earliest_start = 10 MINUTES
	min_players = 5
	weight = 15
	alert_observers = FALSE
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_SPOOKY, TAG_COMMUNAL)
	event_group = /datum/event_group/error

/datum/round_event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25
	announce_when	= 1

/datum/round_event/electrical_storm/announce(fake)
	priority_announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")


/datum/round_event/electrical_storm/start()
	var/list/epicentreList = list()

	for(var/i=1, i <= lightsoutAmount, i++)
		var/turf/T = find_safe_turf()
		if(istype(T))
			epicentreList += T

	if(!epicentreList.len)
		return

	for(var/centre in epicentreList)
		for(var/a in GLOB.apcs_list)
			var/obj/machinery/power/apc/A = a
			if(get_dist(centre, A) <= lightsoutRange)
				A.overload_lighting()
