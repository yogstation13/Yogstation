/datum/symptom/retrovirus
	name = "Retrovirus"
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	max_multiplier = 4
	stage = 4
	badness = EFFECT_DANGER_HARMFUL
	severity = 3

/datum/symptom/retrovirus/activate(mob/living/carbon/affected_mob)
	if(!iscarbon(affected_mob))
		return
	switch(multiplier)
		if(1)
			if(prob(4))
				to_chat(affected_mob, span_danger("Your head hurts."))
			if(prob(4.5))
				to_chat(affected_mob, span_danger("You feel a tingling sensation in your chest."))
			if(prob(4.5))
				to_chat(affected_mob, span_danger("You feel angry."))
		if(2)
			if(prob(4))
				to_chat(affected_mob, span_danger("Your skin feels loose."))
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel very strange."))
			if(prob(2))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head!"))
				affected_mob.Unconscious(40)
			if(prob(2))
				to_chat(affected_mob, span_danger("Your stomach churns."))
		if(3)
			if(prob(5))
				to_chat(affected_mob, span_danger("Your entire body vibrates."))
			if(prob(19))
				switch(rand(1,3))
					if(1)
						scramble_dna(affected_mob, 1, 0, 0, rand(15,45))
					if(2)
						scramble_dna(affected_mob, 0, 1, 0, rand(15,45))
					if(3)
						scramble_dna(affected_mob, 0, 0, 1, rand(15,45))
		if(4)
			if(prob(37))
				switch(rand(1,3))
					if(1)
						scramble_dna(affected_mob, 1, 0, 0, rand(50,75))
					if(2)
						scramble_dna(affected_mob, 0, 1, 0, rand(50,75))
					if(3)
						scramble_dna(affected_mob, 0, 0, 1, rand(50,75))
