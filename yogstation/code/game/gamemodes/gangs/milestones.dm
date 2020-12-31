/datum/objective/gang  // Abstract

/datum/objective/gang/dominate
	name = "Dominate"
	explanation_text = "Take over the station by activating the Dominator device."

/datum/objective/gang/dominate/check_completion()
	var/datum/team/gang/gang = team
	return (gang.winner)

/datum/objective/gang/control
	name = "Control"
	var/control_amount

/datum/objective/gang/control/New()
	control_amount = rand(15, 30)
	explanation_text = "Control at least [control_amount] percent of the station at the end of the shift."

/datum/objective/gang/control/check_completion()
	var/datum/team/gang/gang = team
	if(!(gang.territories.len >= control_amount))
		return FALSE
	return TRUE

/datum/objective/gang/money
	name = "Earn credits"
	var/money_amount
	var/datum/bank_account/gang_account

/datum/objective/gang/money/New()
	money_amount = rand(40000, 70000)
	target_amount = money_amount
	explanation_text = "Have at least [target_amount] credits in your gang's account at the end of the shift."

/datum/objective/gang/money/check_completion()
	var/datum/team/gang/gang = team
	return (gang.registered_account.has_money(money_amount))

/datum/objective/gang/members
	name = "Convert gangsterts"

/datum/objective/gang/members/New()
	target_amount = rand(7,12)
	explanation_text = "Have at least [target_amount] gangsters in your gang at the end of the shift."

/datum/objective/gang/members/check_completion()
	var/datum/team/gang/gang = team
	gang.count_members()
	return (gang.members_amount >= target_amount)

/datum/objective/gang/vip // Abstract type
	var/target_role_type = FALSE
	var/list/possible_targets = list()
	var/list/datum/mind/officers
	var/list/datum/mind/heads
	var/list/blacklist = list()

/datum/objective/gang/vip/inside_man/New()
	name = "Inside Man"
	find_inside_man()

/datum/objective/gang/vip/inside_man/proc/find_inside_man()
	for(var/datum/mind/possible_target in SSjob.get_living_sec())
		possible_targets += possible_target
	if(!possible_targets.len) // DEBUG_TEXT
		explanation_text = "this failed."
	target = pick(possible_targets)
	explanation_text = "Convert [target.name], the [target.assigned_role], to your gang."

/datum/objective/gang/vip/inside_man/check_completion()
	var/list/datum/mind/owners = get_owners()
	return (target in owners)

/datum/objective/gang/vip/average_joe/New()
	..()
	name = "Average Joe"
	officers = SSjob.get_living_sec()
	heads = SSjob.get_living_heads()
	find_average_joe()

/datum/objective/gang/vip/average_joe/proc/find_average_joe()
	blacklist += officers
	blacklist += heads
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (!(possible_target.special_role == ROLE_GANG)))
			if(!(possible_target in blacklist))
				possible_targets += possible_target
	if(!possible_targets.len) // DEBUG_TEXT
		explanation_text = "this failed."
	target = pick(possible_targets)
	explanation_text = "Convert [target.name], the [target.assigned_role], to your gang."

/datum/objective/gang/vip/average_joe/check_completion()
	var/list/datum/mind/owners = get_owners()
	return (target in owners)

/datum/objective/gang/all_from_one
	var/department
	var/list/datum/mind/converted_targets

/datum/objective/gang/all_from_one/New()
	department = pick("engineering", "science", "medical", "supply")
	explanation_text = "Convert all members of the [department] department to your gang."

/datum/objective/gang/all_from_one/check_completion()
	var/datum/team/gang/gang = team
	switch(department)
		if("engineering")
			for(var/datum/mind/possible_target in SSjob.get_living_engineers())
				target_amount++
				var/datum/antagonist/gang/G = possible_target.has_antag_datum(/datum/antagonist/gang)
				if(G)
					var/datum/team/gang/possible_gang = G.get_team()
					if(possible_gang == gang)
						converted_targets |= possible_target
		if("science")
			for(var/datum/mind/possible_target in SSjob.get_living_science())
				target_amount++
				var/datum/antagonist/gang/G = possible_target.has_antag_datum(/datum/antagonist/gang)
				if(G)
					var/datum/team/gang/possible_gang = G.get_team()
					if(possible_gang == gang)
						converted_targets |= possible_target
		if("medical")
			for(var/datum/mind/possible_target in SSjob.get_living_medical())
				target_amount++
				var/datum/antagonist/gang/G = possible_target.has_antag_datum(/datum/antagonist/gang)
				if(G)
					var/datum/team/gang/possible_gang = G.get_team()
					if(possible_gang == gang)
						converted_targets |= possible_target
		if("supply")
			for(var/datum/mind/possible_target in SSjob.get_living_supply())
				target_amount++
				var/datum/antagonist/gang/G = possible_target.has_antag_datum(/datum/antagonist/gang)
				if(G)
					var/datum/team/gang/possible_gang = G.get_team()
					if(possible_gang == gang)
						converted_targets |= possible_target
	return (converted_targets.len >= target_amount)

/datum/objective/gang/one_from_all
	name = "One from all"
	var/departments
	var/is_engineering_staffed
	var/is_medical_staffed
	var/is_science_staffed
	var/is_supply_staffed
	var/converted_engineer
	var/converted_medical
	var/converted_science
	var/converted_supply

/datum/objective/gang/one_from_all/New()
	if(SSjob.get_living_engineers().len >= 1)
		departments++
		is_engineering_staffed = "Engineering."
	if(SSjob.get_living_medical().len >= 1)
		departments++
		is_medical_staffed = "Medical."
	if(SSjob.get_living_science().len >= 1)
		departments++
		is_science_staffed = "Science."
	if(SSjob.get_living_supply().len >= 1)
		departments++
		is_supply_staffed = "Supply."
	explanation_text = "Convert a member of each of the following [departments] departments. [is_engineering_staffed] [is_medical_staffed] [is_science_staffed] [is_supply_staffed]"

/datum/objective/gang/one_from_all/check_completion()
	var/datum/team/gang/gang = team
	if(is_engineering_staffed)
		for(var/datum/mind/possible_engineers in SSjob.get_living_engineers())
			var/datum/antagonist/gang/G = possible_engineers.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_engineer = TRUE
	if(is_medical_staffed)
		for(var/datum/mind/possible_medical in SSjob.get_living_medical())
			var/datum/antagonist/gang/G = possible_medical.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_medical = TRUE
	if(is_science_staffed)
		for(var/datum/mind/possible_science in SSjob.get_living_science())
			var/datum/antagonist/gang/G = possible_science.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_science = TRUE
	if(is_supply_staffed)
		for(var/datum/mind/possible_supply in SSjob.get_living_supply())
			var/datum/antagonist/gang/G = possible_supply.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_supply = TRUE
	return (converted_engineer + converted_medical + converted_science + converted_supply >= departments)

#define MAX_TIER 3
/datum/milestone // Abstract, basically a copy of objectives without actually being one.
	var/datum/team/team					//Needed to check for completions
	var/name = "generic objective" 		//Name for admin prompts
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//Not sure if needed, try replacing with check_completion
	var/milestone_type							//Used to increment milestones to next tier when completed
	var/repeatable						//Used to determine if a milestone is repeatable, and will increment
	var/tier							//Used to determine tier of milestone, and if it is no longer repeateable
	var/max_tier = MAX_TIER				//Max tier to increment to

/datum/milestone/proc/check_completion()
	return completed
/*
/datum/milestone/floortiles // Abstract
	repeatable = TRUE
	milestone_type = "floortiles"

/datum/milestone/floortiles/check_completion

/datum/milestone/floortiles/tier1/New()
	tier = 1
	target_amount = rand(10, 15)
	explanation_text = "Place [target_amount] gang floor tiles."

/datum/milestone/floortiles/tier2/New()
	tier = 2
	target_amount = rand(20, 27)
	explanation_text = "Place [target_amount] gang floor tiles."

/datum/milestone/floortiles/tier3/New()
	repeatable = 0
	tier = 3
	target_amount = rand(35, 50)
	explanation_text = "Place [target_amount] gang floor tiles."
*/
/datum/milestone/uniform
	repeatable = TRUE
	milestone_type = "uniform"

/datum/milestone/uniform/check_completion()
	var/datum/team/gang/gang = team
	return (gang.check_clothing() >= target_amount)

/datum/milestone/uniform/tier1/New()
	tier = 1
	target_amount = rand(1, 3)
	explanation_text = "Have [target_amount] gang members wearing your uniform."

/datum/milestone/uniform/tier2/New()
	tier = 2
	target_amount = rand(4, 6)
	explanation_text = "Have [target_amount] gang members wearing your uniform."

/datum/milestone/uniform/tier3/New()
	repeatable = 0
	tier = 3
	target_amount = rand(7, 12)
	explanation_text = "Have [target_amount] gang members wearing your uniform."

/datum/milestone/members
	repeatable = TRUE
	milestone_type = "members"

/datum/milestone/members/check_completion()
	var/datum/team/gang/gang = team
	return (gang.members_amount >= target_amount)

/datum/milestone/members/tier1/New()
	tier = 1
	target_amount =  3 // Should be the easiest, meant to be the first you complete to unlock 5 members
	explanation_text = "Have [target_amount] gang members in your gang."

/datum/milestone/members/tier2/New()
	tier = 2
	target_amount =  rand(7, 10)
	explanation_text = "Have [target_amount] gang members in your gang."

/datum/milestone/members/tier3/New()
	repeatable = 0
	tier = 3
	target_amount =  rand(13, 16)
	explanation_text = "Have [target_amount] gang members in your gang."

/datum/milestone/money
	repeatable = TRUE
	milestone_type = "money"

/datum/milestone/money/check_completion()
	var/datum/team/gang/gang = team
	return (gang.registered_account.has_money(target_amount))

/datum/milestone/money/tier1/New()
	tier = 1
	target_amount =  rand(2000, 5000)
	explanation_text = "Have [target_amount] credits in your gang's bank account."

/datum/milestone/money/tier2/New()
	tier = 2
	target_amount =  rand(7000, 10000)
	explanation_text = "Have [target_amount] credits in your gang's bank account."

/datum/milestone/money/tier3/New()
	repeatable = 0
	tier = 3
	target_amount =  rand(17000, 26000)
	explanation_text = "Have [target_amount] credits in your gang's bank account."

/datum/milestone/control
	repeatable = TRUE
	milestone_type = "control"

/datum/milestone/control/check_completion()
	var/datum/team/gang/gang = team
	if(!(gang.territories.len >= target_amount))
		return FALSE
	return TRUE

/datum/milestone/control/tier1/New()
	tier = 1
	target_amount =  rand(4, 7)
	explanation_text = "Have [target_amount] areas of the station controlled by your gang."

/datum/milestone/control/tier2/New()
	tier = 2
	target_amount =  rand(10, 13)
	explanation_text = "Have [target_amount] areas of the station controlled by your gang."

/datum/milestone/control/tier3/New()
	repeatable = 0
	tier = 3
	target_amount =  rand(15, 20)
	explanation_text = "Have [target_amount] areas of the station controlled by your gang."

/datum/milestone/vip
	var/target_role_type = FALSE
	var/list/datum/mind/officers
	var/list/datum/mind/heads
	var/blacklist = list()
	var/list/possible_targets = list()			
	var/datum/mind/target

/datum/milestone/vip/average_joe/New()
	officers = SSjob.get_living_sec()
	heads = SSjob.get_living_heads()
	find_average_joe()
	explanation_text = "Convert [target], the [target.assigned_role], to your gang."

/datum/milestone/vip/average_joe/proc/find_average_joe()
	blacklist += officers
	blacklist += heads
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (!(possible_target.special_role == ROLE_GANG)))
			if(!(possible_target in blacklist))
				possible_targets += possible_target
	if(!possible_targets.len) // DEBUG_TEXT
		explanation_text = "this failed."
	target = pick(possible_targets)
	explanation_text = "Convert [target.name], the [target.assigned_role], to your gang."

/datum/milestone/vip/average_joe/check_completion()
	var/datum/team/gang/gang = team
	for(var/datum/antagonist/gang/G in target.antag_datums)
		var/datum/team/gang/possible_gang = G.get_team()
		return (possible_gang == gang)

/datum/milestone/proc/get_crewmember_minds()
	. = list()
	for(var/V in GLOB.data_core.locked)
		var/datum/data/record/R = V
		var/datum/mind/M = R.fields["mindref"]
		if(M)
			. += M


/datum/milestone/one_from_all
	name = "One from all"
	var/departments
	var/is_engineering_staffed
	var/is_medical_staffed
	var/is_science_staffed
	var/is_supply_staffed
	var/converted_engineer
	var/converted_medical
	var/converted_science
	var/converted_supply

/datum/milestone/one_from_all/New()
	if(SSjob.get_living_engineers().len >= 1)
		departments++
		is_engineering_staffed = "Engineering."
	if(SSjob.get_living_medical().len >= 1)
		departments++
		is_medical_staffed = "Medical."
	if(SSjob.get_living_science().len >= 1)
		departments++
		is_science_staffed = "Science."
	if(SSjob.get_living_supply().len >= 1)
		departments++
		is_supply_staffed = "Supply."
	explanation_text = "Convert a member of each of the following [departments] departments. [is_engineering_staffed] [is_medical_staffed] [is_science_staffed] [is_supply_staffed]"

/datum/milestone/one_from_all/check_completion()
	var/datum/team/gang/gang = team
	if(is_engineering_staffed)
		for(var/datum/mind/possible_engineers in SSjob.get_living_engineers())
			var/datum/antagonist/gang/G = possible_engineers.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_engineer = 1
	if(is_medical_staffed)
		for(var/datum/mind/possible_medical in SSjob.get_living_medical())
			var/datum/antagonist/gang/G = possible_medical.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_medical = 1
	if(is_science_staffed)
		for(var/datum/mind/possible_science in SSjob.get_living_science())
			var/datum/antagonist/gang/G = possible_science.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_science = 1
	if(is_supply_staffed)
		for(var/datum/mind/possible_supply in SSjob.get_living_supply())
			var/datum/antagonist/gang/G = possible_supply.has_antag_datum(/datum/antagonist/gang)
			if(G)
				var/datum/team/gang/possible_gang = G.get_team()
				if(possible_gang == gang)
					converted_supply = 1
	return (converted_engineer + converted_medical + converted_science + converted_supply >= departments)