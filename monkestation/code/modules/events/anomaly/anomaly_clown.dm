/datum/round_event_control/anomaly/anomaly_clown
	name = "Anomaly: Clowns"
	description = "A distant Honking."
	typepath = /datum/round_event/anomaly/anomaly_clown

	max_occurrences = 5
	weight = 9
	min_players = 20
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_SPOOKY, TAG_MAGICAL)

/datum/round_event/anomaly/anomaly_clown
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	anomaly_path = /obj/effect/anomaly/clown

/datum/round_event/anomaly/anomaly_clown/announce(fake)
	priority_announce("There should be clowns. Where are the clowns? [impact_area.name]. Send in the clowns.", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
