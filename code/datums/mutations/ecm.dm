/datum/mutation/human/signaljam
	name = "EC-M41 \"Signal Jam\" gene"
	desc = "The subject is no longer able to be tracked by cameras." 
	text_gain_indication = span_notice("You hear static in your ears...")
	instability = 20

/datum/mutation/human/signaljam/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.digitalcamo = 1
	owner.digitalinvis = 1

/datum/mutation/human/signaljam/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.digitalcamo = 0
	owner.digitalinvis = 0
