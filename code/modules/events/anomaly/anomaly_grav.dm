/datum/round_event_control/anomaly/anomaly_grav
	name = "Anomaly: Gravitational"
	typepath = /datum/round_event/anomaly/anomaly_grav

	max_occurrences = 5
	weight = 25
	description = "This anomaly throws things around."
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 3

/datum/round_event/anomaly/anomaly_grav
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	anomaly_path = /obj/effect/anomaly/grav

/datum/round_event/anomaly/anomaly_grav/announce(fake)
	priority_announce("Localized high-intensity gravitational anomaly detected on [ANOMALY_ANNOUNCE_DANGEROUS_TEXT] [impact_area.name]", "Anomaly Alert")
