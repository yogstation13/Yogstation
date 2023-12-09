/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


/datum/keybinding/carbon/rest
	hotkey_keys = list("U")
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."

/datum/keybinding/carbon/rest/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.lay_down()
	return TRUE


/datum/keybinding/living/resist
	hotkey_keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? on fire? Resist!"

/datum/keybinding/living/resist/down(client/user)
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

// Moved here because of dextrous mobs and carbons and etc.
/datum/keybinding/living/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Quick Equip"
	description = "Quickly puts an item in the best slot available."

/datum/keybinding/living/quick_equip/down(client/user)
	var/mob/living/living_mob = user.mob
	living_mob.quick_equip()
	return TRUE
