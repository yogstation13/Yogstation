/// Used to get a random closed and non-secure locker on the station z-level, created for the Stowaway trait.
/proc/get_unlocked_closed_locker()
	var/list/eligible_lockers = list()
	for(var/obj/structure/closet/closet as anything in GLOB.closets)
		if(QDELETED(closet) || closet.opened || istype(closet, /obj/structure/closet/secure_closet))
			continue
		var/turf/closet_turf = get_turf(closet)
		if(!closet_turf || !is_station_level(closet_turf.z) || !is_safe_turf(closet_turf, dense_atoms = TRUE))
			continue
		eligible_lockers += closet
	if(length(eligible_lockers))
		return pick(eligible_lockers)
