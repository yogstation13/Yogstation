/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	weight = 15
	max_occurrences = 4
	earliest_start = 10 MINUTES

/datum/round_event_control/supermatter_surge/canSpawnEvent()
	if(GLOB.main_supermatter_engine?.has_been_powered)
		return ..()

/datum/round_event/supermatter_surge
	var/power = 2000

/datum/round_event/supermatter_surge/setup()
	power = rand(1000,100000)

/datum/round_event/supermatter_surge/announce()
	priority_announce("Class [round(power/500) + 1] supermatter surge detected. Intervention may be required.", "Anomaly Alert")

/datum/round_event/supermatter_surge/start()
	GLOB.main_supermatter_engine.matter_power += power
