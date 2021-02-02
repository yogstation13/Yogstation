/datum/game_mode
	var/list/target_list = list()
	var/list/late_joining_list = list()

/datum/game_mode/traitor/internal_affairs
	name = "Internal Affairs"
	config_tag = "internal_affairs"
	report_type = "internal_affairs"
	false_report_weight = 10
	required_players = 25
	required_enemies = 5
	recommended_enemies = 8
	reroll_friendly = 0
	traitor_name = "Nanotrasen Internal Affairs Agent"
	antag_flag = ROLE_INTERNAL_AFFAIRS
	title_icon = "traitor"

	traitors_possible = 10 //hard limit on traitors if scaling is turned off
	num_modifier = 4 // Four additional traitors
	antag_datum = /datum/antagonist/traitor/internal_affairs

	announce_text = "There are Nanotrasen Internal Affairs Agents trying to kill each other!\n\
	<span class='danger'>IAA</span>: Eliminate your targets and protect yourself!\n\
	<span class='notice'>Crew</span>: Stop the IAA agents before they can cause too much mayhem."



/datum/game_mode/traitor/internal_affairs/post_setup()
	var/i = 0
	for(var/datum/mind/traitor in pre_traitors)
		i++
		if(i + 1 > pre_traitors.len)
			i = 0
		target_list[traitor] = pre_traitors[i+1]
	..()


/datum/game_mode/traitor/internal_affairs/add_latejoin_traitor(datum/mind/character)

	check_potential_agents()

	// As soon as we get 3 or 4 extra latejoin traitors, make them traitors and kill each other.
	if(late_joining_list.len >= rand(3, 4))
		// True randomness
		shuffle_inplace(late_joining_list)
		// Reset the target_list, it'll be used again in force_traitor_objectives
		target_list = list()

		// Basically setting the target_list for who is killing who
		var/i = 0
		for(var/datum/mind/traitor in late_joining_list)
			i++
			if(i + 1 > late_joining_list.len)
				i = 0
			target_list[traitor] = late_joining_list[i + 1]
			traitor.special_role = traitor_name

		// Now, give them their targets
		for(var/datum/mind/traitor in target_list)
			..(traitor)

		late_joining_list = list()
	else
		late_joining_list += character
	return

/datum/game_mode/traitor/internal_affairs/proc/check_potential_agents()

	for(var/M in late_joining_list)
		if(istype(M, /datum/mind))
			var/datum/mind/agent_mind = M
			if(ishuman(agent_mind.current))
				var/mob/living/carbon/human/H = agent_mind.current
				if(H.stat != DEAD)
					if(H.client)
						continue // It all checks out.

		// If any check fails, remove them from our list
		late_joining_list -= M


/datum/game_mode/traitor/internal_affairs/generate_report()
	return "Nanotrasen denies any accusations of placing internal affairs agents onboard your station to eliminate inconvenient employees.  Any further accusations against CentCom for such \
			actions will be met with a conversation with an official internal affairs agent."

/datum/game_mode/traitor/double_agents/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Internal Affairs Agents:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/traitor in traitors)
		round_credits += "<center><h2>[traitor.name] as an Internal Affairs Agent</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The Internal Affairs Agents have concealed their actions!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits

//yogs start
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
				if(!tatortottle.current || tatortottle.current.stat == DEAD || iscyborg(tatortottle.current))
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
					hijack_objective.owner = owner
					add_objective(hijack_objective)

			if(uplink_holder && owner.current && ishuman(owner.current))
				var/datum/component/uplink/uplink = uplink_holder.GetComponent(/datum/component/uplink)
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
			hijack_objective.owner = owner
			add_objective(hijack_objective)

	owner.announce_objectives()
