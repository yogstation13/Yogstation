#define bMAXIMUM	(initial(blood_volume)*BLOOD_MAXIMUM_MULTI)
#define bSAFE		(initial(blood_volume)*BLOOD_SAFE_MULTI)
#define bOKAY 		(initial(blood_volume)*BLOOD_OKAY_MULTI)
#define bBAD		(initial(blood_volume)*BLOOD_BAD_MULTI)
#define bSURVIVE	(initial(blood_volume)*BLOOD_SURVIVE_MULTI)

/mob/living/proc/get_blood_state() // Returns how our good or bad our blood situation is, using the blood enums in Yogstation-TG\code\__DEFINES\mobs.dm
	if(!initial(blood_volume))
		return BLOOD_SAFE // I... guess we're fine?
	
	switch(blood_volume / initial(blood_volume))
		if(bMAXIMUM to INFINITY)
			return BLOOD_MAXIMUM
		if(bSAFE to bMAXIMUM)
			return BLOOD_SAFE
		if(bOKAY to bSAFE)
			return BLOOD_OKAY
		if(bBAD to bOKAY)
			return BLOOD_BAD
		if(bSURVIVE to bBAD)
			return BLOOD_SURVIVE
		else
			return BLOOD_DEAD
	
#undef bMAXIMUM
#undef bSAFE
#undef bOKAY
#undef bBAD
#undef bSURVIVE