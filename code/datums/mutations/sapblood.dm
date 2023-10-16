/datum/mutation/human/sapblood
	name = "Sap blood"
	desc = "A mutation that causes the host's blood to thicken, almost like sap, bleeding less and coagulating faster."
	quality = POSITIVE
	difficulty = 16
	locked = TRUE
	text_gain_indication = span_notice("You feel your arteries cloying!")
	instability = 20
	/// The bloodiest wound that the patient has will have its blood_flow reduced by this much each tick
	var/clot_rate = 0.2
	/// While we have this mutation, we reduce all bleeding by this factor
	var/passive_bleed_modifier = 0.6

/datum/mutation/human/sapblood/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_COAGULATING, GENETIC_MUTATION)
	owner.physiology?.bleed_mod *= passive_bleed_modifier

/datum/mutation/human/sapblood/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_COAGULATING, GENETIC_MUTATION)
	owner.physiology?.bleed_mod /= passive_bleed_modifier

/datum/mutation/human/sapblood/on_life()
	. = ..()
	if(!owner.blood_volume || !owner.all_wounds)
		return

	var/datum/wound/bloodiest_wound

	for(var/i in owner.all_wounds)
		var/datum/wound/iter_wound = i
		if(iter_wound.blood_flow)
			if(iter_wound.blood_flow > bloodiest_wound?.blood_flow)
				bloodiest_wound = iter_wound

	if(bloodiest_wound)
		bloodiest_wound.blood_flow = max(0, bloodiest_wound.blood_flow - clot_rate)
