/datum/surgery/advanced/dna_recovery
	name = "DNA Recovery"
	desc = "An experimental surgical procedure that could fix the DNA from dead bodies. Requires rezadone, amanitin, or entropic polypnium."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/dna_recovery,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/dna_recovery/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	return HAS_TRAIT_FROM(target, TRAIT_BADDNA, CHANGELING_DRAIN) || HAS_TRAIT(target, TRAIT_HUSK)

/datum/surgery_step/dna_recovery
	name = "recover DNA (syringe)"
	implements = list(/obj/item/reagent_containers/syringe = 100, /obj/item/pen = 30)
	time = 15 SECONDS
	chems_needed = list(
		/datum/reagent/medicine/rezadone,
		/datum/reagent/toxin/amanitin,
		/datum/reagent/consumable/entpoly,
	)
	require_all_chems = FALSE

/datum/surgery_step/dna_recovery/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to mend what's left of [target]'s DNA..."),
		span_notice("[user] begins to tinker with [target]'s brain..."),
		span_notice("[user] begins to perform surgery on [target]'s brain.")
	)

/datum/surgery_step/dna_recovery/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You succeed in fixing some of [target]'s DNA!"),
		span_notice("[user] successfully repairs some of [target]'s DNA"),
		span_notice("[user] completes the surgery on [target]'s brain."),
	)
	REMOVE_TRAIT(target, TRAIT_BADDNA, CHANGELING_DRAIN)
	target.cure_husk()
	return TRUE
