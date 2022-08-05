// yogs - Replicated for custom keybindings
/mob/living/carbon/key_down(_key, client/user)
	switch(_key)
		if("R", "Southwest") // Southwest is End
			toggle_throw_mode()
			return
		if("V")
			lay_down()
			return			
		if("1")
			a_intent_change(INTENT_HELP)
			return
		if("2")
			a_intent_change(INTENT_DISARM)
			return
		if("3")
			a_intent_change(INTENT_GRAB)
			return
		if("4")
			a_intent_change(INTENT_HARM)
			return
	return ..()
