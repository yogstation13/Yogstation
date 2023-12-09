// Take every layer off and bring us to the bottom layer.
/turf/proc/ScrapeToBottom(flags)
    if(baseturfs == type) // Already at the bottom
        return src
    if(islist(baseturfs))
        return ChangeTurf(baseturfs[1],baseturfs[1],flags)
    else
        return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away


/// Attempts to replace a tile with lattice. Amount is the amount of tiles to scrape away.
/turf/proc/attempt_lattice_replacement(amount = 2)
	if(lattice_underneath)
		var/turf/new_turf = ScrapeAway(amount, flags = CHANGETURF_INHERIT_AIR)
		if(!istype(new_turf, /turf/open/floor))
			new /obj/structure/lattice(src)
	else
		ScrapeAway(amount, flags = CHANGETURF_INHERIT_AIR)
