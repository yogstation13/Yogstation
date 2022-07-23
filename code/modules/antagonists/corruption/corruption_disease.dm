/datum/disease/corruption
	name = "Corruption"
	max_stages = 5
	spread_text = "Touch"
	spread_flags = DISEASE_SPREAD_CONTACT_SKIN
	cure_text = "The Manly Dorf"
	cures = list(/datum/reagent/water/holywater)
	cure_chance = 90
	agent = "???"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A strange disease, that makes people decay alive and forces them to act harmfull to not diseased people."
	severity = DISEASE_SEVERITY_HARMFUL
	required_organs = list(/obj/item/bodypart/head)
	var/corrupted = FALSE
	var/mob/living/corruption_avatar


/datum/disease/corruption/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel darkness spread through your mind."))
			if(prob(8))
				to_chat(affected_mob, span_danger("You feel your flesh decaying!")) //Fake fealings
				affected_mob.emote("scream")
		if(3)
			if(prob(4))
				to_chat(affected_mob, span_danger("You feel your flesh decaying!"))
				affected_mob.emote("scream")
				if(affected_mob.get_damage_amount(CLONE) > 25)	
					adjustCloneLoss(2)		
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel darkness spread through your mind."))
			if(prob(5))
				affected_mob.vomit(20)			
		if(4)
			if(prob(4))
				to_chat(affected_mob, span_danger("You feel your flesh decaying!"))
				affected_mob.emote("scream")
				if(affected_mob.get_damage_amount(CLONE) > 35)	
					adjustCloneLoss(3)		
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel... not the same."))
				affected_mob.Dizzy(5)
			if(prob(5))
				affected_mob.vomit(20)					
		if(5)
			if(!corrupted || affected_mob.mind)
				corrupted = TRUE
				var/datum/antagonist/corrupted/C = new
				C.corruption_avatar = corruption_avatar
				affected_mob.mind.add_antag_datum(C)
				affected_mob.become_husk()
				affected_mob.emote("scream")
				affected_mob.vomit(30)	
				affected_mob.Dizzy(10)
			if(prob(4))                              ///Funny diseased dudes
				if(affected_mob.get_damage_amount(CLONE) > 35)	
					adjustCloneLoss(3)		
			if(prob(10))
				affected_mob.Dizzy(5)
			if(prob(5))
				affected_mob.vomit(10)			

	return

/datum/disease/corruption/cure(add_resistance)
	affected_mob.cure_husk()
	affected_mob.remove_antag_datum(/datum/antagonist/corrupted)
	. = ..()