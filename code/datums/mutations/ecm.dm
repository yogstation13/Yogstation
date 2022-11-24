/datum/mutation/human/fasttwitch
	name = "EC-M41 \"Signal Jam\" gene"
	desc = "The subject is no longer able to be tracked by cameras." 
	text_gain_indication = span_notice("You hear static in your ears...")
	instability = 20

/datum/mutation/human/fasttwitch/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	user.digitalcamo = 1
	user.digitalinvis = 1

/datum/mutation/human/fasttwitch/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	user.digitalcamo = 0
	user.digitalinvis = 0
