/datum/quirk/outsider
	name = "Outsider"
	desc = "You don't know your species' language. If you are human you know a random language instead of Galactic Common."
	icon = FA_ICON_BAN
	value = QUIRK_COST_OUTSIDER
	gain_text = span_notice("You can't understand your species' language.")
	lose_text = span_notice("You've remembered your species' language.")

/datum/quirk/outsider/add_unique(client/client_source)
	var/is_human = ishumanbasic(quirk_holder)
	if (is_human)
		quirk_holder.remove_language(/datum/language/common, TRUE, TRUE, LANGUAGE_ALL)
	for (var/language in quirk_holder.language_holder.understood_languages)
		if (language != /datum/language/common)
			quirk_holder.remove_language(language, TRUE, FALSE, LANGUAGE_ALL)
	for (var/language in quirk_holder.language_holder.spoken_languages)
		if (language != /datum/language/common)
			quirk_holder.remove_language(language, FALSE, TRUE, LANGUAGE_ALL)
	if (is_human)
		quirk_holder.grant_language(pick(GLOB.roundstart_languages), TRUE, TRUE, LANGUAGE_QUIRK)

/datum/quirk/listener
	name = "Listener"
	desc = "You are unable to speak Galactic Common though you understand it just fine."
	icon = FA_ICON_BELL_SLASH
	value = QUIRK_COST_LISTENER
	hardcore_value = QUIRK_HARDCORE_LISTENER
	gain_text = span_notice("You don't know how to speak Galactic Common.")
	lose_text = span_notice("You're able to speak Galactic Common.")
	medical_record_text = "Patient does not speak Galactic Common and may require an interpreter."

/datum/quirk/listener/add_unique(client/client_source)
	quirk_holder.remove_language(/datum/language/common, FALSE, TRUE, LANGUAGE_ATOM)
	if (!iscarbon(quirk_holder))
		return
	var/mob/living/carbon/carbon_holder = quirk_holder
	for (var/obj/item/clothing/mask/translator/translator in carbon_holder.get_all_gear())
		carbon_holder.temporarilyRemoveItemFromInventory(translator, force = TRUE, idrop = FALSE)
		qdel(translator)
