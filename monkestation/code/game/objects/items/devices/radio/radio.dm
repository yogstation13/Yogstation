/// Sends an uncompressed subspace transmission that all radios on connected z-levels can hear.
/// Bypasses tcomms servers - this is mainly used for the radio host.
/obj/item/radio/proc/universal_transmission(datum/signal/subspace/vocal/signal)
	var/turf/our_turf = get_turf(src)
	if (signal.data["done"] && (our_turf.z in signal.levels))
		return
	signal.data["compression"] = 0
	signal.transmission_method = TRANSMISSION_SUBSPACE
	signal.levels = SSmapping.get_connected_levels(our_turf)
	signal.broadcast()
