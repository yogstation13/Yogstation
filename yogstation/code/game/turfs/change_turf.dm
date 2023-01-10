// Take every layer off and bring us to the bottom layer.
/turf/proc/ScrapeToBottom(flags)
    if(baseturfs == type) // Already at the bottom
        return src
    if(islist(baseturfs))
        return ChangeTurf(baseturfs[1],baseturfs[1],flags)
    else
        return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away