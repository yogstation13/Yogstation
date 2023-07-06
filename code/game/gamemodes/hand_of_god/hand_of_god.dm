/*Hand of God
its the silly little gamemode where two cults are vying to summon their respective gods ratvar or nar'sie
pulls stuff from clock_cult and eldritch_cult mostly items*/

/datum/game_mode/hand_of_god
	name = "Hand Of God"
	config_tag = "hand_of_god"
	antag_flag = ROLE_HOG_CULTIST
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Brig Physician", "Chaplain") 
	required_players = 43
	required_enemies = 1
	recommended_enemies = 2
	enemy_minimum_age = 14
	title_icon = "hand_of_god"

	announce_span = "danger"
	announce_text = "A violent war between cults has errupted on the station!\n\
	<span class='danger'>Cults</span>: Free your god into the mortal realm.\n\
	<span class='notice'>Crew</span>: Prevent the cults from summonning their god."

















