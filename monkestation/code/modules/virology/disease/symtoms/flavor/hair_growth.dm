/datum/symptom/hair
	name = "Hair Loss"
	desc = "Causes rapid hairloss in the infected."
	stage = 2
	badness = EFFECT_DANGER_FLAVOR
	severity = 1
	multiplier = 1
	max_multiplier = 5

/datum/symptom/hair/activate(mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/victim = mob
		if(victim.hairstyle != "Bald")
			if (victim.hairstyle != "Balding Hair")
				to_chat(victim, span_danger("Your hair starts to fall out in clumps..."))
				if (prob(multiplier*20))
					victim.hairstyle = "Balding Hair"
					victim.update_body_parts()
			else
				to_chat(victim, span_danger("You have almost no hair left..."))
				if (prob(multiplier*20))
					victim.hairstyle = "Bald"
					victim.update_body_parts()
