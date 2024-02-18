/mob/living/proc/get_blood_state() // Returns how our good or bad our blood situation is, using the blood enums in Yogstation\code\__DEFINES\mobs.dm
	if(!initial(blood_volume))
		return BLOOD_SAFE // I... guess we're fine?

	if(blood_volume >= BLOOD_VOLUME_MAXIMUM(src))
		return BLOOD_MAXIMUM
	if(blood_volume >= BLOOD_VOLUME_SAFE(src))
		return BLOOD_SAFE
	if(blood_volume >= BLOOD_VOLUME_OKAY(src))
		return BLOOD_OKAY
	if(blood_volume >= BLOOD_VOLUME_BAD(src))
		return BLOOD_BAD
	if(blood_volume >= BLOOD_VOLUME_SURVIVE(src))
		return BLOOD_SURVIVE
	return BLOOD_DEAD

/mob/living/update_sight()
	. = ..()
	for(var/mob/living/simple_animal/hostile/guardian/holopara as anything in hasparasites())
		holopara.lighting_alpha = lighting_alpha
		holopara.update_sight()
