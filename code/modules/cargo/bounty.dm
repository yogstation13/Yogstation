/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits.
	var/claimed = FALSE
	var/high_priority = FALSE
	var/datum/bank_account/account

/datum/bounty/New(datum/bank_account/account)
	src.account = account

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

// Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
/proc/random_bounty(guided, datum/bank_account/account)
	var/bounty_type
	if(!guided || guided == CIV_JOB_RANDOM)
		bounty_type = rand(1,13)
	else if(islist(guided))
		bounty_type = pick(guided)
	else
		bounty_type = guided

	var/subtype
	switch(bounty_type)
		if(CIV_JOB_BASIC)
			subtype = pick(subtypesof(/datum/bounty/item/assistant))
		if(CIV_JOB_ROBO)
			subtype = pick(subtypesof(/datum/bounty/item/mech))
		if(CIV_JOB_CHEF)
			subtype = pick(subtypesof(/datum/bounty/item/chef))
		if(CIV_JOB_SEC)
			subtype = pick(subtypesof(/datum/bounty/item/security))
		if(CIV_JOB_DRINK)
			if(rand(2) == 1)
				subtype = /datum/bounty/reagent/simple_drink
			else
				subtype = /datum/bounty/reagent/complex_drink
		if(CIV_JOB_CHEM)
			if(rand(2) == 1)
				subtype = /datum/bounty/reagent/chemical_simple
			else
				subtype = /datum/bounty/reagent/chemical_complex
		if(CIV_JOB_VIRO)
			subtype = pick(subtypesof(/datum/bounty/virus))
		if(CIV_JOB_SCI)
			subtype = pick(subtypesof(/datum/bounty/item/science))
		if(CIV_JOB_XENO)
			subtype = pick(subtypesof(/datum/bounty/item/slime))
		if(CIV_JOB_MINE)
			if(rand(2) == 1)
				subtype = pick(subtypesof(/datum/bounty/item/mining))
			else
				subtype = pick(subtypesof(/datum/bounty/item/gems))
		if(CIV_JOB_MED)
			subtype = pick(subtypesof(/datum/bounty/item/medical))
		if(CIV_JOB_GROW)
			subtype = pick(subtypesof(/datum/bounty/item/botany))
		if(CIV_JOB_ATMO)
			switch(rand(3))
				if(1)
					subtype = pick(subtypesof(/datum/bounty/item/atmos/simple))
				if(2)
					subtype = pick(subtypesof(/datum/bounty/item/atmos/complex))
				if(3)
					subtype = pick(subtypesof(/datum/bounty/item/h2metal))

	return new subtype(account)

