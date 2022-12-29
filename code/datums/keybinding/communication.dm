/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION


/datum/keybinding/client/communication/say
	hotkey_keys = list("T")
	name = "Say"
	full_name = "IC Say"
	description = ""


/datum/keybinding/client/communication/emote
	hotkey_keys = list("M")
	name = "Emote"
	full_name = "Emote"
	description = ""


/datum/keybinding/client/communication/ooc
	hotkey_keys = list("O")
	name = "OOC"
	full_name = "OOC"
	description = ""


/datum/keybinding/client/communication/looc
	hotkey_keys = list("L")
	name = "LOOC"
	full_name = "LOOC"
	description = ""


/datum/keybinding/client/communication/donor_say
	hotkey_keys = list("F9")
	name = "donor_say"
	full_name = "Donator Say"
	description = ""

/datum/keybinding/client/communication/donor_say/can_use(client/user)
	return is_donator(user)

/datum/keybinding/client/communication/donor_say/down(client/user)
	user.get_donator_say()


/datum/keybinding/client/communication/mentor_say
	hotkey_keys = list("F4")
	name = "mentor_say"
	full_name = "Mentor Say"
	description = ""

/datum/keybinding/client/communication/mentor_say/can_use(client/user)
	return is_mentor(user)

/datum/keybinding/client/communication/mentor_say/down(client/user)
	user.get_mentor_say()
