/datum/component/spoiling
	/// How long until it spoils
	var/spoiling_time = 0
	/// What to change it into
	var/spawned
	/// Is it being refrigerated
	var/cold = FALSE

/datum/component/spoiling/Initialize(_spoiled, _time = 12.5 MINUTES)
	. = ..()
	spawned = _spoiled
	spoiling_time = _time
	START_PROCESSING(SSobj, src)

/datum/component/spoiling/process()
	if(!cold)
		var/atom/parent_atom = parent
		var/turf/T = parent_atom.loc
		if(T.return_air().return_temperature() > 263.15) // 10C
			spoiling_time -= 1 SECONDS

	if(spoiling_time <= 0) // Uh oh stinky!
		new spawned(drop_location())
		STOP_PROCESSING(SSobj, src)
		qdel(parent)

/datum/component/spoiling/proc/drop_location()
	var/atom/parent_atom = parent
	return parent_atom.drop_location()
