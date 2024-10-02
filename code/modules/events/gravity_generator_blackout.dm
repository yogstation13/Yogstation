/datum/round_event_control/gravity_generator_blackout
	name = "Gravity Generator Blackout"
	typepath = /datum/round_event/gravity_generator_blackout
	weight = 30
	description = "Turns off the gravity generator."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPACE)
	event_group = /datum/event_group/bsod

/datum/round_event_control/gravity_generator_blackout/canSpawnEvent(players_amt, allow_magic = FALSE, fake_check = FALSE) //MONKESTATION ADDITION: fake_check = FALSE
	. = ..()
	if(!.)
		return .

	var/station_generator_exists = FALSE
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.machines)
		if(is_station_level(the_generator.z))
			station_generator_exists = TRUE

	if(!station_generator_exists)
		return FALSE

/datum/round_event/gravity_generator_blackout
	announce_when = 1
	start_when = 1
	announce_chance = 33

/datum/round_event/gravity_generator_blackout/announce(fake)
	priority_announce("Warning: Failsafes for the station's artificial gravity arrays have been triggered. Please be aware that if this problem recurs it may result in formation of gravitational anomalies. Nanotrasen wishes to remind you that the unauthorised formation of anomalies within Nanotrasen facilities is strictly prohibited by health and safety regulation [rand(99,9999)][pick("a","b","c")]:subclause[rand(1,20)][pick("a","b","c")].")

/datum/round_event/gravity_generator_blackout/start()
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.machines)
		if(is_station_level(the_generator.z))
			the_generator.blackout()
