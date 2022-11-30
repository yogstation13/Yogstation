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

	murderbone_objective = new murderbone_objective
	murderbone_objective.owner = owner
	add_objective(murderbone_objective)

	var/datum/objective/survive/exist/exist_objective = new //Live live live.
	exist_objective.owner = owner
	add_objective(exist_objective)
