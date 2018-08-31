/datum/game_mode
	var/list/datum/mind/spythieves = list()


/datum/game_mode/spythief
	name = "spy thief"
	config_tag = "spythief"
	antag_flag = ROLE_SPY_THIEF
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 24
	required_enemies = 3
	recommended_enemies = 6
	enemy_minimum_age = 14