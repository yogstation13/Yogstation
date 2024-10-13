/datum/symptom/bones
	name = "Fragile Person Syndrome"
	desc = "Attacks the infected's body structure, making it more fragile."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/bones/activate(mob/living/carbon/human/victim)
	if(!ishuman(victim))
		return
	for(var/obj/item/bodypart/part in victim.bodyparts)
		part.wound_resistance -= 10

/datum/symptom/bones/deactivate(mob/living/carbon/human/victim)
	if(!ishuman(victim))
		return
	for(var/obj/item/bodypart/part in victim.bodyparts)
		part.wound_resistance += 10
