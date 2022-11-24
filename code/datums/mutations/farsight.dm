/datum/mutation/human/farsight
	name = "Farsight"
	desc = "Lets the subject see further." 
	text_gain_indication = span_notice("Your eyesight feels 20/20!")
	instability = 15

/datum/mutation/human/farsight/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.client?.view = "25x25"

/datum/mutation/human/farsight/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.client?.view = getScreenSize(owner.client?.prefs?.widescreenpref)
