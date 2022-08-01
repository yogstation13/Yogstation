// yogs - Replicated for custom keybindings
/mob/living/key_down(_key, client/user)
	switch(_key)
		if("B")
			resist()
			return

	return ..()

/mob/living/key_down(_key, client/user)
	switch(_key)
		if("V")
			lay_down()
			return

	return ..()
