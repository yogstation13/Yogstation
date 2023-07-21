/datum/disease/cluwnification
	name = "Anomalous Clown Retrovirus"
	form = "Infection"
	max_stages = 5
	stage_prob = 2
	cure_text = "A small mix of nothing" // heh
	cures = list(/datum/reagent/consumable/nothing)
	agent = "Fury from the circus of hell itself."
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Subject will become dizzy, confused and steadily more retarded before being turned into a cluwne!"
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE

/datum/disease/cluwnification/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(2))
				to_chat(affected_mob, span_danger("You feel a little silly."))
			if(prob(2))
				to_chat(affected_mob, span_danger("Your head feels funny."))
		if(2)
			if(prob(2))
				to_chat(affected_mob, span_danger("You hear honking."))
				playsound(affected_mob, 'sound/items/bikehorn.ogg', 30, FALSE)
			if(prob(2))
				to_chat(affected_mob, span_danger("Your head starts to spin."))
				affected_mob.adjust_confusion(5 SECONDS)

		if(3)
			if(prob(5))
				to_chat(affected_mob, span_danger("Your mind starts to slip."))
				affected_mob.set_drugginess(5)
			if(prob(2))
				to_chat(affected_mob, span_danger("Your can feel your brain startng to break down."))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
				affected_mob.updatehealth()
			if(prob(5))
				to_chat(affected_mob, span_danger("Your head starts to spin."))
				affected_mob.adjust_confusion(5 SECONDS)
		if(4)
			if(prob(10))
				to_chat(affected_mob, span_danger("OH GOD THE HONKING!!"))
				playsound(affected_mob, 'sound/items/bikehorn.ogg', 50, FALSE)
			if(prob(10))
				to_chat(affected_mob, span_danger("Your brain feels like its being ripped apart."))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
				affected_mob.updatehealth()
			if(prob(15))
				affected_mob.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ) )
			if(prob(10))
				to_chat(affected_mob, span_danger("You fail to form any kind of coherent thought"))
				affected_mob.set_drugginess(10)
				affected_mob.adjust_confusion(10 SECONDS)
		if(5)
			if(prob(30))
				if (!(affected_mob.dna.check_mutation(CLUWNEMUT)))
					to_chat(affected_mob, span_userdanger("IT HURTS!!"))
					var/mob/living/carbon/human/H = affected_mob
					H.cluwneify()
