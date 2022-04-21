/datum/objective/assassinate/kingtoking
	name = "False king"
	martyr_compatible = 1

/datum/objective/assassinate/kingtoking/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the False King!."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/kingtoking/find_target_by_role(role, role_type=ROLE_KING,invert=FALSE)
	. = ..()

/datum/objective/hijack/king
	explanation_text = "Hijack the shuttle to ensure no enemy peasants escape alive and out of custody."

/datum/objective/leadership
	name = "Leadership"
	explanation_text = "Have at least 10 loyal servants at once."
	martyr_compatible = 0


/datum/objective/leadership/proc/gen_amount_goal()
	target_amount = rand(10,20)
	update_explanation_text()
	return target_amount



/datum/objective/leadership/update_explanation_text()
	..()
	explanation_text = "Have at least [target_amount] loyal servants at once."



/datum/objective/leadership/check_completion()
	var/counter = 0
	var/datum/antagonist/king/kingdatum = owner.has_antag_datum(/datum/antagonist/king)
	if (kingdatum && kingdatum.servants)
		for (var/datum/antagonist/servant/servantdatum in kingdatum.servants)
			if(!servantdatum.master == kingdatum)
				return
			var/datum/mind/M = servantdatum.owner
			if(considered_alive(M))
				counter++
		return counter >= target_amount
	return FALSE






/datum/objective/royalguard
	name = "Royal guard"
	explanation_text = "Have at least 3 knights serving you at once."
	martyr_compatible = 1


/datum/objective/royalguard/proc/gen_amount_goal()
	target_amount = rand(3,5)
	update_explanation_text()
	return target_amount



/datum/objective/royalguard/update_explanation_text()
	..()
	explanation_text = "Have at least [target_amount] knights serving you at once."

/datum/objective/royalguard/check_completion()
	var/counter = 0
	var/datum/antagonist/king/kingdatum = owner.has_antag_datum(/datum/antagonist/king)
	if (kingdatum && kingdatum.servants)
		for (var/datum/antagonist/servant/servantdatum in kingdatum.servants)
			if(servantdatum.owner.has_antag_datum(/datum/antagonist/servant/knight))
				if(!servantdatum.master == kingdatum)
					return
				var/datum/mind/M = servantdatum.owner
				if(considered_alive(M))
					counter++
		return counter >= target_amount
	return FALSE

/datum/objective/empire
	name = "Empire"
	explanation_text = "Have at least 3 flags captured by you at once."
	martyr_compatible = 0

/datum/objective/empire/proc/gen_amount_goal()
	target_amount = rand(3,6)
	update_explanation_text()
	return target_amount

/datum/objective/empire/update_explanation_text()
	..()
	explanation_text = "Have at least [target_amount] flags captured by you at once."


/datum/objective/assassinate/head
	name = "Assasinate a Head of Departament"
	martyr_compatible = 1

/datum/objective/assassinate/head/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role] to prove that only you deserve to rule!."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/head/find_target()
	var/list/viable_heads = list()
	var/list/other_targets = list()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind)
			continue
		if(!SSjob.GetJob(H.mind.assigned_role))
			continue
		other_targets += H.mind
		if(!H.mind.assigned_role in GLOB.command_positions)
			continue
		viable_heads += H.mind
	if(viable_heads.len > 0)//find in command positions
		target = pick(viable_heads)
	else if(other_targets.len > 0)//find someone else...
		target = pick(other_targets)
	return target




//Servant shit
/datum/objective/servetheking

/datum/objective/servetheking/update_explanation_text()
	. = ..()
	explanation_text = "Serve your King!"


/datum/objective/servetheking/check_completion()
	var/datum/antagonist/servant/antag_datum = owner.has_antag_datum(/datum/antagonist/servant)
	return antag_datum.master?.owner?.current?.stat != DEAD
