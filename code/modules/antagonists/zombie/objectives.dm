/datum/objective/zombie
	name = "zombie_objective"

/datum/objective/zombie/New()
	update_explanation_text()
	. = ..()

/datum/objective/zombie/infect
	name = "infect"
	var/player_count
	var/people_to_infect

/datum/objective/zombie/infect/New()
	player_count = SSticker.mode.current_players[CURRENT_LIVING_PLAYERS].len
	people_to_infect = round(rand(player_count / 3, player_count / 2), 1)
	. = ..()

/datum/objective/zombie/infect/check_completion()
	if(LAZYLEN(GLOB.zombies) > people_to_infect)
		return TRUE
	return FALSE

/datum/objective/zombie/infect/update_explanation_text()
	..()
	var/player_count = SSticker.mode.current_players[CURRENT_LIVING_PLAYERS].len
	var/people_to_infect = round(rand(player_count / 3, player_count / 2), 1) // example: 36 players -> 12 and 18 -> about 15 people || 48 players -> 16 and 24 -> about 20 people
	explanation_text = "Infect atleast [people_to_infect] people in total. This account for other zombies infects"

