/datum/action/innate/zombie/uncuff
	name = "Break Free!"
	desc = "Breaks you free from handcuffs."
	button_icon_state = "biodegrade"

/datum/action/innate/zombie/uncuff/Activate(forced = FALSE)
	var/mob/living/carbon/human/H = usr
	H.uncuff()
