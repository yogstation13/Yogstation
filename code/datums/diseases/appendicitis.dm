/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 4
	spread_text = "Non-Contagious" //Yogs
	cure_text = "Surgery"
	agent = "Shitty Appendix"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will gradually worsen, until they die."
	severity = DISEASE_SEVERITY_MEDIUM
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/appendix)
	bypasses_immunity = TRUE // Immunity is based on not having an appendix; this isn't a virus

/datum/disease/appendicitis/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/appendix/A = affected_mob.getorgan(/obj/item/organ/appendix)
			if(A)
				A.inflamed = 1
				A.update_appearance(UPDATE_ICON)
			if(prob(5))
				to_chat(affected_mob, span_warning("You feel a stabbing pain in your abdomen!"))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 5)
				affected_mob.Stun(rand(40,60))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(35))
				affected_mob.adjustToxLoss(1)
			if(prob(10))
				affected_mob.emote("cough")
			if(prob(10))
				to_chat(affected_mob, span_warning("You feel a stabbing pain in your abdomen!"))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 5)
				affected_mob.Stun(rand(40,60))
			if(prob(5))
				affected_mob.vomit(95)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 15)
		if(4)
			if(prob(40))
				to_chat(affected_mob, span_warning("You double over in pain!"))
				affected_mob.Knockdown(rand(40,60))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 20)
				affected_mob.adjustBruteLoss(5)
				affected_mob.adjustToxLoss(10)
			if(prob(25))
				affected_mob.emote("groan")
				affected_mob.vomit(100)
			if(prob(25))
				affected_mob.emote("cough")
				affected_mob.bleed(20)
			if(prob(10))
				to_chat(affected_mob, span_warning("You feel your appendix burst!"))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 100)
				affected_mob.adjustBruteLoss(100)
				affected_mob.adjustToxLoss(100)
				affected_mob.Knockdown(60)
