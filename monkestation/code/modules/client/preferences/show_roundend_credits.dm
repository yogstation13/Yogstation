/datum/preference/toggle/show_roundend_credits
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "show_roundend_credits"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/show_roundend_credits/apply_to_client_updated(client/client, value)
	if(!value)
		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, ClearCredits))
