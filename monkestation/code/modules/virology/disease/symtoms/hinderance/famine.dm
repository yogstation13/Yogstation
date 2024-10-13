/datum/symptom/famine
	name = "Faminous Potation"
	desc = "The infected emanates a field that kills off plantlife. Lethal to species descended from plants."
	stage = 2
	max_multiplier = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/famine/activate(mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/victim = mob
		if(ispodperson(victim)) //Plantmen take a LOT of damage
			victim.adjustToxLoss(5 * multiplier)

	for(var/obj/item/food/grown/crop in range(2 * multiplier,mob))
		crop.visible_message(span_warning("\The [crop] rots at an alarming rate!"))
		new /obj/item/food/badrecipe(get_turf(crop))
		qdel(crop)
		if(prob(30 / multiplier))
			break
