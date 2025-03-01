
/datum/symptom/rhumba_beat
	name = "The Rhumba Beat"
	desc = "Chick Chicky Boom!"
	max_multiplier = 5
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	severity = 5

/datum/symptom/rhumba_beat/activate(mob/living/carbon/affected_mob)
	if(ismouse(affected_mob))
		affected_mob.gib()
		return
	multiplier_tweak(0.1)

	switch(round(multiplier))
		if(2)
			if(prob(26))
				affected_mob.take_overall_damage(burn = 5)
			if(prob(0.5))
				to_chat(affected_mob, span_danger("You feel strange..."))
		if(3)
			if(prob(2.5))
				to_chat(affected_mob, span_danger("You feel the urge to dance..."))
			else if(prob(2.5))
				affected_mob.emote("gasp")
			else if(prob(5))
				to_chat(affected_mob, span_danger("You feel the need to chick chicky boom..."))
		if(4)
			if(prob(10))
				if(prob(50))
					affected_mob.adjust_fire_stacks(2)
					affected_mob.ignite_mob()
				else
					affected_mob.emote("gasp")
					to_chat(affected_mob, span_danger("You feel a burning beat inside..."))
		if(5)
			to_chat(affected_mob, span_danger("Your body is unable to contain the Rhumba Beat..."))
			if(prob(29))
				explosion(affected_mob, devastation_range = -1, light_impact_range = 2, flame_range = 2, flash_range = 3, adminlog = FALSE, explosion_cause = src) // This is equivalent to a lvl 1 fireball
				multiplier -= 3
