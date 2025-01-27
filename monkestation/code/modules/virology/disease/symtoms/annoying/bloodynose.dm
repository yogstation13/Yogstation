/datum/symptom/bloodynose
	name = "Intranasal Hemorrhage"
	desc = "Causes the infected's nasal pathways to hemorrhage, causing a nosebleed, potentially carrying the pathogen."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	severity = 2

/datum/symptom/bloodynose/activate(mob/living/mob)
	if (prob(30))
		if (ishuman(mob))
			var/mob/living/carbon/human/victim = mob
			if (!(TRAIT_NOBLOOD in victim.dna.species.inherent_traits))
				victim.add_splatter_floor(get_turf(mob), 1)
		else
			var/obj/effect/decal/cleanable/blood/blood= locate(/obj/effect/decal/cleanable/blood) in get_turf(mob)
			if(blood==null)
				blood = new /obj/effect/decal/cleanable/blood(get_turf(mob))
			blood.diseases |= virus_copylist(mob.diseases)
