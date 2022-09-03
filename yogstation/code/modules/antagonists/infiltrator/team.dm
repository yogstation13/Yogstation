#define MIN_MAJOR_OBJECTIVES 1
#define MAX_MAJOR_OBJECTIVES 2
#define MIN_MINOR_OBJECTIVES 3
#define MAX_MINOR_OBJECTIVES 4

/datum/team/infiltrator
	name = "Syndicate Infiltration Unit"
	member_name = "syndicate infiltrator"

/datum/team/infiltrator/roundend_report()
	var/list/parts = list()
	parts += span_header("Syndicate Infiltrators:<br>")

	var/result = get_result()
	var/dead_as_a_doornail = TRUE
	for(var/I in members)
		var/datum/mind/syndicate = I
		if (syndicate?.current?.stat != DEAD)
			dead_as_a_doornail = FALSE

	var/flavor_message
	if (dead_as_a_doornail)
		var/static/list/messages = list(
			"Well, sending those nitwits was a waste of our time.",
			"I'm gonna drag you incompetent idiots out of hell just so I can kill y'all myself!",
			"We gave you dumbasses all those resources and you just go and die? What sad excuses for agents."
		)
		parts += "<span class='redtext big'>Crew Major Victory!</span>"
		parts += "<B>The crew killed the Syndicate infiltrators!</B>"
		flavor_message = pick(messages)
	else
		switch (result)
			if (INFILTRATION_ALLCOMPLETE)
				var/static/list/messages = list(
					"Hell yeah! Nanotrasen is gonna regret screwing with us now, thanks to y'all!",
					"The boys in dark red are proud of you, agents. We're going to reward you well.",
					"I'm truly impressed, agents. You've earned your place in the Syndicate.",
					"Ha! I knew y'all would come out on top! Nanotrasen stands no chance against human determination!"
				)
				parts += span_greentext(span_big("Infiltrator Major Victory!"))
				parts += span_bold("The Syndicate infiltrators completed all of their objectives successfully!")
				flavor_message = pick(messages)
			if (INFILTRATION_MOSTCOMPLETE)
				var/static/list/messages = list(
					"Well, it ain't perfect, but y'all were damn good.",
					"Good operation, agents. We didn't get everything, but not even we are perfect.",
					"Thanks for the good work, y'all. Return to base and relax a bit before your next job."
				)
				parts += span_greentext(span_big("Infiltrator Moderate Victory"))
				parts += span_bold("The Syndicate infiltrators completed most of their objectives successfully!")
				flavor_message = pick(messages)
			if (INFILTRATION_SOMECOMPLETE)
				var/static/list/messages = list(
					"Better than a complete fluke, I guess.",
					"I'm going to have to pull some strings to make sure we don't get a pay cut for sub-par preformance.",
					"I suppose it wasn't a complete waste of time at least..."
				)
				parts += span_marooned(span_big("Neutral victory"))
				parts += span_bold("The Syndicate infiltrators completed some of their objectives, but not enough to win.")
				flavor_message = pick(messages)
			else
				var/static/list/messages = list(
					"When you nitwits come back to base, y'all better have a damn good explaination for this!",
					"I hope y'all like space carp poop, because cleaning it is the biggest operation you idiots are going to have for a while!",
					"How did y'all mess up such a simple operation? All you had to do was be sneaky and not cause a scene!"
				)
				parts += span_redtext(span_big("Crew Victory</span>"))
				parts += span_bold("The crew stopped the Syndicate infiltrators from completing any of their objectives!</B>")
				flavor_message = pick(messages)
	parts += "<div><font color='#FF0000'><i>\"[flavor_message]\"</i></font>"
	parts += "[GLOB.TAB]- Syndicate Commander [pick(pick(GLOB.first_names_male,GLOB.first_names_female))] [pick(GLOB.last_names)]</div>"

	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	var/text = span_header("The syndicate infiltrators were:")
	var/purchases = ""
	var/tc_spent = 0
	for (var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if (H)
			tc_spent += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)
	text += "(Syndicates used [tc_spent] TC) [purchases]"
	if (tc_spent == 0 && !dead_as_a_doornail && result < INFILTRATION_NONECOMPLETE)
		text += span_big("[icon2html('icons/badass.dmi', world, "badass")]")
	parts += text
	parts += printobjectives(objectives)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/infiltrator/is_gamemode_hero()
	return SSticker.mode.name == "infiltration"

/datum/team/infiltrator/proc/forge_single_objective() // Complete traitor copypasta!
	if(prob(50))
		if(prob(30))
			add_objective(/datum/objective/maroon)
		else
			add_objective(/datum/objective/assassinate)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives))
			var/datum/objective/download/objective = add_objective(/datum/objective/download)
			objective.gen_amount_goal()
		else
			add_objective(/datum/objective/steal)

/datum/team/infiltrator/proc/add_objective(type)
	var/datum/objective/O = type
	if (ispath(type))
		O = new type
	O.find_target()
	O.team = src
	objectives |= O
	if(istype(O, /datum/objective/steal))
		var/datum/objective/steal/S = O
		if(S.targetinfo)
			for(var/item in S.targetinfo.special_equipment)
				for(var/turf/T in GLOB.infiltrator_objective_items)
					if(!(item in T.contents))
						new item(T)
	return O

/datum/team/infiltrator/proc/update_objectives()
	if(LAZYLEN(objectives))
		return
	var/list/major_objectives = subtypesof(/datum/objective/infiltrator)
	var/major = rand(MIN_MAJOR_OBJECTIVES, MAX_MAJOR_OBJECTIVES)
	var/minor = rand(MIN_MINOR_OBJECTIVES, MAX_MINOR_OBJECTIVES)
	for(var/i in 1 to major)
		var/objective_type = pick_n_take(major_objectives)
		var/datum/objective/infiltrator/objective = new objective_type
		if (objective.is_possible())
			add_objective(objective)
		else
			qdel(objective)
	for(var/i in 1 to minor)
		forge_single_objective()
	for(var/datum/mind/M in members)
		var/datum/antagonist/infiltrator/I = M.has_antag_datum(/datum/antagonist/infiltrator)
		if(I)
			I.objectives |= objectives
		M.announce_objectives()

/datum/team/infiltrator/proc/get_result()
	var/objectives_complete = 0
	var/objectives_failed = 0

	for(var/datum/objective/O in objectives)
		if(O.check_completion())
			objectives_complete++
		else
			objectives_failed++

	if(objectives_failed == 0 && objectives_complete > 0) //Complete all, and fail none, big win!
		return INFILTRATION_ALLCOMPLETE
	else if (objectives_failed == 1 && objectives_complete > 0) // Fail one, but complete the rest, still pretty good!
		return INFILTRATION_MOSTCOMPLETE
	else if((objectives_complete == objectives_failed) || (objectives_complete > 0 && objectives_failed > objectives_complete)) //Fail almost all of them, not very good...
		return INFILTRATION_SOMECOMPLETE
	else
		return INFILTRATION_NONECOMPLETE //You completely failed, you suck.
