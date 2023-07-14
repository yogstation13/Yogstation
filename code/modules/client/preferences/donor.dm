/datum/preference/choiced/donor_hat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_hat"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_hat/create_default_value()
	return "None"

/datum/preference/choiced/donor_hat/init_possible_values()
	var/list/values = list()

	values += "None"

	for(var/datum/donator_gear/S as anything in GLOB.donator_gear.donor_items)
		if(S.slot != ITEM_SLOT_HEAD)
			continue

		values += S.name

	return values

/datum/preference/choiced/donor_hat/compile_constant_data()
	var/list/data = ..()

	var/list/key_locked = list()

	for(var/datum/donator_gear/S as anything in GLOB.donator_gear.donor_items)
		if(S.slot != ITEM_SLOT_HEAD && !S.plush)
			continue

		if (!S.ckey)
			continue

		key_locked[S.name] = lowertext(S.ckey)

	data[CHOICED_PREFERENCE_KEY_LOCKED] = key_locked

	return data


/datum/preference/choiced/donor_item
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_item"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_item/create_default_value()
	return "None"

/datum/preference/choiced/donor_item/init_possible_values()
	var/list/values = list()

	values += "None"

	for(var/datum/donator_gear/S as anything in GLOB.donator_gear.donor_items)
		if(S.slot == ITEM_SLOT_HEAD && !S.plush)
			continue

		values += S.name

	return values

/datum/preference/choiced/donor_item/compile_constant_data()
	var/list/data = ..()

	var/list/key_locked = list()

	for(var/datum/donator_gear/S as anything in GLOB.donator_gear.donor_items)
		if(S.slot == ITEM_SLOT_HEAD)
			continue

		if (!S.ckey)
			continue

		key_locked[S.name] = lowertext(S.ckey)

	data[CHOICED_PREFERENCE_KEY_LOCKED] = key_locked

	return data


/datum/preference/choiced/donor_plush
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_plush"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_plush/create_default_value()
	return "None"

/datum/preference/choiced/donor_plush/init_possible_values()
	var/list/values = list()

	values += "None"

	for(var/datum/donator_gear/S as anything in GLOB.donator_gear.donor_items)
		if(S.plush)
			values += S.name

	return values

/datum/preference/choiced/donor_plush/compile_constant_data()
	var/list/data = ..()

	var/list/key_locked = list()

	for(var/datum/donator_gear/S as anything in GLOB.donator_gear.donor_items)
		if(S.slot == ITEM_SLOT_HEAD)
			continue

		if(!S.plush)
			continue

		if (!S.ckey)
			continue

		key_locked[S.name] = lowertext(S.ckey)

	data[CHOICED_PREFERENCE_KEY_LOCKED] = key_locked

	return data



/datum/preference/toggle/borg_hat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "borg_hat"
	savefile_identifier = PREFERENCE_PLAYER


/datum/preference/choiced/donor_pda
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_pda"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_pda/create_default_value()
	return PDA_COLOR_NORMAL

/datum/preference/choiced/donor_pda/init_possible_values()
	return GLOB.donor_pdas


/datum/preference/toggle/purrbation
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "purrbation"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_eorg
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_eorg"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_eorg/create_default_value()
	return "None"

/datum/preference/choiced/donor_eorg/init_possible_values()
	var/list/values = list()

	values += "None"

	for(var/datum/uplink_item/path as anything in GLOB.uplink_items)
		// Any item from any uplink, traitor, nukies, ert, as long as it fits this price range
		if(initial(path.cost) <= 0)
			continue
		if(initial(path.cost) > TELECRYSTALS_DEFAULT)
			continue
		values += "[path]"

	return values

/datum/preference/choiced/donor_eorg/compile_constant_data()
	var/list/data = ..()

	var/list/display_names = list("None" = "None")

	for (var/choice in get_choices())
		if (choice == "None")
			continue
		var/datum/uplink_item/uipath = text2path(choice)
		display_names[choice] = initial(uipath.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = display_names

	return data

/datum/preference/toggle/quiet_mode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "quiet_mode"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE
