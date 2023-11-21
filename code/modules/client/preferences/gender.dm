/// Gender preference
/datum/preference/choiced/gender
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "gender"
	priority = PREFERENCE_PRIORITY_GENDER

/datum/preference/choiced/gender/init_possible_values()
	return list(MALE, FEMALE, PLURAL)

/datum/preference/choiced/gender/create_informed_default_value(datum/preferences/preferences)

	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	
	if(!initial(species_type.sexes) || (AGENDER in initial(species_type.species_traits)))
		return PLURAL
	else if(FGENDER in initial(species_type.species_traits))
		return FEMALE
	else if(MGENDER in initial(species_type.species_traits))
		return MALE

	return pick(list(MALE, FEMALE, PLURAL))

/datum/preference/choiced/gender/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/species/S = target.dna.species

	if(!S.sexes || (AGENDER in S.species_traits))
		value = PLURAL //disregard gender preferences on this species

	if(S)
		if(FGENDER in S.species_traits)
			value = FEMALE
		else if(MGENDER in S.species_traits)
			value = MALE
			
	target.gender = value
