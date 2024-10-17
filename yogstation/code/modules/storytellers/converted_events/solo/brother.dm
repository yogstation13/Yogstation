/datum/round_event_control/antagonist/solo/brother
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	typepath = /datum/round_event/antagonist/solo/brother
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG, TAG_CREW_ANTAG)
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_DETECTIVE,
		JOB_WARDEN,
		JOB_SECURITY_OFFICER,
	)
	min_players = 10 //need at least some players since it IS blood brothers
	weight = 10
	required_enemies = 2
	maximum_antags = 2
	cost = 0.45 // so it doesn't eat up threat for a relatively low-threat antag

/datum/round_event_control/antagonist/solo/brother/roundstart
	name = "Blood Brothers"
	earliest_start = 0 SECONDS
	roundstart = TRUE

/datum/round_event_control/antagonist/solo/brother/midround
	name = "Sleeper Agents (Blood Brothers)"
	min_players = 15 //need more people because this after something else has already spawned


/datum/round_event/antagonist/solo/brother
	/// all bloodbrothers picked by this event are going on this team
	var/datum/team/brother_team/bloods

/datum/round_event/antagonist/solo/brother/setup()
	. = ..()
	bloods = new

/datum/round_event/antagonist/solo/brother/add_datum_to_mind(datum/mind/antag_mind)
	bloods.add_member(antag_mind)
	bloods.forge_brother_objectives()
	antag_mind.add_antag_datum(/datum/antagonist/brother, bloods)
