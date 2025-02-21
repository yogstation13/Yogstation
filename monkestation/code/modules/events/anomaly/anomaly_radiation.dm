/datum/round_event_control/anomaly/anomaly_radiation
	name = "Anomaly: Radiation"
	description = "A sickly green glow from byond the horizon."
	typepath = /datum/round_event/anomaly/anomaly_radiation

	max_occurrences = 1
	weight = 1
	min_players = 20
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_MAGICAL)

/datum/round_event/anomaly/anomaly_radiation
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	anomaly_path = /obj/effect/anomaly/radioactive

/datum/round_event/anomaly/anomaly_radiation/announce(fake)
	priority_announce("Radioactive anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
