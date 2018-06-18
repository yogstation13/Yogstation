/datum/game_mode/traitor/internal_affairs/make_antag_chance()
	return FALSE

/datum/antagonist/traitor/internal_affairs/iaa_process()
	return

/datum/game_mode/traitor/internal_affairs/check_finished(force_ending) //to be called by SSticker
	.=..()
	if(force_ending || !SSticker.setup_done || !gamemode_ready || .) //if the gamemode is already considered finished, if it's not begun or if it's being force ended
		return .

	var/new_target
	for(var/datum/mind/traitor in traitors)
		if(!traitor.current || traitor.current.stat==DEAD)
			continue
		new_target = TRUE
		for(var/datum/objective/O in traitor)
			if(O.check_completion() || istype(O, /datum/objective/escape) || istype(O, /datum/objective/survive))
				continue
			new_target = FALSE

		if(new_target)
			var/list/other_traitors = traitors

			for(var/datum/mind/other_traitor in other_traitors)
				if(other_traitor == traitor || !other_traitor.current || other_traitor.current.stat==DEAD)
					other_traitors -= other_traitor

			if(other_traitors.len)
				var/datum/mind/newTarget = pick(other_traitors)
				if(issilicon(newTarget.current))
					var/datum/objective/destroy/internal/destroy_objective = new
					destroy_objective.owner = traitor
					destroy_objective.target = newTarget
					destroy_objective.update_explanation_text()
					traitor.objectives += destroy_objective

				else
					var/datum/objective/assassinate/internal/kill_objective = new
					kill_objective.owner = traitor
					kill_objective.target = newTarget
					kill_objective.update_explanation_text()
					traitor.objectives += kill_objective

				traitor.announce_objectives()

	return .