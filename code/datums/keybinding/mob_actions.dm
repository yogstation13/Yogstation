///Hotkeys for performing actions
/datum/keybinding/mob/action_hotkey
	var/action_num = 0
	category = CATEGORY_CARBON
	description = "Hotkey to activate an action of your mob in the corresponding slot"

/datum/keybinding/mob/action_hotkey/can_use(client/user)
	return user?.mob?.actions?.len>=action_num && ..()

/datum/keybinding/mob/action_hotkey/down(client/user)
	var/mob/M = user.mob
	var/datum/action/linked_action = M.actions[action_num]
	if (linked_action.owner != M)
		return //cheeky
	if (linked_action)
		linked_action.Trigger()
		SEND_SOUND(usr, get_sfx("terminal_type"))
	else
		to_chat(user, span_warning("You don't have an action to use in that slot"))
	return TRUE

/datum/keybinding/mob/action_hotkey/action_1
	name = "action_1"
	full_name = "Quick Action 1"
	action_num = 1

/datum/keybinding/mob/action_hotkey/action_2
	name = "action_2"
	full_name = "Quick Action 2"
	action_num = 2

/datum/keybinding/mob/action_hotkey/action_3
	name = "action_3"
	full_name = "Quick Action 3"
	action_num = 3

/datum/keybinding/mob/action_hotkey/action_4
	name = "action_4"
	full_name = "Quick Action 4"
	action_num = 4
