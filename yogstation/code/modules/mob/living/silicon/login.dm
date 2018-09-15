/mob/living/silicon/Login()
	if(mind)
		mind.remove_antag_datum(/datum/antagonist/gang)
	. = ..()
