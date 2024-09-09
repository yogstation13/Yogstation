/datum/reagent/consumable/ethanol/melon_liquor
	name = "Melon Liquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	taste_description = "fruity alcohol"
	color = "#138808d0" // rgb: 19, 136, 8
	boozepwr = 30

/datum/reagent/consumable/ethanol/poison_wine
	name = "Fungal Wine"
	description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
	taste_description = "purified alcoholic death"
	color = "#000000d0"
	boozepwr = 1

/datum/reagent/consumable/ethanol/poison_wine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	drinker.adjust_hallucinations(1.5 SECONDS)
	drinker.adjust_drugginess(5 SECONDS)

	drinker.adjustToxLoss(3 * seconds_per_tick)

/datum/reagent/consumable/ethanol/candy_wine
	name = "Candy Liquor"
	description = "Made from assorted sweets, candies and even flowers."
	taste_description = "sweet and smooth alcohol"
	color = "#E33232d0" // rgb: 227, 50, 50
	boozepwr = 15
