/datum/quirk/family_heirloom
	value = 0 // Yogs Made It Free and no longer mood locked
	mood_quirk = FALSE // Just Incase

/datum/quirk/blooddeficiency/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOBLOOD in species.species_traits) //can't lose blood if your species doesn't have any
	qdel(species)

	if(disallowed_trait)
		return "You don't have blood!"
	return ..()
