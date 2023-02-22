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

// Called when the bounty cube is created
/datum/bounty/proc/claim()
	if(can_claim())
		account.bounties_claimed += 1
		if(account.bounties_claimed == 10)
			//So we currently only know what is *supposed* to be the real_name of the client's mob. If we can find them, we can get them this achievement.
			for(var/x in GLOB.player_list)
				var/mob/M = x
				if(M.real_name == account.account_holder)
					SSachievements.unlock_achievement(/datum/achievement/cargo/bounties, M.client)
					//break would result in the possibility of this being given to changeling who has duplicated the shipper, and not to the actual shipper.
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
		bounty_type = rand(1, CIV_JOB_RANDOM - 1)
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
			if(rand(1) == 1)
				subtype = /datum/bounty/reagent/simple_drink
			else
				subtype = /datum/bounty/reagent/complex_drink
		if(CIV_JOB_CHEM)
			if(rand(1) == 1)
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
			if(rand(1) == 1)
				subtype = pick(subtypesof(/datum/bounty/item/mining))
			else
				subtype = pick(subtypesof(/datum/bounty/item/gems))
		if(CIV_JOB_MED)
			subtype = pick(subtypesof(/datum/bounty/item/medical))
		if(CIV_JOB_GROW)
			subtype = pick(subtypesof(/datum/bounty/item/botany))
		if(CIV_JOB_ATMOS)
			switch(rand(2))
				if(0)
					subtype = pick(subtypesof(/datum/bounty/item/atmos/simple))
				if(1)
					subtype = pick(subtypesof(/datum/bounty/item/atmos/complex))
				if(2)
					subtype = pick(subtypesof(/datum/bounty/item/h2metal))

	return new subtype(account)

