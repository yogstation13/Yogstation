/datum/round_event_control/anomaly/anomaly_frost
	name = "Anomaly: Frost"
	description = "The white frost comes."
	typepath = /datum/round_event/anomaly/anomaly_frost

	max_occurrences = 5
	weight = 10
	min_players = 20

	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_SPOOKY)

/datum/round_event/anomaly/anomaly_frost
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	anomaly_path = /obj/effect/anomaly/frost

/datum/round_event/anomaly/anomaly_frost/announce(fake)
	priority_announce("Frost Anomaly detected in: [impact_area.name]. Brace for the cold.", "Anomaly Alert", 'monkestation/sound/misc/frost_horn.ogg')
