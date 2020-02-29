/datum/surgery/advanced/dna_recovery
	name = "DNA recovery"
	desc = "An experimental surgical procedure that could fix the DNA from dead bodies. Requires rezadone."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/saw,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/dna_recovery,
				/datum/surgery_step/close)

	possible_locs = list(BODY_ZONE_HEAD)


/datum/surgery/advanced/dna_recovery/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE

	if(!HAS_TRAIT_FROM(target, TRAIT_BADDNA, CHANGELING_DRAIN))
		return FALSE
	else
		return TRUE

/datum/surgery_step/dna_recovery
	name = "recover DNA"
	implements = list(/obj/item/reagent_containers/syringe = 100, /obj/item/pen = 30)
	time = 150
	chems_needed = list(/datum/reagent/medicine/rezadone)
	require_all_chems = FALSE

/datum/surgery_step/dna_recovery/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to mend what's left of [target]'s DNA...</span>",
		"[user] begins to tinker with [target]'s brain...",
		"[user] begins to perform surgery on [target]'s brain.")

/datum/surgery_step/dna_recovery/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succeed in fixing some of [target]'s DNA!</span>",
		"[user] successfully repairs some of [target]'s DNA",
		"[user] completes the surgery on [target]'s brain.")
	REMOVE_TRAIT(target, TRAIT_BADDNA, CHANGELING_DRAIN)
	return TRUE