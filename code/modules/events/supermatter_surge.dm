/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	weight = 15
	max_occurrences = 4
	earliest_start = 10 MINUTES
	var/forced_power

/datum/round_event_control/supermatter_surge/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/selected_power = input("How severe should it be? Between 1000 and 100000. Press cancel for random") as num|null
	if(!selected_power)
		selected_power = rand(1000, 100000)
	selected_power = clamp(selected_power, 1000, 100000)
	forced_power = selected_power

	

/datum/round_event_control/supermatter_surge/canSpawnEvent()
	if(GLOB.main_supermatter_engine?.has_been_powered)
		return ..()

/datum/round_event/supermatter_surge
	var/power = 2000
	announceWhen = 1

/datum/round_event/supermatter_surge/setup()
	var/datum/round_event_control/supermatter_surge/C = control
	if(C.forced_power)
		power = C.forced_power
	else
		power = rand(1000,100000)

/datum/round_event/supermatter_surge/announce(fake)
	priority_announce("Class [round(power/500) + 1] supermatter surge detected. Intervention may be required.", "Anomaly Alert")

/datum/round_event/supermatter_surge/start()
	GLOB.main_supermatter_engine.surge(power)
