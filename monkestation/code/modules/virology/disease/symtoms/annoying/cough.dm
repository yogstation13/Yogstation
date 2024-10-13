/datum/symptom/cough//creates pathogenic clouds that may contain even non-airborne viruses.
	name = "Anima Syndrome"
	desc = "Causes the infected to cough rapidly, releasing pathogenic clouds."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	max_chance = 10

/datum/symptom/cough/activate(mob/living/mob)
	mob.emote("cough")
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/victim = mob
	var/datum/gas_mixture/breath
	breath = victim.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		if(!victim.wear_mask)
			if(isturf(mob.loc))
				var/list/blockers = list()
				blockers = list(victim.wear_mask,victim.glasses,victim.head)
				for (var/item in blockers)
					var/obj/item/clothing/clothes = item
					if (!istype(clothes))
						continue
					if (clothes.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
						return
				if(mob.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/virus  as anything in mob.diseases)
					strength += virus.infectionchance
				strength = round(strength/mob.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), mob, virus_copylist(mob.diseases))
					strength -= 30
					i++
