/datum/antagonist/traitor/malf/forge_ai_objectives()

	var/list/datum/objective/possible_murderbone_objectives = list(
		/datum/objective/block = 100, //No organics on the shuttle.
		/datum/objective/purge = 50 //No mutants on the shuttle.
	)
	var/datum/objective/murderbone_objective = pickweight(possible_murderbone_objectives) //Kill kill kill.


	var/datum/objective/protect/protect_objective = new //Protect someone from dying. Prevents indiscriminate plasma floods.
	protect_objective.owner = owner
	protect_objective.find_target()
	add_objective(protect_objective)

	if(GLOB.joined_player_list.len >= 40)
		var/datum/objective/robot_army/army_objective = new //Have 8 or more connected cyborgs.
		army_objective.owner = owner
		add_objective(army_objective)
	else if(!protect_objective.target || !prob(80)) //Gameplay optimization.
		var/list/possible_pets = list()
		for(var/mob/living/simple_animal/M in GLOB.alive_mob_list)
			//This is a hacky way of getting unique pets.
			if(M.gold_core_spawnable != NO_SPAWN) //Not unique.
				continue
			if(!M.healable || M.del_on_death) //Annoying to protect.
				continue
			if(M.status_flags & GODMODE) //lol
				continue
			if(!M.z || !is_station_level(M.z))
				continue
			possible_pets += M
		if(length(possible_pets)) //I don't see this failing, but whatever.
			var/datum/objective/protect_mindless_living/pettect_objective = new //Protect a pet from dying.
			pettect_objective.owner = owner
			pettect_objective.protect_target = pick(possible_pets)
			pettect_objective.update_explanation_text()
			add_objective(pettect_objective)


	murderbone_objective = new murderbone_objective
	murderbone_objective.owner = owner
	add_objective(murderbone_objective)

	var/datum/objective/survive/exist/exist_objective = new //Live live live.
	exist_objective.owner = owner
	add_objective(exist_objective)