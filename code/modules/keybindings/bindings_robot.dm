<<<<<<< HEAD
// yogs - Replicated for custom keybindings
=======
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
/mob/living/silicon/robot/key_down(_key, client/user)
	switch(_key)
		if("1", "2", "3")
			toggle_module(text2num(_key))
			return
		if("4")
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if("Q")
			uneq_active()
			return
	return ..()