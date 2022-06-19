/datum/component/waddling
    dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/waddling/Initialize()
    if(!isliving(parent))
        return COMPONENT_INCOMPATIBLE
    RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/Waddle)

/datum/component/waddling/proc/Waddle()
    var/mob/living/L = parent
    if(L.incapacitated() || !(L.mobility_flags & MOBILITY_STAND))
        return
    var/cached_transform = L.transform
    animate(L, pixel_z = 4, time = 0 SECONDS)
    animate(pixel_z = 0, transform = turn(cached_transform, pick(-12, 0, 12)), time=0.2 SECONDS)
    animate(pixel_z = 0, transform = cached_transform, time = 0 SECONDS)
