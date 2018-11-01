/datum/antagonist/traitor/internal_affairs/iaa_process()
	if(owner && owner.current && !iscyborg(owner.current) && owner.current.stat!=DEAD)
		var/new_objective = TRUE
		for(var/objective_ in objectives)
			if(istype(objective_, /datum/objective/hijack) || istype(objective_, /datum/objective/martyr) || istype(objective_, /datum/objective/block))
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
			for(var/objective_ in objectives)
				if(!is_internal_objective(objective_))
					continue
				var/datum/objective/assassinate/internal/objective = objective_
				if(objective.target)
					other_traitors -= objective.target
			for(var/tator in other_traitors)
				var/datum/mind/tatortottle = tator
				if(!tatortottle.current || tatortottle.current.stat == DEAD)
					other_traitors -= tatortottle

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
				for(var/objective_ in objectives)
					remove_objective(objective_)

				if(issilicon(owner))
					var/datum/objective/block/block_objective = new
					block_objective.owner = owner
					add_objective(block_objective) //AIs are guaranteed hijack since glorious death doesn't really make sense for them, and they don't have a murderbone rule regardless.

				else if(prob(50)) //50/50 split between glorious death and hijack, so IAA can't just go "hurr, I can kill everyone since I'll get hijack later"
					var/datum/objective/martyr/martyr_objective = new
					martyr_objective.owner = owner
					add_objective(martyr_objective)
				else
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = owner.
					add_objective(hijack_objective)

			if(uplink_holder && owner.current && ishuman(owner.current))
				GET_COMPONENT_FROM(uplink, /datum/component/uplink, uplink_holder)
				uplink.telecrystals += 5
				to_chat(owner, "<span class='notice'>You have been given 5 TC as a reward for completing your objective!</span>")

			owner.announce_objectives()

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
		if(issilicon(owner))
			var/datum/objective/block/block_objective = new
			block_objective.owner = owner
			add_objective(block_objective) //AIs are guaranteed hijack since glorious death doesn't really make sense for them, and they don't have a murderbone rule regardless.

		else if(prob(50)) //50/50 split between glorious death and hijack, so IAA can't just go "hurr, I can kill everyone since I'll get hijack later"
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			add_objective(martyr_objective)
		else
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner.
			add_objective(hijack_objective)

	owner.announce_objectives()