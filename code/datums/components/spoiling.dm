/datum/component/spoiling
	/// How long until it spoils
	var/spoiling_time = 15 MINUTES
	/// What to change it into
	var/obj/spawned
	/// Is it being refrigerated
	var/cold = FALSE

/datum/component/spoiling/Initialize(...)
	. = ..()
		START_PROCESSING(SSobj, src)

/datum/component/spoiling/process()
	if(!cold)
		spoiling_time -= 1 SECONDS

	if(spoiling_time <= 0) // Uh oh stinky!
		new/spawned(src)
		qdel(src)
		STOP_PROCESSING(src)
