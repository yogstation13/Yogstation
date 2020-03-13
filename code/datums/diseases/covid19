/datum/disease/coronavirus
	name = "Coronavirus"
	max_stages = 3
	spread_text = "Airborne"
  spread_flags = DISEASE_SPREAD_AIRBORNE | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_BLOOD
	cure_text = "Felinid Mutation Toxin"
	cures = list(/datum/reagent/mutationtoxin/felinid) //specific cure recommended by Monster860 due to no known current coronavirus cure
	cure_chance = 10
	agent = "SARS-CoV-2 COVID-19"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Ancient form of coronavirus. If left untreated, the subject will feel quite unwell."
	severity = DISEASE_SEVERITY_MEDIUM

/datum/disease/coronavirus/stage_act()
	..()
	switch(stage)
		if(2)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()

		if(3)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(15))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
	return
