//THIS IS THE METEOR EVENT, IT NEEDS TO BE A METEOR, DO NOT SPAWN THIS ON PLANETARY MAPS(the spawn works fine on planets, the actual issue is the ling passes out due to CO2)
// /datum/round_event_control/changeling
// 	track = EVENT_TRACK_MAJOR
// 	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN)
// 	checks_antag_cap = TRUE

// /datum/round_event_control/gravity_generator_blackout
// 	track = EVENT_TRACK_MODERATE
// 	tags = list(TAG_COMMUNAL, TAG_SPACE)
// 	event_group = /datum/event_group/bsod

// /datum/round_event_control/radiation_leak
// 	track = EVENT_TRACK_MODERATE
// 	tags = list(TAG_COMMUNAL)

// /datum/round_event_control/scrubber_clog
// 	track = EVENT_TRACK_MUNDANE
// 	tags = list(TAG_COMMUNAL, TAG_ALIEN, TAG_MAGICAL)
// 	event_group = /datum/event_group/guests

// /datum/round_event_control/scrubber_clog/critical
// 	track = EVENT_TRACK_MAJOR
// 	tags = list(TAG_COMMUNAL, TAG_COMBAT, TAG_EXTERNAL, TAG_ALIEN, TAG_MAGICAL)

/datum/round_event_control/slaughter
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event_control/space_dust
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_DESTRUCTIVE, TAG_SPACE, TAG_EXTERNAL)

/datum/round_event_control/space_dragon
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event_control/spacevine
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_ALIEN)
	checks_antag_cap = TRUE
	event_group = /datum/event_group/guests

/datum/round_event_control/spider_infestation
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/stray_cargo
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

// /datum/round_event_control/stray_meteor
// 	track = EVENT_TRACK_MODERATE
// 	tags = list(TAG_DESTRUCTIVE, TAG_SPACE, TAG_EXTERNAL)
// 	event_group = /datum/event_group/debris

/datum/round_event_control/supermatter_surge
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)
	event_group = /datum/event_group/error

// /datum/round_event_control/tram_malfunction TRAMSTATION LETS FUCKING GOOOOO
// 	track = EVENT_TRACK_MUNDANE
// 	tags = list(TAG_COMMUNAL)
// 	event_group = /datum/event_group/error

// /datum/round_event_control/wisdomcow
// 	track = EVENT_TRACK_MUNDANE
// 	tags = list(TAG_COMMUNAL, TAG_POSITIVE, TAG_MAGICAL)
// 	event_group = /datum/event_group/guests

/datum/round_event_control/wormholes
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_MAGICAL)
	event_group = /datum/event_group/anomalies
