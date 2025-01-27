/datum/symptom/beard
	name = "Facial Hypertrichosis"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2
	max_multiplier = 5
	badness = EFFECT_DANGER_FLAVOR
	severity = 1


/datum/symptom/beard/activate(mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = mob
		if(ishuman(mob))
			var/beard_name = ""
			spawn(5 SECONDS)
				if(multiplier >= 1 && multiplier < 2)
					beard_name = "Beard (Jensen)"
				if(multiplier >= 2 && multiplier < 3)
					beard_name = "Beard (Full)"
				if(multiplier >= 3 && multiplier < 4)
					beard_name = "Beard (Very Long)"
				if(multiplier >= 4)
					beard_name = "Beard (Dwarf)"
				if(beard_name != "" && victim.facial_hairstyle != beard_name)
					victim.facial_hairstyle = beard_name
					to_chat(victim, span_warning("Your chin itches."))
					victim.update_body_parts()
