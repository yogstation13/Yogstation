/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "If left untreated subject will regurgitate butterflies."
	severity = DISEASE_SEVERITY_MINOR

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You feel anxious.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Your stomach flutters.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You feel panicky.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You're overtaken with panic!</span>")
				affected_mob.confused += (rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel butterflies in your stomach.</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] stumbles around in a panic.</span>", \
												"<span class='userdanger'>You have a panic attack!</span>")
				affected_mob.confused += (rand(6,8))
				affected_mob.jitteriness += (rand(6,8))
			if(prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up butterflies!</span>", \
													"<span class='userdanger'>You cough up butterflies!</span>")
				//Yogs start -- Puts a maximum on the number of butterflies that can be spawned via this disease
				var/mob/living/simple_animal/butterfly/Alpha = new(affected_mob.loc)
				var/mob/living/simple_animal/butterfly/Beta = new(affected_mob.loc)
				butterfly_count += list(Alpha,Beta)
				if(butterfly_count.len > 250)
					for(var/i in butterfly_count)
						var/mob/living/simple_animal/butterfly/Butt = butterfly_count[i]
						if(!Butt || Butt.stat == DEAD) // If this butterfly no longer exists or is dead
							butterfly_count.Cut(i,i+1)
							qdel(Butt)
							if(butterfly_count.len < 250)
								break
				//Yogs end
	return