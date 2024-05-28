/datum/component/lingering
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// A callback on the parent to be called when it tries to apply an affect on an atom
	var/datum/callback/affect_callback

/datum/component/lingering/Initialize(datum/callback/affect_callback)
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE
	if(!affect_callback)
		stack_trace("Lingering component has been applied to a turf without an affect callback proc")
		return COMPONENT_INCOMPATIBLE
	src.affect_callback = affect_callback

/datum/component/lingering/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_HITBY, PROC_REF(hitby))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(Entered))

/datum/component/lingering/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_HITBY)
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	STOP_PROCESSING(SSobj, src)
	. = ..()
	
////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Triggers---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/hitby(datum/source, atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(affect_stuff(AM))
		START_PROCESSING(SSobj, src)

/datum/component/lingering/proc/Entered(datum/source, atom/movable/AM)
	if(affect_stuff(AM))
		START_PROCESSING(SSobj, src)

/datum/component/lingering/process(delta_time)
	if(!affect_stuff(null, delta_time))
		STOP_PROCESSING(SSobj, src)

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------safety check-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))

	var/turf/open/place = get_turf(parent)

	var/list/found_safeties = typecache_filter_list(place.contents, lava_safeties_typecache)

	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/datum/component/lingering/proc/affect_stuff(AM, delta_time = 1)
	. = 0

	if(!affect_callback)
		stack_trace("Lingering component has been applied to a turf without an affect callback proc") //covering my bases
		return

	if(is_safe())
		return FALSE

	if(AM) //if it's a specific object, apply to that one
		return affect_callback.Invoke(AM, delta_time)

	var/turf/open/place = get_turf(parent) //otherwise, apply to every object on the turf

	if(!place)
		return

	for(var/thing in place.contents)
		if(thing == parent)
			continue
		if(affect_callback.Invoke(thing, delta_time))
			. = 1
