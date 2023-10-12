///basically just a copy of how part of /datum/action/innate works, but as a spell typepath
/datum/action/cooldown/spell/toggle
	/// Whether we're active or not
	var/active = FALSE
	
/datum/action/cooldown/spell/toggle/cast(atom/cast_on)
	if(!..())
		return FALSE

	// We're not a click action (we're a toggle or otherwise)
	var/active_status = active
	if(active_status)
		Enable()
	else
		Disable()

	if(active != active_status)
		build_all_button_icons(UPDATE_BUTTON_STATUS)

	return TRUE

/datum/action/cooldown/spell/toggle/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return active

/datum/action/cooldown/spell/toggle/proc/Enable()
	return

/datum/action/cooldown/spell/toggle/proc/Disable()
	return
