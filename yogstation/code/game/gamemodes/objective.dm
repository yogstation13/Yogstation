/datum/objective/assassinate/internal/check_completion()
	return !considered_alive(target)

/datum/objective/escape/assumed_identity
	name = "escape with assumed identity"
	explanation_text = "Escape on the shuttle or an escape pod alive under an assumed name."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody, under an assumed name."


/datum/objective/escape/escape_with_identity/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!ishuman(M.current) || !considered_escaped(M))
			continue
		var/mob/living/carbon/human/H = M.current
		if(H.name != H.dna.real_name && H.name != "Unknown")
			return TRUE
	return FALSE
