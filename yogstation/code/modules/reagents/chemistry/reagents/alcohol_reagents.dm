/datum/reagent/consumable/ethanol/catsip
	name = "Catsip"
	description = "A kawaii drink from space-Japan."
	color ="#ff99ac"
	boozepwr = 50
	quality = DRINK_NICE
	taste_description = "degeneracy"
	glass_icon_state = "catsip"
	glass_name = "Catsip"
	glass_desc = "Unfortunately has a tendency to induce the peculiar vocal tics of a wapanese mutant in the imbiber."

/datum/reagent/consumable/ethanol/catsip/on_mob_life(mob/living/M)
	if(prob(8))
		M.say(pick("Nya.", "N-nya!", "NYA!"), forced = "catsip")
	return ..()

/datum/reagent/consumable/ethanol/catsip/on_mob_add(mob/living/carbon/human/M)
	if(!M.dna.species.is_wagging_tail())
		M.emote("wag")
	return ..()
