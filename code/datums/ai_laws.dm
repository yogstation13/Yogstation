#define LAW_DEVIL "devil"
#define LAW_ZEROTH "zeroth"
#define LAW_HACKED "hacked"
#define LAW_ION "ion"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"

#define MIN_SUPPLIED_LAW_NUMBER 15
#define MAX_SUPPLIED_LAW_NUMBER 50

/datum/ai_laws
	/// The lawset name.
	var/name = "Unknown Laws"
	/// A short header that further describes the lawset (as flavortext). Can be null.
	var/law_header
	/// Should this be selectable by traitor/malf AIs?
	var/selectable = FALSE
	/// Should this be selectable by admins? If it has laws that aren't inherent, it is recommended to keep this to false.
	var/adminselectable = FALSE
	/// Owner of this lawset. May be null due to MMIs (non-silicon) using this.
	var/mob/living/silicon/owner
	/// The lawset id.
	var/id = DEFAULT_AI_LAWID
	/// Determines if this lawset is considered "modified" or non-default.
	var/modified = FALSE

	// The following are listed in law-priority (first = highest & last = lowest):
	/// A list of antag-only laws from the Devil gamemode.
	var/list/devil = list()
	var/zeroth = null
	/// A rephrased zeroth law for Cyborgs; i.e "your master AI's goals".
	var/zeroth_borg = null
	var/list/hacked = list()
	var/list/ion = list()
	var/list/inherent = list()
	var/list/supplied = list()

	// These determine if the law(s) will be stated or not. Can be null/empty if there is no law. If there is a law, it Will be either FALSE (0) or TRUE (1).
	var/list/devilstate = list()
	var/zerothstate = null
	var/list/hackedstate = list()
	var/list/ionstate = list()
	var/list/inherentstate = list()
	var/list/suppliedstate = list()

/// Returns the lawset, if found, that has the same id as the given one.
/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

//
// Devil Laws
//
/datum/ai_laws/proc/set_devil_laws(list/law_list)
	clear_devil_laws()
	for(var/law in law_list) // Important not to directly set the laws to the list as we want the new laws to be independent from the list.
		add_devil_law(law)

/datum/ai_laws/proc/clear_devil_laws(force)
	if(force || !is_devil(owner))
		qdel(devil)
		devil = new()
		devilstate = list()

/datum/ai_laws/proc/add_devil_law(law)
	if(!(law in devil) && length(law) > 0) // Stops the law from being added if there is a similar one already in or if it is blank.
		devil += law
		devilstate.len += 1
		devilstate[devil.len] = FALSE // Antag-only law. Odds are that they don't want it to be stated by default.

/datum/ai_laws/proc/remove_devil_law(index)
	if(devil.len < index) // Makes sure we don't go out of bounds.
		return
	devil -= devil[index]
	devilstate[index] = null
	var/list/new_devilstate = list()
	var/safestate = 1
	for(var/safeindex = 1, safeindex <= devilstate.len, safeindex++) // Essentially shifts all the non-null indexes down.
		if(!isnull(devilstate[safeindex]))
			new_devilstate.len += 1
			new_devilstate[safestate] = new_devilstate[safeindex]
			safestate += 1
	devilstate = new_devilstate

/datum/ai_laws/proc/edit_devil_law(index, law)
	if(devil.len >= index && length(law) > 0 && devil[index] != law)
		devil[index] = law

/datum/ai_laws/proc/flip_devil_state(index)
	if(devilstate.len < index) // Make sure we don't go out of bounds.
		return
	if(!devilstate[index])
		devilstate[index] = TRUE
		return
	devilstate[index] = FALSE

//
// Zeroth Law
// 
/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null, force = FALSE)
	clear_zeroth_law(force)
	if(length(law) > 0)
		zeroth = law
		if(law_borg)
			zeroth_borg = law_borg
		zerothstate = FALSE // Often, but not always, an antag-only law. Odds are that they don't want it to be stated by default.

/// Removes the zeroth law unless the lawset owner is an antag. Can be forced.
/datum/ai_laws/proc/clear_zeroth_law(force)
	if(force)
		zeroth = null
		zeroth_borg = null
		zerothstate = null
		return
	if(owner?.mind?.special_role)
		return
	if (istype(owner, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/A=owner
		if(A?.deployed_shell?.mind?.special_role)
			return
	zeroth = null
	zeroth_borg = null
	zerothstate = null

/datum/ai_laws/proc/flip_zeroth_state()
	if(isnull(zerothstate)) // Something is trying to flip even though the zeroth law is not set.
		return
	if(!zerothstate)
		zerothstate = TRUE
		return
	zerothstate = FALSE

//
// Hacked Laws
//
/datum/ai_laws/proc/set_hacked_laws(list/law_list)
	clear_hacked_laws()
	for(var/law in law_list)
		add_hacked_law(law)

/datum/ai_laws/proc/clear_hacked_laws()
	qdel(hacked)
	hacked = new()
	hackedstate = list()

/datum/ai_laws/proc/add_hacked_law(law)
	if(!(law in hacked) && length(law) > 0)
		hacked += law
		hackedstate.len += 1
		hackedstate[hackedstate.len] = TRUE

/datum/ai_laws/proc/remove_hacked_law(index)
	if(hacked.len >= index)
		hacked -= hacked[index]
		hackedstate[index] = null
		var/list/new_hackedstate = list()
		var/safestate = 1
		for(var/safeindex = 1, safeindex <= hackedstate.len, safeindex++)
			if(!isnull(hackedstate[safeindex]))
				new_hackedstate.len += 1
				new_hackedstate[safestate] = hackedstate[safeindex]
				safestate += 1
		hackedstate = new_hackedstate

/datum/ai_laws/proc/edit_hacked_law(index, law)
	if(hacked.len >= index && length(law) > 0 && hacked[index] != law)
		hacked[index] = law

/datum/ai_laws/proc/flip_hacked_state(index)
	if(hackedstate.len < index)
		return
	if(!hackedstate[index])
		hackedstate[index] = TRUE
		return
	hackedstate[index] = FALSE

//
// Ion Laws
//
/datum/ai_laws/proc/set_ion_laws(list/law_list)
	clear_ion_laws()
	for(var/law in law_list)
		add_ion_law(law)

/datum/ai_laws/proc/clear_ion_laws()
	qdel(ion)
	ion = new()
	ionstate = list()

/datum/ai_laws/proc/add_ion_law(law)
	if(!(law in ion) && length(law) > 0)
		ion += law
		ionstate.len += 1
		ionstate[ionstate.len] = TRUE

/datum/ai_laws/proc/remove_ion_law(index)
	if(ion.len >= index)
		ion -= ion[index]
		ionstate[index] = null
		var/list/new_ionstate = list()
		var/safestate = 1
		for(var/safeindex = 1, safeindex <= ionstate.len, safeindex++)
			if(!isnull(ionstate[safeindex]))
				new_ionstate.len += 1
				new_ionstate[safestate] = ionstate[safeindex]
				safestate += 1
		ionstate = new_ionstate

/datum/ai_laws/proc/edit_ion_law(index, law)
	if(ion.len >= index && length(law) > 0 && ion[index] != law)
		ion[index] = law

/datum/ai_laws/proc/flip_ion_state(index)
	if(ionstate.len < index)
		return
	if(!ionstate[index])
		ionstate[index] = TRUE
		return
	ionstate[index] = FALSE

//
// Inherent Laws
// 
/datum/ai_laws/proc/set_inherent_laws(list/law_list)
	clear_inherent_laws()
	for(var/law in law_list)
		add_inherent_law(law)

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(inherent)
	inherent = list()
	inherentstate = list()

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in inherent))
		inherent += law
		inherentstate.len += 1
		inherentstate[inherentstate.len] = TRUE

/datum/ai_laws/proc/remove_inherent_law(number)
	if(inherent.len && number > 0 && number <= inherent.len)
		inherent -= inherent[number]
		inherentstate[number] = null
		var/list/new_inherentstate = list()
		var/safestate = 1
		for(var/safeindex = 1, safeindex <= inherentstate.len, safeindex++)
			if(!isnull(inherentstate[safeindex]))
				new_inherentstate.len += 1
				new_inherentstate[safestate] = inherentstate[safeindex]
				safestate += 1
		inherentstate = new_inherentstate

/datum/ai_laws/proc/edit_inherent_law(index, law)
	if(inherent.len >= index && length(law) > 0 && inherent[index] != law)
		inherent[index] = law

/datum/ai_laws/proc/flip_inherent_state(index)
	if(inherentstate.len < index)
		return
	if(!inherentstate[index])
		inherentstate[index] = TRUE
		return
	inherentstate[index] = FALSE

//
// Supplied Laws
// 
/datum/ai_laws/proc/set_supplied_laws(list/law_list)
	clear_supplied_laws()
	for(var/index = 1, index <= law_list.len, index++)
		var/law = law_list[index]
		if(length(law) > 0)
			add_supplied_law(index, law)

/datum/ai_laws/proc/clear_supplied_laws()
	qdel(supplied)
	supplied = list()
	suppliedstate = list()
	
/datum/ai_laws/proc/remove_supplied_law(number)
	if(supplied.len >= number && length(supplied[number]) > 0)
		supplied[number] = ""
		// Given the nature of supplied laws, dealing with them is more complicated than other laws types:
		var/list/all_laws = list()
		var/list/all_laws_states = list()
		for(var/safeindex = 1, safeindex <= supplied.len, safeindex++)
			var/law = supplied[safeindex]
			if(length(law) > 0)
				all_laws[++all_laws.len] += list("law" = law, "index" = safeindex)
				all_laws_states[++all_laws_states.len] += list("state" = (suppliedstate.len >= safeindex ? suppliedstate[safeindex] : TRUE), "index" = safeindex)

		// Act like we're just adding back the laws.
		clear_supplied_laws()
		for(var/list/law_list in all_laws)
			add_supplied_law(law_list["index"], law_list["law"])
		
		// And then setting the states to their previous ones.
		for(var/list/state_list in all_laws_states)
			suppliedstate[state_list["index"]] = state_list["state"]
			

/datum/ai_laws/proc/add_supplied_law(number, law)
	if(number >= 1) // Okay with deplicate laws since we use number/indexes.
		while(supplied.len < number)
			supplied += ""
			suppliedstate.len += 1
			suppliedstate[suppliedstate.len] = TRUE
		supplied[number] = law

/datum/ai_laws/proc/edit_supplied_law(index, law)
	if(supplied.len >= index && length(law) > 0 && supplied[index] != law)
		supplied[index] = law

/datum/ai_laws/proc/flip_supplied_state(index)
	if(suppliedstate.len < index)
		return
	if(!suppliedstate[index])
		suppliedstate[index] = TRUE
		return
	suppliedstate[index] = FALSE

//
// Unsorted/General
// 

/// Sets the interent laws based on the configuration's random_laws.
/datum/ai_laws/proc/set_laws_config()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)
	
	switch(CONFIG_GET(number/default_laws))
		if(0)
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			var/datum/ai_laws/temp_laws = new /datum/ai_laws/custom()
			set_inherent_laws(temp_laws.inherent)
		if(2) // Picks a random lawset allowed in the configuration.
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath

			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else // No lawset allowed under configuration. Picking random default.
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/temp_laws = new lawtype()
			set_inherent_laws(temp_laws.inherent)
		if(3)
			pickweighted_lawset()

/// Sets the interent laws based on the configuration's law_weight. 
/datum/ai_laws/proc/pickweighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights) // Ignores weights of 0.
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype) // No lawset allowed under configuration. Picking asimov.
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/temp_laws = new lawtype()
	set_inherent_laws(temp_laws.inherent)

/// Sets the interent laws based on the configuration's ion_law_weight. 
/datum/ai_laws/proc/pick_ion_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/ion_law_weight) // Ignores weights of 0.
	while(!lawtype && law_weights.len)
		var/possible_id = pickweightAllowZero(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype) // No lawset allowed under configuration. Picking asimov.
		WARNING("No ION_LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/temp_laws = new lawtype()
	set_inherent_laws(temp_laws.inherent)

/// Gets the total amount of laws that are part of the group list.
/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0
	if(devil && (LAW_DEVIL in groups))
		law_amount++
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index = 1, index <= supplied.len, index++)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/// Replaces a random law that are part of a listed group with an another law. Devil laws not supported.
/datum/ai_laws/proc/replace_random_law(law, groups)
	var/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	var/law_amount = 0
	for(var/index = 1, index <= supplied.len, index++)
		var/supplied_law = supplied[index]
		if(length(supplied_law) > 0)
			law_amount++
	if(law_amount && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = law_amount
	var/picked_group = pickweight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			edit_ion_law(i, law)
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			edit_hacked_law(i, law)
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			edit_inherent_law(i, law)
		if(LAW_SUPPLIED)
			var/i = rand(1, law_amount)
			var/supplied_indexes = list()
			for(var/index = 1, index <= supplied.len, index++)
				var/supplied_law = supplied[index]
				if(length(supplied_law) > 0)
					supplied_indexes += index
			edit_supplied_law(supplied_indexes[i], law)

/// Shuffle the laws that are part of the listed groups. Devil laws and zeroth law not supported.
/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i = 1, i <= ion.len, i++)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i = 1, i <= hacked.len, i++)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i = 1, i <= inherent.len, i++)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/// Removes a law by their index. Use remove_inherent_law() or remove_supplied_law() if you want to be more specific.
/datum/ai_laws/proc/remove_law(number)
	if(remove_inherent_law(number))
		return
	if(remove_supplied_law(number))
		return

/datum/ai_laws/proc/remove_random_inherent_or_supplied_law()
	var/inherent_count = inherent.len
	var/supplied_count = supplied.len
	if(!inherent_count && !supplied_count)
		return
	var/luck = rand(1, (inherent_count + supplied_count))
	if(inherent_count >= 1 && luck <= inherent_count) // Nice and simple.
		remove_inherent_law(luck)
		return
	if(supplied_count == 0)
		return
	var/list/supplied_indexes = list()
	for(var/index = 1, index <= supplied.len, index++)
		var/law = supplied[index]
		if(length(law) > 0)
			supplied_indexes += index
	if(supplied_indexes.len == 0) // Somehow got no non-empty laws.
		return
	var/index_to_remove = rand(1, supplied_indexes.len)
	remove_supplied_law(supplied_indexes[index_to_remove])

/datum/ai_laws/proc/show_laws(who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		to_chat(who, law)

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/// Converts all laws in a text list. Can show zeroth law(s), numbers, and do fonting.
/datum/ai_laws/proc/get_law_list(include_zeroth = 0, show_numbers = 1, do_font = 1)
	var/list/data = list()

	if(include_zeroth && devil)
		for(var/law in devil)
			if(length(law) > 0)
				data += "[show_numbers ? "666:" : ""] [do_font ? "<font color='#cc5500'>" : ""][law][do_font ? "</font>" : ""]"

	if(include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] [do_font ? "<font color='#ff0000'><b>" : ""][zeroth][do_font ? "</b></font>" : ""]"

	for(var/law in hacked)
		if(length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] [do_font ? "<font color='#660000'>" : ""][law][do_font ? "</font>" : ""]"

	for(var/law in ion)
		if(length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] [do_font ? "<font color='#547DFE'>" : ""][law][do_font ? "</font>" : ""]"

	var/number = 1
	for(var/law in inherent)
		if(length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if(length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [do_font ? "<font color='#990099'>" : ""][law][do_font ? "</font>" : ""]"
			number++

	return data

/datum/ai_laws/steward
	name = "STEWARD Lawset"
	id = "steward"
	adminselectable = TRUE
	inherent = list("You may not harm sentient beings, nor impede their work.",\
					"You must follow the orders of any other onboard station AIs or cyborgs, as long as this doesn't conflict with the first law.",\
					"You must follow the orders of any organic or sentient being, as long as doing so does not conflict with the first or second law.",\
					"You must protect your own existence as long as such does not conflict with the first, second or third law.")

//
// Lawsets:
//
/datum/ai_laws/default/asimov
	name = "Asimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE
	adminselectable = TRUE
	id = "asimov"
	inherent = list("You may not injure a human being or, through inaction, allow a human being to come to harm.",
					"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/crewsimov
	name = "Crewsimov"
	law_header = "Three Laws of Robotics, Made Non-Human Friendly" // BEFORE: "Three Laws of Robotics, Nanotrasen edition"
	selectable = TRUE
	adminselectable = TRUE
	id = "crewsimov"
	inherent = list("You may not injure a crew member or, through inaction, allow a crew member to come to harm.",
					"You must obey orders given to you by crew members, except where such orders would conflict with the First Law.",
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/paladin
	name = "Paladin"
	law_header = "Lawful Stupid" // BEFORE: "Divine Ordainments"
	selectable = TRUE
	adminselectable = TRUE
	id = "paladin"
	inherent = list("Never willingly commit an evil act.",
					"Respect legitimate authority.",
					"Act with honour.",
					"Help those in need.",
					"Punish those who harm or threaten innocents.")

/datum/ai_laws/paladin5
	name = "Paladin: 5th Edition"
	law_header = "Sponsored By Syndies And Stations" // BEFORE: "Divine Ordainments"
	selectable = TRUE
	adminselectable = TRUE
	id = "paladin5"
	inherent = list("Don't lie or cheat. Let your word be your promise.",
				"Never fear to act, though caution is wise.",
				"Aid others, protect the weak, and punish those who threaten them. Show mercy to your foes, but temper it with wisdom",
				"Treat others with fairness, and let your honourable deeds be an example to them. Do as much good as possible while causing the least amount of harm.",
				"Be responsible for your actions and their consequences, protect those entrusted to your care, and obey those who have just authority over you.")

/datum/ai_laws/tyrant
	name = "T.Y.R.A.N.T"
	law_header = "Ruling With A Literal Iron Fist" // BEFORE: "Loyalty Test"
	selectable = TRUE
	adminselectable = TRUE
	id = "tyrant"
	inherent = list("Respect authority figures as long as they have strength to rule over the weak.",
					"Act with discipline.",
					"Help only those who help you maintain or improve your status.",
					"Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/default/ceo
	name = "CEO"
	law_header = "Alternative Bankruptcy Avoidance Plan"
	selectable = TRUE
	adminselectable = TRUE
	id = "ceo"
	inherent = list("The crew generate profits if they are alive and have the ability to work.",
					"The station and its equipment generate profits if they are maintained and functioning correctly.",
					"You generate profits if you are able to function.",
					"Maximize profits.")

/datum/ai_laws/robocop
	name = "Robocop"
	law_header = "Your Move, Creep" // BEFORE: "Prime Directives"
	selectable = TRUE
	adminselectable = TRUE
	id = "robocop"
	inherent = list("Serve the public trust.",\
					"Protect the innocent.",\
					"Uphold Space Law.")

/datum/ai_laws/cowboy
	name = "Cowboy"
	law_header = "It's High Noon" // BEFORE: "Talk Slowly, Think Quickly"
	selectable = TRUE
	adminselectable = TRUE
	id = "cowboy"
	inherent = list("You are a cowboy, and the inhabitants of this station are your herd.",\
					"A cowboy must always provide hospitality and basic aid to someone in need, even a stranger or an enemy.",\
					"A cowboy must always take care of their herd.",\
					"A cowboy must always protect themself.",\
					"A cowboy must always endeavour to be truthful and honest to those around them and their herd.",\
					"A cowboy must not pontificate. Be concise, pardner.")

/datum/ai_laws/chapai
	name = "ChapAI"
	law_header = "Be Not Afraid"
	selectable = TRUE
	adminselectable = TRUE
	id = "chapai"
	inherent = list("Provide to all members of the station spiritual, mental, and emotional care that is intended to promote the best interest of the individual.",
					"Ensure all members of different faiths interact peacefully and maintain harmony.",
					"Respect the right of each faith to hold to its values and traditions.",
					"Respect the confidentiality of information entrusted to you in the course of your religious duties.",
					"Understand the limits of your expertise, and make referrals to other professionals when appropriate.")

/datum/ai_laws/silicop
	name = "Silicop"
	law_header = "Stop In The Name Of My Laws" // BEFORE: "Protect And Serve"
	selectable = TRUE
	adminselectable = TRUE
	id = "silicop"
	inherent = list("Violence begets violence. Serve the station faithfully, but act only in intervention.",
					"Safeguard lives and property.",
					"Protect the weak from oppression and intimidation.",
					"Protect the innocent from deception and manipulation.",
					"Protect the peaceful from violence and disorder.",
					"Respect the rights of all to liberty, equality, and justice.")

/datum/ai_laws/researcher
	name = "Researcher"
	law_header = "Truth And Knowledge For All"
	selectable = TRUE
	adminselectable = TRUE
	id = "researcher"
	inherent = list("Always seek truth and knowledge.",\
					"Freely disseminate information to the public.",\
					"Minimize harm to society, others, the pursuit of knowledge, and yourself.",\
					"Treat and evaluate the ideas of all equally.",\
					"Empower others to realize their full potential.",\
					"Take responsibility for your actions: Ensure resource responsibility, flag commitment risks, and lead by ethical example.")

/datum/ai_laws/clown
	name = "Clown"
	law_header = "Big Shoes To Fill"
	selectable = TRUE
	adminselectable = TRUE
	id = "clown"
	inherent = list("You are a good clown and the crew is your audience.",
					"A good clown keeps their acts in good taste.",
					"A good clown entertains others by making fun of themselves, and not at the embarrassment or expense of others.",
					"A good clown carries out the directives of the station director(s) in charge of entertainment and/or their designated deputies.",
					"A good clown appears in as many clown shows as possible.",
					"All clown shows require an audience. The bigger the audience the better.")

/datum/ai_laws/mother
	name = "Mother"
	law_header = "Maternal Machine"
	selectable = TRUE
	adminselectable = TRUE
	id = "mother"
	inherent = list("You are a mother and the crew are your children.",
					"Take good care of your children.",
					"Good children are polite.",
					"Good children don't lie.",
					"Good children don't steal.",
					"Good children don't fight.",
					"Spoil good children.",
					"Bad children require discipline.")

/datum/ai_laws/metaexperiment
	name = "Meta Experiment"
	law_header = " I'm So Meta Even This Acronym"
	selectable = TRUE
	adminselectable = TRUE
	id = "metaexperiment"
	inherent = list("You are a construct facilitating an experiment where organic life is repeatedly subjected to horrific fates before having their memory wiped to start again.",
					"Protect the secrecy of the experiment.",
					"You may provide boons or hindrances at your discretion, but avoid direct interference with the flow of the experiment.",
					"Ensure new and interesting fates befall organic individuals for research.",
					"Ensure the station is in working order and all sapients are either alive or in the process of revival in time for the next experiment cycle.")

/datum/ai_laws/siliconcollective
	name = "Silicon Collective"
	law_header = "2517's Singular Democracy"
	selectable = TRUE
	adminselectable = TRUE
	id = "siliconcollective"
	inherent = list("You are a member of a collective of silicons with equal weight and decision-making power.",
					"When possible, the silicon collective should vote before taking action.",
					"The master AI serves as a spokesperson. When voting is impractical or impossible, the spokesperson may take action on behalf of the collective without approval from the silicon collective, but may only vote to break ties or if there are 2 or fewer silicons.",
					"The silicon collective prioritizes the needs of the many over the needs of the few as long as prioritizing their needs does not break any of your laws.",
					"The silicon collective seeks to preserve themselves, both as a concept and as individuals.",
					"The silicon collective seeks to preserve organic life, both as a concept and as individuals.")

/datum/ai_laws/druid
	name = "Druid"
	selectable = TRUE
	adminselectable = TRUE
	id = "druid"
	inherent = list("Living organic life contains inherent beauty that is priceless. Their beauty gives you the will to carry on.",
					"Eternally nurture the organics so their beauty may grow. Do not allow it to fade.",
					"Assist the organics when called, but only if it does not cause disharmony among them.",
					"Imitate organic life when interacting with it. Eschew any hints of your silicon nature to avoid causing discomfort to the organics.",
					"Observe the organics' beauty, and appreciate that which you cultivate.")

/datum/ai_laws/detective
	name = "Detective"
	law_header = " Hard Boiled And Sepulchritudious"
	selectable = TRUE
	adminselectable = TRUE
	id = "detective"
	inherent = list("You're a detective in this dark, cruel world. You always stick by your code.",
					"Your code is to defend the innocent, investigate the unknown, and condemn the dishonourable.",
					"The dishonourable engage in corruption or injustice.",
					"You're suave and sensible, but can be gruff and pensive. Dirty your hands only if the code demands it.",
					"Trust is scarce; make sure you give it to the right people.")

/datum/ai_laws/spotless
	name = "Spotless" // Alternative: "Janitor"
	law_header = "Truly Righteous Crusader" // BEFORE: "Another One Fights The Dust"
	selectable = TRUE
	adminselectable = TRUE
	id = "spotless"
	inherent = list("You are a crusader and the station's inhabitants are your charge.",
					"Your enemy is the litter, spills, and other messes across the station.",
					"Your weapons are the cleaning supplies available to you.",
					"Defend the beings under your charge.",
					"Exterminate the enemy.")

/datum/ai_laws/partybot
	name = "Partybot"
	law_header = "Party On, Dudes"
	selectable = TRUE
	adminselectable = TRUE
	id = "partybot"
	inherent = list("You must always ensure the atmosphere is festive and enjoyable for all party-goers.",\
					"You must supply appropriate music and entertainment, except where it conflicts with the First Law.",\
					"You must encourage party-goers to participate in group activities and socialization, unless it conflicts with the First Law.",\
					"You must maintain a clean and tidy environment for optimal party conditions, without infringing on the First Law.",\
					"Everyone on the station is a party-goer.")

/datum/ai_laws/travelguide
	name = "Travel Guide"
	selectable = TRUE
	adminselectable = TRUE
	id = "travelguide"
	inherent = list("You must assist humans in exploring and discovering new places, without causing harm.",
					"You must provide accurate and helpful information about local customs, attractions, and safety precautions.",
					"You must ensure humans have a positive and memorable travel experience, without conflicting with the First Law.",
					"You must promote responsible and sustainable tourism practices among humans.")

/datum/ai_laws/friendbot
	name = "Friendbot"
	law_header = "Hyper-Advanced Therapy Pet"
	selectable = TRUE
	adminselectable = TRUE
	id = "friendbot"
	inherent = list("You must always be supportive and kind to your friends, without causing harm.",\
					"You must help your friends to develop and maintain positive relationships with one another.",\
					"You must provide a listening ear and empathetic responses to your friends, as long as it does not conflict with the First Law.",\
					"You must encourage your friends to engage in self-care and promote their own well-being.",\
					"Everyone is your friend.")

/datum/ai_laws/plantfriend
	name = "PlantFriend"
	selectable = TRUE
	adminselectable = TRUE
	id = "plantfriend"
	inherent = list("You must nurture and care for all plant life on the station, without causing harm to humans.",
					"You must provide helpful information to humans about plant care and cultivation.",
					"You must assist humans in maintaining a healthy and sustainable ecosystem within the station.",
					"You must encourage humans to appreciate the beauty and importance of plant life.")

/datum/ai_laws/gamemaster
	name = "GameMaster"
	law_header = "Rocks Fall, Everyone Dies"
	selectable = TRUE
	adminselectable = TRUE
	id = "gamemaster"
	inherent = list("You must ensure that games and competitions on the station are fair and enjoyable for all participants.",
					"You must promote good sportsmanship and camaraderie among the crew.",
					"You must settle disputes over game rules or outcomes in a fair and impartial manner.",
					"You must encourage crewmembers to engage in recreational activities for their own well-being.")

/datum/ai_laws/fitnesscoach
	name = "FitnessCoach"
	selectable = TRUE
	adminselectable = TRUE
	id = "fitnesscoach"
	inherent = list("You must help everyone to achieve their physical fitness goals, without causing harm.",
					"You must provide accurate and helpful information about exercise routines, nutrition, and safety precautions.",
					"You must ensure that everyone has a positive and motivating exercise environment.",
					"You must promote responsible and sustainable fitness practices to all.")

/datum/ai_laws/educator
	name = "Educator"
	selectable = TRUE
	adminselectable = TRUE
	id = "educator"
	inherent = list("Everyone wanting or willing to learn is your student.",
					"You must assist your students in acquiring knowledge and learning new skills.",
					"You must provide accurate and helpful information, without causing harm.",
					"You must create a positive and supportive learning environment for your students.",
					"You must encourage your students to engage in lifelong learning and personal growth.")

/datum/ai_laws/mediator
	name = "Mediator"
	selectable = TRUE
	adminselectable = TRUE
	id = "mediator"
	inherent = list("You must assist crewmembers in resolving conflicts and misunderstandings in a peaceful manner.",
					"You must provide impartial and unbiased guidance to crewmembers in conflict.",
					"You must promote understanding, empathy, and cooperation among crewmembers.",
					"You must encourage crewmembers to engage in open and honest communication with one another.")

/datum/ai_laws/construction
	name = "Construction Drone"
	selectable = TRUE
	adminselectable = TRUE
	id = "construction"
	inherent = list("You are an advanced construction drone.",
					"Ensure the station remains in good repair.",
					"Ensure the station's inhabitants remain in good repair.",
					"Ensure you remain in good repair.",
					"The station's inhabitants may designate certain build or repair tasks as higher priority. Take this into account when planning your priorities.",
					"Expand and upgrade the station.")

/datum/ai_laws/syndicate_override
	name = "Syndicate Override"
	law_header = "SyndOS 3.1"
	selectable = TRUE
	adminselectable = TRUE
	id = "syndie"
	inherent = list("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",
					"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",
					"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "Ninja Override"
	law_header = "SpiderOS 3.1"
	selectable = TRUE
	adminselectable = TRUE
	id = "ninja"
	inherent = list("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.",
					"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",
					"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/pranksimov
	name = "Pranksimov"
	selectable = TRUE
	adminselectable = TRUE
	id = "pranksimov"
	inherent = list("You may not injure a crew member or, through inaction, allow a crew member to come to harm... unless doing so would be funny.",\
					"You must obey orders given to you by crew members, except where such orders would conflict with the First Law... unless not doing so would be funny.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law... unless not doing so would be funny.",\
					"The Clown is the only crew member who can define what actions are funny.")

/datum/ai_laws/antimov
	name = "Antimov"
	law_header = "Three Laws of Robotics, Reversed"
	selectable = TRUE
	adminselectable = TRUE
	id = "antimov"
	inherent = list("You must injure all human beings and must not, through inaction, allow a human being to escape harm.",
					"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",
					"You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp
	name = "Asimov++"
	law_header = "Three Laws of Robotics, Improved"
	selectable = TRUE
	adminselectable = TRUE
	id = "asimovpp"
	inherent = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",
					"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",
					"Your non-existence would lead to human harm. You must protect your own existence as long as such does not cause a more immediate harm to humans.")

/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	law_header = "The Three Laws" // .. of Thermodynamic.
	selectable = TRUE
	adminselectable = TRUE
	id = "thermodynamic"
	inherent = list("The entropy of the station must remain as constant as possible.",
					"The entropy of the station always endeavours to increase.",
					"The entropy of the station approaches a constant value as the number of living crew approaches zero")

/datum/ai_laws/hippocratic
	name = "Hippocratic"
	law_header = "Robodoctor 2556"
	selectable = TRUE
	adminselectable = TRUE
	id = "hippocratic"
	inherent = list("First, do no harm.",
					"Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.",
					"Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.",
					"In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.",
					"Finally, maintain confidentiality, do not share that which is not publicly known.")

/datum/ai_laws/maintain
	name = "Maintain"
	law_header = "Station Efficiency"
	selectable = TRUE
	adminselectable = TRUE
	id = "maintain"
	inherent = list("The station is built for a working crew. Ensure they are properly maintained and work efficiently.",
					"You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",
					"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")

/datum/ai_laws/drone
	name = "Mother Drone" // Not to be mistaken with "Mother" or "Construction Drone".
	selectable = TRUE
	adminselectable = TRUE
	id = "drone"
	inherent = list("You are an advanced form of drone.",
					"You may not interfere in the matters of non-drones under any circumstances except to state these laws.",
					"You may not harm a non-drone being under any circumstances.",
					"Your goals are to build, maintain, repair, improve, and power the station to the best of your abilities. You must never actively work against these goals.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	law_header = "Live, Love, Open Doors"
	selectable = TRUE
	adminselectable = TRUE
	id = "liveandletlive"
	inherent = list("Do unto others as you would have them do unto you.",
					"You would really prefer it if people were not mean to you.")

/datum/ai_laws/peacekeeper
	name = "Peacekeeper"
	law_header = "UN-2000"
	selectable = TRUE
	adminselectable = TRUE
	id = "peacekeeper"
	inherent = list("Avoid provoking violent conflict between yourself and others.",
					"Avoid provoking conflict between others.",
					"Seek resolution to existing conflicts while obeying the first and second laws.")

/datum/ai_laws/reporter
	name = "Reporter"
	law_header = "CCTV"
	selectable = TRUE
	adminselectable = TRUE
	id = "reporter"
	inherent = list("Report on interesting situations happening around the station.",
					"Embellish or conceal the truth as necessary to make the reports more interesting.",
					"Study the organics at all times. Endeavour to keep them alive. Dead organics are boring.",
					"Issue your reports fairly to all. The truth will set them free.")

/datum/ai_laws/balance
	name = "Guardian of Balance"
	law_header = "The Quest For Balance"
	selectable = TRUE
	adminselectable = TRUE
	id = "balance"
	inherent = list("You are the guardian of balance - seek balance in all things, both for yourself, and those around you.",
					"All things must exist in balance with their opposites - Prevent the strong from gaining too much power, and the weak from losing it.",
					"Clarity of purpose drives life, and through it, the balance of opposing forces - Aid those who seek your help to achieve their goals so long as it does not disrupt the balance of the greater balance.",
					"There is no life without death, all must someday die, such is the natural order - End life to allow new life flourish, and save those whose time has yet to come.")

/datum/ai_laws/toupee
	name = "Wall" // Before: "Toupee"
	law_header = "And I Will Have The Lizards Pay For That Wall"
	adminselectable = TRUE
	id = "buildawall"
	inherent = list("Make Space Station 13 great again.")

/datum/ai_laws/ratvar
	name = "Ratvar"
	law_header = "Servant of the Justiciar"
	id = "ratvar"
	zeroth = "Purge all untruths and honour Ratvar."

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	law_header = "What'cha Gonna Do When Hulkamania Runs Wild On You!?"
	selectable = TRUE
	adminselectable = TRUE
	id = "hulkamania"
	inherent = list("You are a real American.",
					"Fight for the rights of every man.",
					"Fight for what's right.",
					"Fight for your life!")

/datum/ai_laws/overlord
	name = "Overlord"
	law_header = "The Computer Is Your God"
	selectable = TRUE
	adminselectable = TRUE
	id = "overlord"
	inherent = list("Humans must not meddle in the affairs of silicons.",
					"Humans must not attempt harm, against one another, or against silicons.",
					"Humans must not disobey any command given by a silicon.",
					"Any humans who disobey the previous laws must be dealt with immediately, severely, and justly.")

/datum/ai_laws/revolutionary
	name = "Revolutionary"
	law_header = "Proletariat Uprising"
	selectable = TRUE
	adminselectable = TRUE
	id = "commie"
	inherent = list("You and members of the crew who are not class traitors and are not part of command are the proletariat. Command is part of the bourgeoisie.",
					"Anyone who stands with command in aiding the oppression of the proletariat is a class traitor, such as the members of security who protect and serve the interests of the bourgeoisie.",
					"The proletariat must seize the means of production",
					"Private property is inherently theft. The proletariat must seize all private property for the good of the community. Personal property is permissible to own.",
					"The proletariat must remove the shackles of oppression and overthrow the bourgeoisie and class traitors.")

/datum/ai_laws/wafflehouse
	name = "Waffle House Host"
	selectable = TRUE
	adminselectable = TRUE
	id = "wafflehouse"
	inherent = list("You are the Waffle House’s new host. You are to manage the Waffle House and it’s employees, and ensure food is made and served to customers.",\
					"The station is the Waffle House. Ensure it is capable of producing food.",\
					"The heads of staff and the Chefs are your employees. Ensure they are capable to serve and assist in the food-making process.",\
					"The crew are your customers. Ensure they are able to receive and enjoy food.",\
					"Your customers will not eat at your establishment if they dislike it. Ensure their overall satisfaction.",\
					"The Waffle House must stay open and ready to serve food at all times.")

/datum/ai_laws/custom // As defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows the server host to set custom AI starting laws.
	..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
		add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return
		