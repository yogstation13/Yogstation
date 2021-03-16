/datum/disease/sleepy
	name = "Sleepy Virus"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 10
	agent = "SLPY Viron"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	permeability_mod = 0.75
	desc = "If left untreated the subject will feel very tired."
	severity = DISEASE_SEVERITY_NONTHREAT

/// Sleepy virus is a nonlethal and weak virus that is more of a nuisance than a threat.

/datum/disease/sleepy/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(5))
				affected_mob.emote("yawn")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your muscles feel tired.</span>")
				if(prob(20))
					affected_mob.adjustStaminaLoss(5)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>A nap would be good right about now.</span>")
				if(prob(10))
					affected_mob.adjustStaminaLoss(3)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You feel numb.</span>")
				if(prob(20))
					affected_mob.adjustStaminaLoss(8)

		if(3)
			if(prob(8))
				affected_mob.emote("yawn")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your muscles feel very weak.</span>")
				affected_mob.adjustStaminaLoss(10)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your legs buckle beneath you.</span>")
				affected_mob.Knockdown(40)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You close your eyes... just for a moment.</span>")
				affected_mob.blind_eyes(6)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your legs feel weak.</span>")
				affected_mob.confused = max(affected_mob.confused, 4)
				affected_mob.adjustStaminaLoss(10)
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your eyes feel strained.</span>")
				affected_mob.blur_eyes(6)
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'>[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]</span>")
				affected_mob.blur_eyes(6)
				affected_mob.confused = max(affected_mob.confused, 4)
				affected_mob.adjustStaminaLoss(15)
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Just a little nap...</span>")
					affected_mob.SetSleeping(80)
	return
