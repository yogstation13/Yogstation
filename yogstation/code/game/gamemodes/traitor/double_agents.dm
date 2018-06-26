/datum/antagonist/traitor/internal_affairs/iaa_process()
	if(owner && owner.current && owner.current.stat!=DEAD)
		var/new_objective = TRUE
		for(var/objective_ in owner.objectives)
			if(istype(objective_, /datum/objective/hijack) || istype(objective_, /datum/objective/martyr))
				new_objective = FALSE
				break
			if(!is_internal_objective(objective_))
				continue
			var/datum/objective/assassinate/internal/objective = objective_
			if(!objective.target || objective.check_completion())
				continue
			new_objective = FALSE

		if(new_objective)
			var/list/other_traitors = SSticker.mode.traitors - owner
			for(var/objective_ in owner.objectives)
				if(!is_internal_objective(objective_))
					continue
				var/datum/objective/assassinate/internal/objective = objective_
				if(objective.target && objective.target.current)
					other_traitors -= objective.target.current

			if(other_traitors.len)
				var/datum/mind/target_mind = pick(other_traitors)
				if(issilicon(target_mind.current))
					var/datum/objective/destroy/internal/destroy_objective = new
					destroy_objective.owner = owner
					destroy_objective.target = target_mind
					destroy_objective.update_explanation_text()
					add_objective(destroy_objective)
				else
					var/datum/objective/assassinate/internal/kill_objective = new
					kill_objective.owner = owner
					kill_objective.target = target_mind
					kill_objective.update_explanation_text()
					add_objective(kill_objective)
			else
				for(var/objective_ in owner.objectives)
					remove_objective(objective_)

				if(prob(50))
					var/datum/objective/martyr/martyr_objective = new
					martyr_objective.owner = owner
					add_objective(martyr_objective)
				else
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = owner.
					add_objective(hijack_objective)

/datum/game_mode/traitor/internal_affairs/add_latejoin_traitor(datum/mind/character)
	for(var/data in character.antag_datums)
		if(istype(data, /datum/antagonist/traitor/internal_affairs))
			var/datum/antagonist/traitor/internal_affairs/IAAdata = data
			IAAdata.latejoin()
			break

/datum/antagonist/traitor/internal_affairs/proc/latejoin()
	var/list/other_traitors = SSticker.mode.traitors - owner
	for(var/V in other_traitors)
		var/datum/mind/traitor = V
		if(!traitor.current || traitor.current.stat == DEAD)
			other_traitors -= traitor

	if(other_traitors.len)
		var/datum/mind/target_mind = pick(other_traitors)
		if(issilicon(target_mind.current))
			var/datum/objective/destroy/internal/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.target = target_mind
			destroy_objective.update_explanation_text()
			add_objective(destroy_objective)
		else
			var/datum/objective/assassinate/internal/kill_objective = new
			kill_objective.owner = owner
			kill_objective.target = target_mind
			kill_objective.update_explanation_text()
			add_objective(kill_objective)
	else
		if(prob(50))
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			add_objective(martyr_objective)
		else
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner.
			add_objective(hijack_objective)