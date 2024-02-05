/datum/keybinding/client/communication/say/down(client/user)
    user.mob.say_wrapper()
    return TRUE 

/datum/keybinding/client/communication/emote/down(client/user)
    user.mob.me_wrapper()
    return TRUE

/datum/keybinding/client/communication/looc/down(client/user)
    user.looc_wrapper()
    return TRUE 

/datum/keybinding/client/communication/ooc/down(client/user)
    user.ooc_wrapper()
    return TRUE
	
/datum/keybinding/client/communication/donor_say/down(client/user)
	user.get_donator_say()
	return TRUE 

/datum/keybinding/client/communication/mentor_say/down(client/user)
	user.mentor_wrapper()
	return TRUE 

/client/verb/looc_wrapper()
	set hidden = TRUE
	var/message = input("", "LOOC \"text\"") as null|text
	looc(message)

/client/verb/mentor_wrapper()
	set hidden = TRUE
	set name = "msay"

	var/message = input(src, null, "Mentor Chat \"text\"") as text|null
	if (message)
		cmd_mentor_say(message)
