/datum/quirk/monophobia
	name = "Monophobia"
	desc = "You are extremely stressed when left alone, leading to potentially lethal levels of anxiety."
	value = -6
	icon = FA_ICON_USER_FRIENDS
	medical_record_text = "Patient has an irrational fear of something."
	mail_goodies = list(/obj/item/choice_beacon/pet)

/datum/quirk/monophobia/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(new /datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/monophobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)
