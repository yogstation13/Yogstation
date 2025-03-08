/datum/quirk/anime
	name = "Anime"
	desc = "You are an anime enjoyer! Show your enthusiasm with some fashionable attire."
	value = 0
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE | QUIRK_HIDE_FROM_SCAN
	mob_trait = TRAIT_ANIME
	icon = FA_ICON_PAW

	var/static/list/anime_list = list(
		/obj/item/organ/external/anime_head,
		/obj/item/organ/external/anime_middle,
		/obj/item/organ/external/anime_bottom,
	)

/datum/quirk/anime/add(client/client_source)
	var/mob/living/carbon/human/quirk_holder = src.quirk_holder
	RegisterSignal(quirk_holder, COMSIG_SPECIES_GAIN_PRE, PROC_REF(on_species_gain))

	var/datum/species/species = quirk_holder?.dna?.species
	if(QDELETED(species))
		return
	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		if (!should_external_organ_apply_to(organ_path, quirk_holder))
			continue
		//Load a persons preferences from DNA
		var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
		new_organ.Insert(quirk_holder, special = TRUE, drop_if_replaced = FALSE)
		species.external_organs |= organ_path

/datum/quirk/anime/remove()
	var/mob/living/carbon/human/quirk_holder = src.quirk_holder
	UnregisterSignal(quirk_holder, COMSIG_SPECIES_GAIN_PRE)
	var/datum/species/species = quirk_holder?.dna?.species
	if(QDELETED(species))
		return
	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		species.external_organs -= organ_path
		var/obj/item/organ/external/anime_organ = quirk_holder.get_organ_by_type(organ_path)
		if(!QDELETED(anime_organ))
			anime_organ.Remove(quirk_holder, special = TRUE)
			SSwardrobe.stash_object(anime_organ)

/datum/quirk/anime/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		if (!should_external_organ_apply_to(organ_path, quirk_holder))
			continue
		new_species.external_organs |= organ_path
