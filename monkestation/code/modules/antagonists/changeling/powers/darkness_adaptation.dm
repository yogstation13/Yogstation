/datum/action/changeling/darkness_adaptation/enable_ability(mob/living/carbon/human/cling)
	. = ..()
	RegisterSignal(cling, COMSIG_CARBON_LOSE_MUTATION, PROC_REF(on_mutation_lost))

/datum/action/changeling/darkness_adaptation/disable_ability(mob/living/carbon/human/cling)
	. = ..()
	UnregisterSignal(cling, COMSIG_CARBON_LOSE_MUTATION)

/datum/action/changeling/darkness_adaptation/proc/on_mutation_lost(mob/living/carbon/human/cling, mutation_type)
	SIGNAL_HANDLER
	if(mutation_type in typesof(/datum/mutation/human/chameleon))
		addtimer(CALLBACK(src, PROC_REF(reset_alpha), cling), 0.1 SECONDS) // stupidity at it's finest

/datum/action/changeling/darkness_adaptation/proc/reset_alpha(mob/living/carbon/human/cling)
	if(!QDELETED(cling))
		animate(cling, alpha = 65, time = 3 SECONDS)
