/// Language holder for borers, that let them understand any language their host understands.
/datum/language_holder/borer

/datum/language_holder/borer/has_language(language, spoken = FALSE)
	. = ..()
	if(.)
		return
	var/mob/living/basic/cortical_borer/cortical_owner = get_atom()
	if(istype(cortical_owner))
		return cortical_owner.human_host?.get_language_holder()?.has_language(language, spoken)
