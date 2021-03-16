#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000

/datum/component/radioactive/rad_examine(datum/source, mob/user, atom/thing)
	var/atom/master = parent
	switch(strength)
		if(0 to RAD_AMOUNT_LOW)
			if(get_dist(master, user) <= 1)
				to_chat(user,"The air around [master] feels warm.")
		if(RAD_AMOUNT_LOW to RAD_AMOUNT_MEDIUM)
			to_chat(user, "[master] feels weird to look at.")
		if(RAD_AMOUNT_MEDIUM to RAD_AMOUNT_HIGH)
			to_chat(user, "[master] seems to be glowing a bit.")
		if(RAD_AMOUNT_HIGH to RAD_AMOUNT_EXTREME) //At this level the object can contaminate other objects
			to_chat(user, "<span class='warning'>[master] hurts to look at.</span>")
		if(RAD_AMOUNT_EXTREME to INFINITY)
			to_chat(user, "<span class='warning'>[master] burns to look at!</span>")
	
#undef RAD_AMOUNT_LOW
#undef RAD_AMOUNT_MEDIUM
#undef RAD_AMOUNT_HIGH
#undef RAD_AMOUNT_EXTREME
