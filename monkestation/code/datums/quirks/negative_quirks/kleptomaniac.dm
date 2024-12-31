/datum/quirk/kleptomaniac
	name = "Kleptomaniac"
	desc = "The station's just full of free stuff!  Nobody would notice if you just... took it, right?"
	value = -2
	medical_record_text = "Patient has an unconscious tendency to pickpocket nearby people or pick up items off the ground."
	icon = FA_ICON_BAG_SHOPPING

/datum/quirk/kleptomaniac/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(ishuman(human_holder))
		human_holder.gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(ishuman(human_holder))
		human_holder.cure_trauma_type(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)
