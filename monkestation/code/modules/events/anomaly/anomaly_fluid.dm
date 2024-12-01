/datum/round_event_control/anomaly/anomaly_fluid
	name = "Anomaly: Fluidic"
	description = "Noah, get the boat."
	typepath = /datum/round_event/anomaly/anomaly_fluid

	max_occurrences = 3
	weight = 20
	min_players = 30
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MUNDANE

/datum/round_event/anomaly/anomaly_fluid
	start_when = 1
	anomaly_path = /obj/effect/anomaly/fluid

/datum/round_event/anomaly/anomaly_fluid/announce(fake)
	priority_announce("Fluidic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
