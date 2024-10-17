/datum/round_event_control/prob_anomaly
	name = "Probabilistic Anomaly"
	typepath = /datum/round_event/prob_anomaly
	weight = 10
	description = "Sets rng seed for a duration."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 3
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_MAGICAL)

/datum/round_event/prob_anomaly
	announce_when = 1
	end_when = 30
	var/seed = 0

/datum/round_event/prob_anomaly/announce(fake)
	var/alert = pick("A probabilistic anomaly has been detected near the station. Prepare for a distortion of the laws of probability.",
		"An improbability drive is powering up within this sector. Prepare for a distortion of the laws of probability.")
	priority_announce(alert)

/datum/round_event/prob_anomaly/start()
	end_when = rand(120,600) // About 2 to 10 minutes, more or less
	seed = rand(1,1e9)
	rand_seed(seed)
	
/datum/round_event/prob_anomaly/tick()
	rand_seed(seed) // Keeps forcing the same random numbers to be generated, repeatedly
	
/datum/round_event/prob_anomaly/end()
	rand_seed(rand(1,1e9))
