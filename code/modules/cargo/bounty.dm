GLOBAL_LIST_EMPTY(bounties_list)

/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits.
	var/claimed = FALSE
	var/high_priority = FALSE

// Displayed on bounty UI screen.
/datum/bounty/proc/completion_string()
	return ""

// Displayed on bounty UI screen.
/datum/bounty/proc/reward_string()
	return "[reward] Credits"

/datum/bounty/proc/can_claim()
	return !claimed

// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim(mob/user)
	if(can_claim())
		// var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		// if(D)
		// 	D.adjust_money(reward * SSeconomy.bounty_modifier)
		// 	D.bounties_claimed += 1
		// 	if(D.bounties_claimed == 10)
		// 		SSachievements.unlock_achievement(/datum/achievement/cargo/bounties, user.client)
		claimed = TRUE

// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	return FALSE

// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	return

// When randomly generating the bounty list, duplicate bounties must be avoided.
// This proc is used to determine if two bounties are duplicates, or incompatible in general.
/datum/bounty/proc/compatible_with(other_bounty)
	return TRUE

/datum/bounty/proc/mark_high_priority(scale_reward = 2)
	if(high_priority)
		return
	high_priority = TRUE
	reward = round(reward * scale_reward)

// Returns FALSE if the bounty is incompatible with the current bounties.
/proc/try_add_bounty(datum/bounty/new_bounty)
	if(!new_bounty || !new_bounty.name || !new_bounty.description)
		return FALSE
	for(var/i in GLOB.bounties_list)
		var/datum/bounty/B = i
		if(!B.compatible_with(new_bounty) || !new_bounty.compatible_with(B))
			return FALSE
	GLOB.bounties_list += new_bounty
	return TRUE

// Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
/proc/random_bounty(guided = FALSE)
	var/bounty_type
	if(!guided || guided == CIV_JOB_RANDOM)
		bounty_type = rand(1,13)
	else if(islist(guided))
		bounty_type = pick(guided)
	else
		bounty_type = guided

	switch(bounty_type)
		if(CIV_JOB_BASIC)
			var/subtype = pick(subtypesof(/datum/bounty/item/assistant))
			return new subtype
		if(CIV_JOB_ROBO)
			var/subtype = pick(subtypesof(/datum/bounty/item/mech))
			return new subtype
		if(CIV_JOB_CHEF)
			var/subtype = pick(subtypesof(/datum/bounty/item/chef))
			return new subtype
		if(CIV_JOB_SEC)
			var/subtype = pick(subtypesof(/datum/bounty/item/security))
			return new subtype
		if(CIV_JOB_DRINK)
			if(rand(2) == 1)
				return new /datum/bounty/reagent/simple_drink
			return new /datum/bounty/reagent/complex_drink
		if(CIV_JOB_CHEM)
			if(rand(2) == 1)
				return new /datum/bounty/reagent/chemical_simple
			return new /datum/bounty/reagent/chemical_complex
		if(CIV_JOB_VIRO)
			var/subtype = pick(subtypesof(/datum/bounty/virus))
			return new subtype
		if(CIV_JOB_SCI)
			var/subtype = pick(subtypesof(/datum/bounty/item/science))
			return new subtype
		if(CIV_JOB_XENO)
			var/subtype = pick(subtypesof(/datum/bounty/item/slime))
			return new subtype
		if(CIV_JOB_MINE)
			var/subtype = pick(subtypesof(/datum/bounty/item/mining))
			return new subtype
		if(CIV_JOB_MED)
			var/subtype = pick(subtypesof(/datum/bounty/item/medical))
			return new subtype
		if(CIV_JOB_GROW)
			var/subtype = pick(subtypesof(/datum/bounty/item/botany))
			return new subtype
		if(CIV_JOB_ATMO)
			var/subtype
			if(rand(2) == 1)
				subtype = pick(subtypesof(/datum/bounty/item/atmos/simple))
			else
				subtype = pick(subtypesof(/datum/bounty/item/atmos/complex))
			return new subtype

// Called lazily at startup to populate GLOB.bounties_list with random bounties.
/proc/setup_bounties()

	var/pick // instead of creating it a bunch let's go ahead and toss it here, we know we're going to use it for dynamics and subtypes!

	/********************************Subtype Gens********************************/
	var/list/easy_add_list_subtypes = list(/datum/bounty/item/assistant = 3)

	for(var/the_type in easy_add_list_subtypes)
		for(var/i in 1 to easy_add_list_subtypes[the_type])
			pick = pick(subtypesof(the_type))
			try_add_bounty(new pick)

/proc/completed_bounty_count()
	var/count = 0
	for(var/i in GLOB.bounties_list)
		var/datum/bounty/B = i
		if(B.claimed)
			++count
	return count

