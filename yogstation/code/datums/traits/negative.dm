/datum/quirk/family_heirloom
	value = 0 // Yogs Made It Free and no longer mood locked
	mood_quirk = FALSE // Just Incase

/datum/quirk/blooddeficiency/check_quirk(datum/preferences/prefs)
	if(prefs.pref_species && (NOBLOOD in prefs.pref_species.species_traits)) //can't lose blood if your species doesn't have any
		return "You don't have blood as [prefs.pref_species]!"
	return FALSE
