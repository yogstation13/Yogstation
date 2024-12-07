/datum/round_event_control/antagonist/solo/nuclear_operative/clown
	name = "Roundstart Clown Operative"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_CLOWN_OPERATIVE
	antag_datum = /datum/antagonist/nukeop/clownop
	typepath = /datum/round_event/antagonist/solo/nuclear_operative/clown
	weight = 1 //these are meant to be very rare
	max_occurrences = 1
	event_icon_state = "flukeops"

/datum/round_event/antagonist/solo/nuclear_operative/clown
	required_role = ROLE_CLOWN_OPERATIVE
	job_type = /datum/job/clown_operative
	antag_type = /datum/antagonist/nukeop/clownop
	leader_antag_type = /datum/antagonist/nukeop/leader/clownop
