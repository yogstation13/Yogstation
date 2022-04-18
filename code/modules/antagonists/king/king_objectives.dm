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
			if(!servantdatum.master = kingdatum)
				return
			var/datum/mind/M = servantdatum.owner
			if(considered_alive(M))
				counter++
		return counter >= target_amount




	return FALSE
