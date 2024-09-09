// These chems are related to painkillers tangentially

// Component in ibuprofen.
/datum/reagent/propionic_acid
	name = "Propionic Acid"
	description = "A pungent liquid that's often used in preservatives and synthesizing of other chemicals."
	reagent_state = LIQUID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#c7a9c9"
	ph = 7

// Diphenhydramine can be upgraded into Dimenhydrinate, less good against allergens but better against nausea
/datum/reagent/medicine/dimenhydrinate
	name = "Dimenhydrinate"
	description = "Helps combat nausea and motion sickness."
	reagent_state = LIQUID
	color = "#98ffee"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 10.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/dimenhydrinate/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	M.adjust_disgust(-8 * REM * seconds_per_tick)
	if(M.nutrition > NUTRITION_LEVEL_FULL - 25) // Boosts hunger to a bit, assuming you've been vomiting
		M.adjust_nutrition(2 * HUNGER_FACTOR * REM * seconds_per_tick)

/datum/chemical_reaction/medicine/dimenhydrinate
	results = list(/datum/reagent/medicine/dimenhydrinate = 3)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/nitrogen = 1, /datum/reagent/chlorine = 1)
	optimal_ph_max = 12.5
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

// Good against nausea, easier to make than Dimenhydrinate
/datum/reagent/medicine/ondansetron
	name = "Ondansetron"
	description = "Prevents nausea and vomiting."
	reagent_state = LIQUID
	color = "#74d3ff"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 10.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/ondansetron/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(8, seconds_per_tick))
		M.adjust_drowsiness(2 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(15, seconds_per_tick) && M.get_bodypart_pain(BODY_ZONE_HEAD) <= PAIN_HEAD_MAX / 4)
		M.cause_pain(BODY_ZONE_HEAD, 4)
	M.adjust_disgust(-10 * REM * seconds_per_tick)
