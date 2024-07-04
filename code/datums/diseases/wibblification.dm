/datum/disease/wibblification
	name = "Wibblification"
	desc = "If left untreated the subject will become very wibbly."
	agent = "the weight of the universe"
	max_stages = 3
	viable_mobtypes = list(/mob/living)
	bypasses_immunity = TRUE //pick a god and pray
	severity = DISEASE_SEVERITY_BIOHAZARD
	disease_flags = CAN_CARRY
	spread_flags = DISEASE_SPREAD_CONTACT_SKIN
	infectable_biotypes = ALL_BIOTYPES
	var/previous_chat = 0

/datum/disease/wibblification/stage_act()
	..()
	if(previous_chat < stage) //only do the effect once
		previous_chat = stage
		switch(stage)
			if(2)
				to_chat(affected_mob, span_warning("You feel a little... wibbly?"))
			if(3)
				to_chat(affected_mob, span_warning("Something feels very... wibbly!"))
				apply_wibbly_filters(affected_mob)

/datum/disease/wibblification/cure(add_resistance) //this ain't happening, but if it does
	. = ..()
	if(affected_mob)
		remove_wibbly_filters(affected_mob)
