TOGGLE_CHECKBOX(/datum/verbs/menu/Settings, listen_looc)()
	set name = "Show/Hide LOOC"
	set category = "Preferences"
	set desc = "Show LOOC Chat"
	usr.client.prefs.chat_toggles ^= CHAT_LOOC
	usr.client.prefs.save_preferences()
	to_chat(usr, "You will [(usr.client.prefs.chat_toggles & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Seeing LOOC", "[usr.client.prefs.chat_toggles & CHAT_LOOC ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/listen_ooc/Get_checked(client/C)
	return C.prefs.chat_toggles & CHAT_LOOC

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings, ghost_ckey)()
	set name = "Show/Hide ckey in deadchat"
	set category = "Preferences"
	set desc = "Toggle ckey"
	usr.client.prefs.chat_toggles ^= GHOST_CKEY
	usr.client.prefs.save_preferences()
	to_chat(usr, "Your ckey is [(usr.client.prefs.chat_toggles & GHOST_CKEY) ? "no longer" : "now"] visible in deadchat.")