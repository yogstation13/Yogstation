/datum/action/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey. Cannot be used while cuffed or stunned. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	req_human = 1
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return FALSE
	to_chat(user, span_warning("Our genes cry out!"))
	..()
	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)
	return TRUE
