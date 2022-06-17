/obj/item/organ/heart/gland/chem
	abductor_hint = "intrinsic pharma-provider. The abductee constantly produces random chemicals inside their bloodstream. They also quickly regenerate toxin damage."
	cooldown_low = 5 SECONDS
	cooldown_high = 5 SECONDS
	icon_state = "viral"
	mind_control_uses = 3
	mind_control_duration = 1200
	var/list/possible_reagents = list()

/obj/item/organ/heart/gland/chem/Initialize()
	. = ..()
	for(var/R in subtypesof(/datum/reagent/drug) + subtypesof(/datum/reagent/medicine) + typesof(/datum/reagent/toxin))
		possible_reagents += R

/obj/item/organ/heart/gland/chem/activate()
	var/chem_to_add = pick(possible_reagents)
	owner.reagents.add_reagent(chem_to_add, 2)
	owner.adjustToxLoss(-5, TRUE, TRUE)
	..()

