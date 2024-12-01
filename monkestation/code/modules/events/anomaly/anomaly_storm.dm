/datum/round_event_control/anomaly/anomaly_storm
	name = "Anomaly: Storm"
	description = "A tesla, condensed."
	typepath = /datum/round_event/anomaly/anomaly_storm

	max_occurrences = 3
	weight = 5
	min_players = 40

	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_MAGICAL, TAG_DESTRUCTIVE)

/datum/round_event/anomaly/anomaly_storm
	start_when = 1
	anomaly_path = /obj/effect/anomaly/storm

/datum/round_event/anomaly/anomaly_storm/announce(fake)
	priority_announce("Powerful Storm anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
