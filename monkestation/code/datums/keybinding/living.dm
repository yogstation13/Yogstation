/datum/keybinding/living/interaction_action1
	hotkey_keys = list("1")
	name = "interaction_mode_action_1"
	full_name = "Intent 1/Combat Off"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_1

/datum/keybinding/living/interaction_action1/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(1)

/datum/keybinding/living/interaction_action2
	hotkey_keys = list("2")
	name = "interaction_mode_action_2"
	full_name = "Intent 2"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_2

/datum/keybinding/living/interaction_action2/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(2)

/datum/keybinding/living/interaction_action3
	hotkey_keys = list("3")
	name = "interaction_mode_action_3"
	full_name = "Intent 3/Combat On"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_3

/datum/keybinding/living/interaction_action3/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(3)

/datum/keybinding/living/interaction_action4
	hotkey_keys = list("4", "F")
	name = "interaction_mode_action_4"
	full_name = "Intent 4/Toggle Combat"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_4

/datum/keybinding/living/interaction_action4/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(4)

/datum/keybinding/living/interaction_action5
	hotkey_keys = list("Unbound")
	name = "interaction_mode_action_5"
	full_name = "Intent Cycle"
	description = "Cycles through intents"
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_5

/datum/keybinding/living/interaction_action5/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(5)

/datum/keybinding/living/item_pixel_shift
	hotkey_keys = list("V")
	name = "item_pixel_shift"
	full_name = "Item Pixel Shift"
	description = "Shift a pulled item's offset"
	category = CATEGORY_MISC
	keybind_signal = COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN

/datum/keybinding/living/item_pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.AddComponent(/datum/component/pixel_shift)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN)

/datum/keybinding/living/item_pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP)

/datum/keybinding/living/pixel_shift
	hotkey_keys = list("B")
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Shift your characters offset."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN

/datum/keybinding/living/pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.AddComponent(/datum/component/pixel_shift)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN)

/datum/keybinding/living/pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_SHIFT_UP)

/datum/keybinding/living/interaction_toggle_wield
	hotkey_keys = list("ShiftX")
	name = "keybinding_living_toggle_wield"
	full_name = "Wield"
	description = "Wield an object in two hands, such as a gun."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_WIELD

/datum/keybinding/living/interaction_toggle_wield/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/mob = user.mob
	var/obj/item/item = mob?.get_active_held_item()
	if(item?.GetComponent(/datum/component/two_handed)) // does our active item have a two_handed component? if so let's ctrl click it!
		item.CtrlClick(mob)
