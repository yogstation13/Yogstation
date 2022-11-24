/datum/mutation/human/fasttwitch
	name = "Fast-twitch muscles ACTN3-R577X negative"
	desc = "Lets the subject move faster." 
	text_gain_indication = span_notice("You feel fast!")
	instability = 30

/datum/mutation/human/fasttwitch/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_movespeed_modifier("genetics", TRUE, 100, override=TRUE, multiplicative_slowdown=-0.1, movetypes=(~FLYING))

/datum/mutation/human/fasttwitch/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_movespeed_modifier("genetics", TRUE, 100, override=TRUE, multiplicative_slowdown=-0.1, movetypes=(~FLYING))
