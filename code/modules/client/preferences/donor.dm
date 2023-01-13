/datum/preference/choiced/donor_hat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_hat"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_hat/create_default_value()
	return "None"

/datum/preference/choiced/donor_hat/init_possible_values()
	var/list/values = list()

	values += "None"

	for(var/datum/donator_gear/S in GLOB.donator_gear.donor_items)
		if(S.slot == SLOT_HEAD)
			values += S.name

	return values


/datum/preference/choiced/donor_item
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_item"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_item/create_default_value()
	return "None"

/datum/preference/choiced/donor_item/init_possible_values()
	var/list/values = list()

	values += "None"

	for(var/datum/donator_gear/S in GLOB.donator_gear.donor_items)
		if(S.slot != SLOT_HEAD)
			values += S.name

	return values


/datum/preference/toggle/borg_hat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "borg_hat"
	savefile_identifier = PREFERENCE_PLAYER
