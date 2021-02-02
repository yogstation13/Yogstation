/datum/mutation/human/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "A hyperactive liver improves the patient's ability to metabolize alcohol."
	quality = POSITIVE
	text_gain_indication = "<span class='danger'>Your liver hurts.</span>"
	text_lose_indication = "<span class='danger'>Your liver feels sad.</span>"

/datum/mutation/human/alcohol_tolerance/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_ALCOHOL_TOLERANCE, GENETIC_MUTATION)

/datum/mutation/human/alcohol_tolerance/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_ALCOHOL_TOLERANCE, GENETIC_MUTATION)

/datum/mutation/human/alcohol_generate
	name = "Auto-brewery Syndrome"
	desc = "The patient's body now naturally produces alcohol into their bloodstream."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>Your liver feels amazing.</span>"
	text_lose_indication = "<span class='danger'>Your liver feels sad.</span>"

/datum/mutation/human/alcohol_generate/on_life()
	if(prob(15))
		owner.reagents.add_reagent(/datum/reagent/consumable/ethanol, 3)