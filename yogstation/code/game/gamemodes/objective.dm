/datum/objective/assassinate/internal/check_completion()
	return !considered_alive(target)

//Darkspawn objective
/datum/objective/darkspawn
	explanation_text = "Become lucid and perform the Sacrament."

/datum/objective/darkspawn/check_completion()
	return istype(owner.current, /mob/living/simple_animal/hostile/darkspawn_progenitor)