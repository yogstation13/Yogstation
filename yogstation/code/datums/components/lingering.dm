/datum/component/lingering
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// A callback on the parent to be called when it tries to apply an affect on an atom
	var/datum/callback/affect_callback
	/// A list of things that if even one is on the tile, will prevent the effect
	var/list/safeties_typecache

/**
 * Lingering component
 * 
 * essentially caltrops, but it keeps triggering every SSobj tick
 * 
 * vars:
 * * affect_callback (required) A callback that triggers a proc that returns true or false, false will stop the processing of the component
 * * safeties_typecache (optional) A list of typepaths that if they're on the same tile will prevent the effect
 */
/datum/component/lingering/Initialize(datum/callback/affect_callback, list/safeties_typecache)
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE
	if(!affect_callback)
		stack_trace("Lingering component has been applied to a turf without an affect callback proc")
		return COMPONENT_INCOMPATIBLE
	src.affect_callback = affect_callback
	src.safeties_typecache = safeties_typecache

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
	if(affect_target(AM))
		START_PROCESSING(SSobj, src)

/datum/component/lingering/proc/Entered(datum/source, atom/movable/AM)
	if(affect_target(AM))
		START_PROCESSING(SSobj, src)

/datum/component/lingering/process(delta_time)
	if(!affect_stuff(delta_time))
		STOP_PROCESSING(SSobj, src)

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------safety check-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/is_safe()
	if(!safeties_typecache)
		return FALSE

	var/turf/open/place = get_turf(parent)

	var/list/found_safeties = typecache_filter_list(place.contents, safeties_typecache)

	for(var/obj/structure/stone_tile/S in found_safeties) //snowflake check because stone tiles work weirdly, not ideal
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)

	return LAZYLEN(found_safeties)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------single tick upon enter-----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/affect_target(AM)
	. = FALSE

	if(!affect_callback)
		stack_trace("Lingering component has been applied to a turf without an affect callback proc") //covering my bases
		return

	if(is_safe()) //we don't want to damage the target, but we want to start processing just in case
		return TRUE

	if(AM) //if it's a specific object, apply to that one
		return affect_callback.Invoke(AM, 1)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Tick everything inside on process---------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/affect_stuff(delta_time = 1)
	. = FALSE

	if(!affect_callback)
		stack_trace("Lingering component has been applied to a turf without an affect callback proc") //covering my bases
		return

	var/turf/open/place = get_turf(parent) //otherwise, apply to every object on the turf

	if(!place)
		return

	var/safe = is_safe() //we call this here so it doesn't need to be called multiple times if it returns false

	for(var/thing in place.contents)
		if(safe) //we don't want to damage anything, but if there's something here, make sure to keep processing just in case it stops being safe
			return TRUE
		if(thing == parent)
			continue
		if(affect_callback.Invoke(thing, delta_time))
			. = TRUE
