/datum/select_equipment/ui_act(action, params)
	. = ..()
	if (!.)
		return
	if (action != "applyoutfit")
		return

	var/mob/living/target_mob_living = user.mob

	for(var/datum/quirk/quirk as anything in target_mob_living.quirks)
		target_mob_living.remove_quirk(quirk.type)
	switch(params["applyQuirks"])
		if("All Quirks")
			SSquirks.AssignQuirks(target_mob_living, user)
		if("Positive Quirks Only")
			SSquirks.AssignQuirks(target_mob_living, user, omit_negatives = TRUE)
		if("Negative Quirks Only")
			SSquirks.AssignQuirks(target_mob_living, user, omit_positives = TRUE)
		if("Neutral Quirks Only")
			SSquirks.AssignQuirks(target_mob_living, user, omit_positives = TRUE, omit_negatives = TRUE)

	if(params["holyEffect"])
		new /obj/effect/holy(target_mob_living.loc)
