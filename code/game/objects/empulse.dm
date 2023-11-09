/proc/empulse(turf/epicenter, severity, range=null, log=TRUE)
	if(!epicenter)
		CRASH("Warning: empulse() called without an epicenter!")

	if(severity < 1)
		return

	if(!isturf(epicenter))
		epicenter = get_turf(epicenter.loc)
	
	if(isnull(range)) // range is equal to severity by default
		range = severity

	if(log)
		message_admins("EMP with size ([range]) and severity ([severity]) in area [epicenter.loc.name] ")
		log_game("EMP with size ([range]) and severity ([severity]) in area [epicenter.loc.name] ")

	if(range <= 0)
		for(var/atom/A in epicenter)
			A.emp_act(severity)
		return

	var/tile_falloff = severity / range
	for(var/A in spiral_range(range, epicenter))
		var/atom/T = A
		var/decayed_severity = severity - round(get_dist(epicenter, T) * tile_falloff)
		if(decayed_severity < 1)
			continue
		T.emp_act(decayed_severity)
	return TRUE
