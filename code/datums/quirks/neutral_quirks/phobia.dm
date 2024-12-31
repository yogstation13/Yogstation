/datum/quirk/phobia
	name = "Phobia"
	desc = "You are irrationally afraid of something."
	icon = FA_ICON_SPIDER
	value = 0
	medical_record_text = "Patient has an irrational fear of something."
	mail_goodies = list(/obj/item/clothing/glasses/blindfold, /obj/item/storage/pill_bottle/psicodine)
	var/phobia

// Phobia will follow you between transfers
/datum/quirk/phobia/add(client/client_source)
	phobia ||= client_source?.prefs?.read_preference(/datum/preference/choiced/phobia)
	if(!phobia)
		return

	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia(phobia), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/mild/phobia, TRAUMA_RESILIENCE_ABSOLUTE)
	phobia = null

/datum/quirk/phobia/clone_data()
	return phobia

/datum/quirk/phobia/on_clone(mob/living/carbon/human/cloned_mob, client/client_source, data)
	phobia = data
	return ..()
