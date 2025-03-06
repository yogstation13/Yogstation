/datum/quirk/foreigner
	name = "Foreigner"
	// monkestation edit original: desc = "You're not from around here. You don't know Galactic Common!"
	desc = "You don't understand Galactic Common. If you are human you have learned Galactic Uncommon instead."
	icon = FA_ICON_LANGUAGE
	value = QUIRK_COST_FOREIGNER //Monkestation change 0->QUIRK_COST_FOREIGNER
	gain_text = span_notice("The words being spoken around you don't make any sense.")
	lose_text = span_notice("You've developed fluency in Galactic Common.")
	// monkestation edit original: medical_record_text = "Patient does not speak Galactic Common and may require an interpreter."
	medical_record_text = "Patient does not understand Galactic Common and may require an interpreter."
	mail_goodies = list(/obj/item/taperecorder) // for translation

// monkestation edit start
/* original
/datum/quirk/foreigner/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.add_blocked_language(/datum/language/common)
	if(ishumanbasic(human_holder))
		human_holder.grant_language(/datum/language/uncommon, understood = TRUE, spoken = TRUE, source = LANGUAGE_QUIRK)

/datum/quirk/foreigner/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.remove_blocked_language(/datum/language/common)
	if(ishumanbasic(human_holder))
		human_holder.remove_language(/datum/language/uncommon)
*/
/datum/quirk/foreigner/add_unique(client/client_source)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	quirk_holder.remove_language(/datum/language/common, TRUE, TRUE, LANGUAGE_ALL)
	if(ishumanbasic(human_holder))
		human_holder.grant_language(/datum/language/uncommon, understood = TRUE, spoken = TRUE, source = LANGUAGE_QUIRK)
// monkestation edit end
