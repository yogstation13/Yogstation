/datum/disease/jitters
	name = "The jitters"
	max_stages = 3
	stage_prob = 3
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_CONTACT_SKIN
	cure_text = "Morphine"
	cures = list(/datum/reagent/medicine/morphine)
	agent = "Extreme leg spasm syndrome"
	viable_mobtypes = list(/mob/living/carbon/human)
	severity = DISEASE_SEVERITY_MEDIUM
	desc = "This virus stimulates leg muscles and causes sudden spasms that will force the subject to jump forward."

/datum/disease/jitters/stage_act()
	..()
	var/atom/target = get_edge_target_turf(affected_mob, affected_mob.dir)
	switch(stage)
		if(1)
			if(prob(10))
				affected_mob.adjust_jitter(2 SECONDS)
		if(2)
			if(prob(20))
				affected_mob.adjust_jitter(2 SECONDS)
			if(prob(10))
				to_chat(affected_mob, span_notice("You feel ants in your legs."))
		if(3)
			if(prob(40))
				affected_mob.adjust_jitter(2 SECONDS)
			if(prob(20))
				to_chat(affected_mob, span_danger("You feel a million pricks on your legs!"))
			if((affected_mob.mobility_flags & MOBILITY_MOVE) && prob(15))
				affected_mob.throw_at(target, 4, 3, spin = FALSE, diagonals_first = TRUE)
				playsound(affected_mob, 'sound/weapons/fwoosh.ogg', 50, 1, 1)
				affected_mob.visible_message(span_warning("[affected_mob] uncontrollably leaps forward!"))
