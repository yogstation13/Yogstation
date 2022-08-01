/mob/living/key_down(datum/keyinfo/I, client/user)
	switch(I.action)
		if(ACTION_RESIST)
			resist()
			return

	return ..()

/mob/living/key_down(datum/keyinfo/I, client/user)
	switch(I.action)
		if(ACTION_REST)
			lay_down()
			return

	return ..()
