/datum/component/wet_floor/update_flags()
	var/intensity
	lube_flags = NONE
	switch(highest_strength)
		if(TURF_WET_WATER)
			intensity = 60
			lube_flags = NO_SLIP_WHEN_WALKING
		if(TURF_WET_LUBE)
			intensity = 80
			lube_flags = SLIDE | GALOSHES_DONT_HELP
		if(TURF_WET_ICE)
			intensity = 120
			lube_flags = SLIDE | GALOSHES_DONT_HELP
		if(TURF_WET_PERMAFROST)
			intensity = 120
			lube_flags = SLIDE_ICE | GALOSHES_DONT_HELP
		else
			qdel(parent.GetComponent(/datum/component/slippery))
			return

	var/datum/component/slippery/S = parent.LoadComponent(/datum/component/slippery, NONE, CALLBACK(src, .proc/AfterSlip))
	S.intensity = intensity
	S.lube_flags = lube_flags
