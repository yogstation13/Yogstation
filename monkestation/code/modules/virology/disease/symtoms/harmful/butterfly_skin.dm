/datum/symptom/butterfly_skin
	name = "Epidermolysis Bullosa"
	desc = "Inhibits the strength of the infected's skin, causing it to tear on contact."
	stage = 3
	max_count = 1
	badness = EFFECT_DANGER_HARMFUL
	var/skip = FALSE

/datum/symptom/butterfly_skin/activate(mob/living/carbon/mob)
	to_chat(mob, span_warning("Your skin feels a little fragile."))

/datum/symptom/butterfly_skin/deactivate(mob/living/carbon/mob)
	if(!skip)
		to_chat(mob, span_notice("Your skin feels nice and durable again!"))
	..()

/datum/symptom/butterfly_skin/on_touch(mob/living/carbon/mob, toucher, touched, touch_type)
	if(count && !skip)
		var/obj/item/bodypart/part
		if(ishuman(mob))
			var/mob/living/carbon/human/victim = mob
			part = victim.get_bodypart(victim.get_random_valid_zone())
		if(toucher == mob)
			if(part)
				to_chat(mob, span_warning("As you bump into \the [touched], some of the skin on your [part] shears off!"))
				part.take_damage(10)
			else
				to_chat(mob, span_warning("As you bump into \the [touched], some of your skin shears off!"))
				mob.adjustBruteLoss(10)
		else
			if(part)
				to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, some of the skin on your [part] shears off!"))
				to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], some of the skin on \his [part] shears off!"))
				part.take_damage(10)
			else
				to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, some of your skin shears off!"))
				to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], some of \his skin shears off!"))
				mob.adjustBruteLoss(10)
