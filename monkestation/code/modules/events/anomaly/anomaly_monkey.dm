/datum/round_event_control/anomaly/anomaly_monkey
	name = "Anomaly: Monkey"
	description = "OOGA"
	typepath = /datum/round_event/anomaly/anomaly_monkey

	max_occurrences = 1
	weight = 10
	track = EVENT_TRACK_MAJOR

/datum/round_event/anomaly/anomaly_monkey
	start_when = 1
	anomaly_path = /obj/effect/anomaly/monkey

/datum/round_event/anomaly/anomaly_monkey/announce(fake)
	priority_announce("Random Chimp Event detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
