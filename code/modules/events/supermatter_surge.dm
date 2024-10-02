/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	weight = 15
	max_occurrences = 4
	earliest_start = 10 MINUTES
	description = "The supermatter will increase in power and heat by a random amount, and announce it."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)
	event_group = /datum/event_group/error
	admin_setup = list(
		/datum/event_admin_setup/input_number/surge_spiciness,
	)

/datum/round_event_control/supermatter_surge/canSpawnEvent(players_amt, allow_magic = FALSE, fake_check = FALSE)
	if(GLOB.main_supermatter_engine?.has_been_powered)
		return ..()

/datum/round_event/supermatter_surge
	var/power
	announce_when = 1

/datum/round_event/supermatter_surge/setup()
	if(!power)
		power = rand(1000,100000)
	setup = TRUE

/datum/round_event/supermatter_surge/announce(fake)
	priority_announce("Class [round(power/500) + 1] supermatter surge detected. Intervention may be required.", "Anomaly Alert")

/datum/round_event/supermatter_surge/start()
	GLOB.main_supermatter_engine.surge(power)

/datum/event_admin_setup/input_number/surge_spiciness
	input_text = "Set surge power. (Higher is more severe.)"
	min_value = 1000
	max_value = 100000

/datum/event_admin_setup/input_number/surge_spiciness/prompt_admins()
	default_value = rand(1000, 100000)
	return ..()

/datum/event_admin_setup/input_number/surge_spiciness/apply_to_event(datum/round_event/supermatter_surge/event)
	event.power = chosen_value
