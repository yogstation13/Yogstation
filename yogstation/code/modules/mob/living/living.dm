/mob/living/proc/get_blood_state() // Returns how our good or bad our blood situation is, using the blood enums in Yogstation-TG\code\__DEFINES\mobs.dm
	if(!initial(blood_volume))
		return BLOOD_SAFE // I... guess we're fine?
	
	switch(blood_volume / initial(blood_volume))
		if(BLOOD_VOLUME_MAXIMUM(src) to INFINITY)
			return BLOOD_MAXIMUM
		if(BLOOD_VOLUME_SAFE(src) to BLOOD_VOLUME_MAXIMUM(src))
			return BLOOD_SAFE
		if(BLOOD_VOLUME_OKAY(src) to BLOOD_VOLUME_SAFE(src))
			return BLOOD_OKAY
		if(BLOOD_VOLUME_BAD(src) to BLOOD_VOLUME_OKAY(src))
			return BLOOD_BAD
		if(BLOOD_VOLUME_SURVIVE(src) to BLOOD_VOLUME_BAD(src))
			return BLOOD_SURVIVE
		else
			return BLOOD_DEAD
