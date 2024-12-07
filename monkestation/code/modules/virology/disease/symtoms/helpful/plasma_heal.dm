/// Determines the rate at which Plasma Fixation heals based on the amount of plasma in the air
#define HEALING_PER_MOL 1.1
/// Determines the rate at which Plasma Fixation heals based on the amount of plasma being breathed through internals
#define HEALING_PER_BREATH_PRESSURE 0.05
/// Determines the highest amount you can be healed for when breathing plasma from internals
#define MAX_HEAL_COEFFICIENT_INTERNALS 0.75
/// Determines the highest amount you can be healed for from pulling plasma from the environment
#define MAX_HEAL_COEFFICIENT_ENVIRONMENT 0.5
/// Determines the highest amount you can be healed for when there is plasma in the bloodstream
#define MAX_HEAL_COEFFICIENT_BLOODSTREAM 0.75
/// This is the base heal amount before being multiplied by the healing coefficients
#define BASE_HEAL_PLASMA_FIXATION 4

/datum/symptom/plasma_heal
	name = "Plasma Fixation"
	desc = "The virus draws plasma from the atmosphere and from inside the body to heal and stabilize body temperature."

	stage = 1
	max_multiplier = 5
	max_chance = 45

	var/passive_message = span_notice("You feel an odd attraction to plasma.")
	var/temp_rate = 1

/datum/symptom/plasma_heal/first_activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	if(!HAS_TRAIT(mob, TRAIT_PLASMA_LOVER_METABOLISM))
		to_chat(mob, span_notice("You suddenly love plasma."))
	ADD_TRAIT(mob, TRAIT_PLASMA_LOVER_METABOLISM, type)

/datum/symptom/plasma_heal/side_effect(mob/living/mob)
	. = ..()
	REMOVE_TRAIT(mob, TRAIT_PLASMA_LOVER_METABOLISM, type)

/datum/symptom/plasma_heal/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	var/effectiveness = CanHeal(mob)
	if(!effectiveness)
		return
	if(passive_message_condition(mob))
		to_chat(mob, passive_message)
	Heal(mob, effectiveness)

/datum/symptom/plasma_heal/proc/CanHeal(mob/living/diseased_mob)
	var/datum/gas_mixture/environment
	var/list/gases

	var/base = 0

	// Check internals
	///  the amount of mols in a breath is significantly lower than in the environment so we are just going to use the tank's
	///  distribution pressure as an abstraction rather than calculate it using the ideal gas equation.
	///  balanced around a tank set to 4kpa = about 0.2 healing power. maxes out at 0.75 healing power, or 15kpa.
	if(iscarbon(diseased_mob))
		var/mob/living/carbon/breather = diseased_mob
		var/obj/item/tank/internals/internals_tank = breather.internal
		if(internals_tank)
			var/datum/gas_mixture/tank_contents = internals_tank.return_air()
			if(tank_contents && round(tank_contents.return_pressure())) // make sure the tank is not empty or 0 pressure
				if(tank_contents.gases[/datum/gas/plasma])
					// higher tank distribution pressure leads to more healing, but once you get to about 15kpa you reach the max
					base += power * min(MAX_HEAL_COEFFICIENT_INTERNALS, internals_tank.distribute_pressure * HEALING_PER_BREATH_PRESSURE)
	// Check environment
	if(diseased_mob.loc)
		environment = diseased_mob.loc.return_air()
	if(environment)
		gases = environment.gases
		if(gases[/datum/gas/plasma])
			base += power * min(MAX_HEAL_COEFFICIENT_INTERNALS, gases[/datum/gas/plasma][MOLES] * HEALING_PER_MOL)
	// Check for reagents in bloodstream
	if(diseased_mob.reagents?.has_reagent(/datum/reagent/toxin/plasma, needs_metabolizing = TRUE))
		base += power * MAX_HEAL_COEFFICIENT_BLOODSTREAM //Determines how much the symptom heals if injected or ingested
	return base

/datum/symptom/plasma_heal/proc/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/plasma_heal/proc/Heal(mob/living/carbon/M, actual_power)
	var/heal_amt = BASE_HEAL_PLASMA_FIXATION * actual_power

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing plasma inside and around you..."))

	var/target_temp = M.standard_body_temperature
	if(M.bodytemperature > target_temp)
		M.adjust_bodytemperature(-2 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)
		if(prob(5))
			to_chat(M, span_notice("You feel less hot."))
	else if(M.bodytemperature < (M.standard_body_temperature + 1))
		M.adjust_bodytemperature(2 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, 0, target_temp)
		if(prob(5))
			to_chat(M, span_notice("You feel warmer."))

	M.adjustToxLoss(-heal_amt)

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC)
	if(!parts.len)
		return
	if(prob(5))
		to_chat(M, span_notice("The pain from your wounds fades rapidly."))
	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()
	return 1

///Plasma End
#undef HEALING_PER_MOL
#undef HEALING_PER_BREATH_PRESSURE
#undef MAX_HEAL_COEFFICIENT_INTERNALS
#undef MAX_HEAL_COEFFICIENT_ENVIRONMENT
#undef MAX_HEAL_COEFFICIENT_BLOODSTREAM
#undef BASE_HEAL_PLASMA_FIXATION
