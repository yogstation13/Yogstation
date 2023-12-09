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
				to_chat(affected_mob, span_danger("Your muscles feel tired."))
				if(prob(20))
					affected_mob.adjustStaminaLoss(5)
			if(prob(5))
				to_chat(affected_mob, span_danger("A nap would be good right about now."))
				if(prob(10))
					affected_mob.adjustStaminaLoss(3)
			if(prob(3))
				to_chat(affected_mob, span_danger("You feel numb."))
				if(prob(20))
					affected_mob.adjustStaminaLoss(8)

		if(3)
			if(prob(8))
				affected_mob.emote("yawn")
			if(prob(3))
				to_chat(affected_mob, span_danger("Your muscles feel very weak."))
				affected_mob.adjustStaminaLoss(10)
			if(prob(2))
				to_chat(affected_mob, span_danger("Your legs buckle beneath you."))
				affected_mob.Knockdown(40)
			if(prob(3))
				to_chat(affected_mob, span_danger("You close your eyes... just for a moment."))
				affected_mob.blind_eyes(6)
			if(prob(3))
				to_chat(affected_mob, span_danger("Your legs feel weak."))
				affected_mob.set_confusion_if_lower(4 SECONDS)
				affected_mob.adjustStaminaLoss(10)
			if(prob(3))
				to_chat(affected_mob, span_danger("Your eyes feel strained."))
				affected_mob.adjust_eye_blur(6)
			if(prob(3))
				to_chat(affected_mob, span_warning("[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]"))
				affected_mob.adjust_eye_blur(6)
				affected_mob.set_confusion_if_lower(4 SECONDS)
				affected_mob.adjustStaminaLoss(15)
				if(prob(5))
					to_chat(affected_mob, span_danger("Just a little nap..."))
					affected_mob.SetSleeping(80)
	return
