/mob/living/silicon/robot/key_down(datum/keyinfo/I, client/user)
	switch(I.action)
		if(ACTION_MODULE1)
			toggle_module(1)
			return
		if(ACTION_MODULE2)
			toggle_module(2)
			return
		if(ACTION_MODULE3)
			toggle_module(3)
			return
		if(ACTION_INTENTLEFT)
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if(ACTION_DROP)
			uneq_active()
			return

	return ..()