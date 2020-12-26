/datum/objective/gang  // Abstract

/datum/objective/gang/dominate
	name = "Dominate"
	explanation_text = "Take over the station by activating the Dominator device."

/datum/objective/gang/dominat/check_completion()
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
//	var/list/datum/mind/owners = get_owners()
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
	switch(department)
		if("engineering")
			for(var/datum/mind/possible_target in SSjob.get_living_engineers())
				target_amount++
				if(possible_target.has_antag_datum(/datum/antagonist/gang))
					converted_targets++
		if("science")
			for(var/datum/mind/possible_target in SSjob.get_living_science())
				target_amount++
				if(possible_target.has_antag_datum(/datum/antagonist/gang))
					converted_targets++
		if("medical")
			for(var/datum/mind/possible_target in SSjob.get_living_medical())
				target_amount++
				if(possible_target.has_antag_datum(/datum/antagonist/gang))
					converted_targets++
		if("supply")
			for(var/datum/mind/possible_target in SSjob.get_living_supply())
				target_amount++
				if(possible_target.has_antag_datum(/datum/antagonist/gang))
					converted_targets++
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
	if(is_engineering_staffed)
		for(var/datum/mind/possible_engineers in SSjob.get_living_engineers())
			if(possible_engineers.has_antag_datum(/datum/antagonist/gang))
				converted_engineer = 1
	if(is_medical_staffed)
		for(var/datum/mind/possible_medical in SSjob.get_living_medical())
			if(possible_medical.has_antag_datum(/datum/antagonist/gang))
				converted_medical = 1
	if(is_science_staffed)
		for(var/datum/mind/possible_science in SSjob.get_living_science())
			if(possible_science.has_antag_datum(/datum/antagonist/gang))
				converted_science = 1
	if(is_supply_staffed)
		for(var/datum/mind/possible_supply in SSjob.get_living_supply())
			if(possible_supply.has_antag_datum(/datum/antagonist/gang))
				converted_supply = 1
	return (converted_engineer + converted_medical + converted_science + converted_supply >= departments)

