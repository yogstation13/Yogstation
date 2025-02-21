/datum/reagent/consumable/ethanol/ratvander
	name = "Rat'vander Cocktail"
	description = "Side effects include hoarding brass and hatred of blood."
	color = LIGHT_COLOR_CLOCKWORK
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "sweet brass"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	bypass_restriction = TRUE

/datum/reagent/consumable/ethanol/ratvander/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_timed_status_effect(6 SECONDS * REM * seconds_per_tick, /datum/status_effect/speech/slurring/clock, max_duration = 6 SECONDS)
	drinker.adjust_stutter_up_to(6 SECONDS * REM * seconds_per_tick, 6 SECONDS)
	return ..()
