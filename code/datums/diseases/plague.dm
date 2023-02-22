/datum/disease/plague
	form = "Disease"
	name = "Plague"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "Plague rats"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 10
	desc = "A deadly disease, spread by infected animals and insects. It causes fever, weakness, headache and choking."
	required_organs = list(/obj/item/organ/lungs)
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE

/datum/disease/plague/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, span_danger("Your chest hurts."))
			if(prob(2))
				to_chat(affected_mob, span_danger("Your head pounds."))
		if(4)
			if(prob(2))
				to_chat(affected_mob, span_userdanger("You can't keep steady!"))
				affected_mob.Dizzy(5)
			if(prob(2))
				to_chat(affected_mob, span_danger("You can barely breathe!"))
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, span_danger("You can't breathe!"))
				affected_mob.adjustOxyLoss(20)
				affected_mob.emote("gasp")
			if(prob(2))
				to_chat(affected_mob, span_danger("You feel weak!"))
				affected_mob.adjustStaminaLoss(40)
		if(5)
			if(prob(10))
				affected_mob.vomit(20)
			if(prob(15))
				affected_mob.adjust_bodytemperature(30)
				to_chat(affected_mob, span_danger("You feel hot!"))
			if(prob(2))
				to_chat(affected_mob, span_danger("You feel very weak!"))
				affected_mob.adjustStaminaLoss(60)
			if(prob(6))
				to_chat(affected_mob, span_danger("Your lungs feel full of fluid! You're unable to breathe!"))
				affected_mob.adjustOxyLoss(35)
				affected_mob.emote("gasp")
	return

