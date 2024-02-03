/datum/reagent/medicine/mannitol
	name = "Mannitolin"
	description = "Generic drug that uses a patented active substance molecule to restore brain damage. Unfortunately it isn`t too effective and requires very cold temperatures to properly metabolize."
	color = "#DCDCFF"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature < T0C)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (holder.has_reagent(/datum/reagent/drug/methamphetamine) ? 0 : -2)*REM)
		. = 1
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (holder.has_reagent(/datum/reagent/drug/methamphetamine) ? 0 : -0.2)*REM)
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (M.bodytemperature ** 2) + 0.5)
	..()

/datum/reagent/medicine/mannitol/advanced
	name = "Mannitol"
	description = "Efficiently restores brain damage. Brand patented."
	color = "#4CE8E2"
	metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/medicine/mannitol/advanced/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (holder.has_reagent(/datum/reagent/drug/methamphetamine) ? 0 : -2)*REM)
	current_cycle++
	holder.remove_reagent(type, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	description = "A chemical that derives from Cryoxadone. It specializes in healing clone damage, but nothing else. Requires very cold temperatures to properly metabolize, and metabolizes quicker than cryoxadone."
	color = "#80BFFF"
	taste_description = "muscle"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature < T0C && M.IsSleeping()) //yes you have to be in cryo shut up and drink your corn syrup
		M.adjustCloneLoss(0.001 * (M.bodytemperature ** 2) - 100, 0)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.000015 * (M.bodytemperature ** 2) + 0.75)
	..()