/datum/round_event_control/antagonist/solo/traitor
	antag_flag = ROLE_TRAITOR
	tags = list(TAG_COMBAT)
	antag_datum = /datum/antagonist/traitor
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("AI", "Cyborg", "Synthetic")
	weight = 15

/datum/round_event_control/antagonist/solo/traitor/roundstart
	name = "Traitors"
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/traitor/midround
	name = "Sleeper Agents (Traitors)"
	prompted_picking = TRUE
