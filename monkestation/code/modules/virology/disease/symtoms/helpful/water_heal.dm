/datum/symptom/water_heal
	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair damaged tissue cells. More effective when using holy water and against burns."

	stage = 1
	max_multiplier = 5
	max_chance = 45
	badness = EFFECT_DANGER_HELPFUL
	severity = 0

	var/passive_message = span_notice("Your skin feels oddly dry...")
	var/absorption_coeff = 1


/datum/symptom/water_heal/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	. = ..()
	var/effectiveness = CanHeal(mob)
	if(!effectiveness)
		return
	if(passive_message_condition(mob))
		to_chat(mob, passive_message)
	Heal(mob, effectiveness)

/datum/symptom/water_heal/proc/CanHeal(mob/living/M)
	if(!M)
		return 1
	var/base = 0
	if(M.fire_stacks < 0)
		M.adjust_fire_stacks(min(absorption_coeff, -M.fire_stacks))
		base += multiplier
	if(M.reagents?.has_reagent(/datum/reagent/water/holywater, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water/holywater, 0.5 * absorption_coeff)
		base += multiplier * 0.75
	else if(M.reagents?.has_reagent(/datum/reagent/water, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water, 0.5 * absorption_coeff)
		base += multiplier * 0.5
	return base

/datum/symptom/water_heal/proc/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/water_heal/proc/Heal(mob/living/carbon/M, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1, BODYTYPE_ORGANIC) //more effective on burns

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing the water around you to soothe your damaged skin."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len * 0.5, heal_amt/parts.len, BODYTYPE_ORGANIC))
			M.update_damage_overlays()

	return 1
