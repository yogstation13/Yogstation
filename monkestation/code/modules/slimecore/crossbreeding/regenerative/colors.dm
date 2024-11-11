/datum/status_effect/regenerative_extract/purple
	base_healing_amt = 10
	diminishing_multiplier = 0.5
	diminish_time = 1.5 MINUTES
	extra_traits = list(TRAIT_NOCRITOVERLAY, TRAIT_NOSOFTCRIT)

/datum/status_effect/regenerative_extract/purple/on_remove()
	. = ..()
	if(owner.has_dna()?.species?.reagent_tag & PROCESS_ORGANIC) // won't work during cooldown, and won't waste effort injecting into IPCs
		var/inject_amt = round(10 * multiplier)
		if(inject_amt >= 1)
			owner.reagents?.add_reagent(/datum/reagent/medicine/regen_jelly, inject_amt)


/datum/status_effect/regenerative_extract/silver
	base_healing_amt = 4
	nutrition_heal_cap = NUTRITION_LEVEL_WELL_FED + 50
	diminishing_multiplier = 0.8
	diminish_time = 30 SECONDS
	extra_traits = list(TRAIT_NOFAT)

/datum/status_effect/regenerative_extract/yellow
	extra_traits = list(TRAIT_SHOCKIMMUNE, TRAIT_TESLA_SHOCKIMMUNE, TRAIT_AIRLOCK_SHOCKIMMUNE)

/datum/status_effect/regenerative_extract/adamantine
	extra_traits = list(TRAIT_FEARLESS, TRAIT_HARDLY_WOUNDED)

// rainbow extracts are similar to old regen extract effects, albeit it won't replace your organs, and won't heal limbs
/datum/status_effect/regenerative_extract/rainbow
	duration = 30 SECONDS
	base_healing_amt = 15
	diminishing_multiplier = 1
	diminish_time = 1.5 MINUTES
	extra_traits = list(TRAIT_NOCRITOVERLAY, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT)
	pain_amount = 80 //wow having my wounds closed up in seconds really fucking HURTS

