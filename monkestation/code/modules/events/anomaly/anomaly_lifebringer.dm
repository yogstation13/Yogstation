/datum/round_event_control/anomaly/anomaly_lifebringer
	name = "Anomaly: lifebringer"
	description = "Meow"
	typepath = /datum/round_event/anomaly/anomaly_lifebringer

	max_occurrences = 2
	weight = 15
	track = EVENT_TRACK_MUNDANE

/datum/round_event/anomaly/anomaly_lifebringer
	start_when = 1
	anomaly_path = /obj/effect/anomaly/lifebringer

/datum/round_event/anomaly/anomaly_lifebringer/announce(fake)
	priority_announce("Lifebringer anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
