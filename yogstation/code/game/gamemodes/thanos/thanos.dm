/datum/game_mode
	var/list/datum/mind/thanos
	var/list/datum/mind/minions = list()

/datum/game_mode/thanos
	name = "thanos"
	config_tag = "thanos"
	report_type = "thanos"
	antag_flag = ROLE_THANOS
	required_players = 30
	required_enemies = 1
	recommended_enemies = 3
	enemy_minimum_age = 14
	round_ends_with_antag_death = 1
	announce_span = "danger"
	announce_text = "A mad titan with a powerful gauntlet is gathering the gems, and all are on Space Station 13!\n\
	<span class='danger'>Titan and minions</span>: Accomplish your objective at all costs!\n\
	<span class='notice'>Crew</span>: Eliminate the mad titan before they can succeed!"
	var/max_thanos_members = 4 //one thanos and three minions
	var/list/pre_thanos = list()

	var/datum/team/thanos/thanos_team

	var/thanos_antag_datum_type = /datum/antagonist/thanos
	var/thanos_minion_datum_type = /datum/antagonist/thanos/minion


/datum/game_mode/thanos/pre_setup()
	var/n_thanos = min(round(num_players() / 20), antag_candidates.len, agents_possible)
	if(n_thanos >= required_enemies)
		for(var/i = 0, i < n_thanos, ++i)
			var/datum/mind/new_thanos = pick_n_take(antag_candidates)
			pre_thanos += new_thanos
			new_op.assigned_role = ROLE_THANOS
			new_op.special_role = ROLE_THANOS
			//log_game("[key_name(new_op)] has been selected as a nuclear operative") | yogs - redundant
		return TRUE

/datum/game_mode/thanos/post_setup()
	//Assign leader
	var/datum/mind/thanos_mind = pre_thanos[1]
	var/datum/antagonist/thanos/T = thanos_mind.add_antag_datum(thanos_antag_datum_type)
	thanos_team = T.thanos_team
	if(pre_thanos.len>1)
		//Assign the minions
		for(var/i = 2 to pre_thanos.len)
			var/datum/mind/minion_mind = pre_thanos[i]
			minion_mind.add_antag_datum(thanos_minion_datum_type)
	return ..()

/datum/game_mode/thanos/check_win()
	if (snapped)
		return TRUE
	return ..()
