/datum/symptom/polyvitiligo
	name = "Chroma Imbalance"
	desc = "The virus replaces the melanin in the skin with reactive pigment."
	stage = 3
	max_multiplier = 6
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/polyvitiligo/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return
	switch(round(multiplier, 1))
		if(5)
			var/static/list/banned_reagents = list(/datum/reagent/colorful_reagent/powder/invisible, /datum/reagent/colorful_reagent/powder/white)
			var/color = pick(subtypesof(/datum/reagent/colorful_reagent/powder) - banned_reagents)
			if(mob.reagents.total_volume <= (mob.reagents.maximum_volume/10)) // no flooding humans with 1000 units of colorful reagent
				mob.reagents.add_reagent(color, 5 * multiplier)
		else
			if (prob(50)) // spam
				mob.visible_message(span_warning("[mob] looks rather vibrant..."), span_notice("The colors, man, the colors..."))
