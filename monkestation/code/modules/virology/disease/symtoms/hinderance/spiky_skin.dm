/datum/symptom/spiky_skin
	name = "Porokeratosis Acanthus"
	desc = "Causes the infected to generate keratin spines along their skin."
	stage = 2
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE
	var/skip = FALSE
	multiplier = 4
	max_multiplier = 8

/datum/symptom/spiky_skin/activate(mob/living/mob, multiplier)
	to_chat(mob, span_warning("Your skin feels a little prickly."))

/datum/symptom/spiky_skin/deactivate(mob/living/mob)
	if(!skip)
		to_chat(mob, span_notice("Your skin feels nice and smooth again!"))
	..()

/datum/symptom/spiky_skin/on_touch(mob/living/mob, mob/living/toucher, mob/living/touched, touch_type)
	if(!count || skip)
		return
	if(!istype(toucher) || !istype(touched))
		return
	var/obj/item/bodypart/bodypartTarget
	var/mob/living/carbon/human/target
	if(toucher == mob)	//we bumped into someone else
		if(ishuman(touched))
			target = touched
			bodypartTarget = target.get_bodypart(target.get_random_valid_zone())
	else	//someone else bumped into us
		if(ishuman(toucher))
			target = toucher
			bodypartTarget = target.get_bodypart(target.get_random_valid_zone())

	if(toucher == mob)
		if(bodypartTarget)
			to_chat(mob, span_warning("As you bump into \the [touched], your spines dig into \his [bodypartTarget]!"))
			bodypartTarget.take_damage(multiplier, BRUTE)
		else
			to_chat(mob, span_warning("As you bump into \the [touched], your spines dig into \him!"))
			var/mob/living/impaled = touched
			if(istype(impaled) && !istype(impaled, /mob/living/silicon))
				impaled.apply_damage(multiplier, BRUTE, bodypartTarget)
	else
		if(bodypartTarget)
			to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, your spines dig into \his [bodypartTarget]!"))
			to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into your [bodypartTarget]!"))
			bodypartTarget.take_damage(multiplier)
		else
			to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, your spines dig into \him!"))
			to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into you!"))
			var/mob/living/victim = toucher
			if(istype(victim) && !istype(victim, /mob/living/silicon))
				victim.apply_damage(multiplier)
	var/mob/attacker = touched
	log_attack("[attacker] damaged [target] with keratin spikes")
