// Used by /turf/open/chasm and subtypes to implement the "dropping" mechanic
/datum/component/chasm
	var/turf/target_turf
	var/obj/effect/abstract/chasm_storage/storage
	var/fall_message = "GAH! Ah... where are you?"
	var/oblivion_message = "You stumble and stare into the abyss before you. It stares back, and you fall into the enveloping dark."

	var/static/list/falling_atoms = list() // Atoms currently falling into chasms
	var/static/list/forbidden_types = typecacheof(list(
		/obj/singularity,
		/obj/docking_port,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/item/projectile,
		/obj/effect/projectile,
		/obj/effect/portal,
		/obj/effect/abstract,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/temp_visual,
		/obj/effect/light_emitter/tendril,
		/obj/effect/collapse,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/dummy/phased_mob,
		/obj/effect/dummy/crawling //yogs
		))

/datum/component/chasm/Initialize(turf/target)
	RegisterSignals(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Entered)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY,.proc/fish)
	target_turf = target
	START_PROCESSING(SSobj, src) // process on create, in case stuff is still there

/datum/component/chasm/proc/Entered(datum/source, atom/movable/AM)
	START_PROCESSING(SSobj, src)
	drop_stuff(AM)

/datum/component/chasm/process()
	if (!drop_stuff())
		STOP_PROCESSING(SSobj, src)

/datum/component/chasm/proc/is_safe()
	//if anything matching this typecache is found in the chasm, we don't drop things
	var/static/list/chasm_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))

	var/atom/parent = src.parent
	var/list/found_safeties = typecache_filter_list(parent.contents, chasm_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/datum/component/chasm/proc/drop_stuff(AM)
	. = 0
	if (is_safe())
		return FALSE

	var/atom/parent = src.parent
	var/to_check = AM ? list(AM) : parent.contents
	for (var/thing in to_check)
		if (droppable(thing))
			. = 1
			INVOKE_ASYNC(src, .proc/drop, thing)

/datum/component/chasm/proc/droppable(atom/movable/AM)
	// avoid an infinite loop, but allow falling a large distance
	if(falling_atoms[AM] && falling_atoms[AM] > 30)
		return FALSE
	if(!isliving(AM) && !isobj(AM))
		return FALSE
	if(is_type_in_typecache(AM, forbidden_types) || AM.throwing || (AM.movement_type & FLOATING))
		return FALSE
	//Flies right over the chasm
	if(ismob(AM))
		var/mob/M = AM
		if(M.buckled)		//middle statement to prevent infinite loops just in case!
			var/mob/buckled_to = M.buckled
			if((!ismob(M.buckled) || (buckled_to.buckled != M)) && !droppable(M.buckled))
				return FALSE
		if(M.is_flying())
			return FALSE
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			for(var/obj/item/wormhole_jaunter/J in H.GetAllContents())
				//To freak out any bystanders
				H.visible_message(span_boldwarning("[H] falls into [parent]!"))
				J.chasm_react(H)
				return FALSE
	return TRUE

/datum/component/chasm/proc/drop(atom/movable/dropped_thing)
	var/datum/weakref/falling_ref = WEAKREF(dropped_thing)
	//Make sure the item is still there after our sleep
	if(!dropped_thing || !falling_ref?.resolve())
		falling_atoms -= falling_ref
		return
	falling_atoms[falling_ref] = (falling_atoms[falling_ref] || 0) + 1
	var/turf/T = target_turf
	var/atom/parent = src.parent

	if(T)
		// send to the turf below
		dropped_thing.visible_message(span_boldwarning("[dropped_thing] falls into [parent]!"), span_userdanger("[fall_message]"))
		T.visible_message(span_boldwarning("[dropped_thing] falls from above!"))
		dropped_thing.forceMove(T)
		if(isliving(dropped_thing))
			var/mob/living/L = dropped_thing
			L.Paralyze(100)
			L.adjustBruteLoss(30)
		falling_atoms -= falling_ref
		return

	// send to oblivion
	dropped_thing.visible_message(span_boldwarning("[dropped_thing] falls into [parent]!"), span_userdanger("[oblivion_message]"))
	if (isliving(dropped_thing))
		var/mob/living/falling_mob = dropped_thing
		falling_mob.notransform = TRUE
		falling_mob.Paralyze(20 SECONDS)

	var/oldtransform = dropped_thing.transform
	var/oldcolor = dropped_thing.color
	var/oldalpha = dropped_thing.alpha

	animate(dropped_thing, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!dropped_thing || QDELETED(dropped_thing))
			return
		dropped_thing.pixel_y--
		sleep(0.2 SECONDS)

	//Make sure the item is still there after our sleep
	if(!dropped_thing || QDELETED(dropped_thing))
		return

	if (!storage)
		storage = new(get_turf(parent))
		RegisterSignal(storage, COMSIG_ATOM_EXITED, .proc/left_chasm)

	if (storage.contains(dropped_thing))
		return

	dropped_thing.alpha = oldalpha
	dropped_thing.color = oldcolor
	dropped_thing.transform = oldtransform

	if (dropped_thing.forceMove(storage))
		if (isliving(dropped_thing))
			RegisterSignal(dropped_thing, COMSIG_LIVING_REVIVE, .proc/on_revive)
	else
		parent.visible_message(span_boldwarning("[parent] spits out [dropped_thing]!"))
		dropped_thing.throw_at(get_edge_target_turf(parent, pick(GLOB.alldirs)), rand(1, 10), rand(1, 10))

	if (isliving(dropped_thing))
		var/mob/living/fallen_mob = dropped_thing
		if(fallen_mob.stat != DEAD)
			fallen_mob.death(TRUE)
			fallen_mob.notransform = FALSE
			fallen_mob.apply_damage(300)
			var/obj/item/bodypart/l_leg = fallen_mob.get_bodypart(BODY_ZONE_L_LEG)
			var/datum/wound/blunt/critical/l_fracture = new
			l_fracture.apply_wound(l_leg)
			var/obj/item/bodypart/r_leg = fallen_mob.get_bodypart(BODY_ZONE_R_LEG)
			var/datum/wound/blunt/critical/r_fracture = new
			r_fracture.apply_wound(r_leg)

	falling_atoms -= falling_ref

/**
 * Called when something has left the chasm depths storage.
 * Arguments
 *
 * * source - Chasm object holder.
 * * gone - Item which has just left the chasm contents.
 */
/datum/component/chasm/proc/left_chasm(atom/source, atom/movable/gone)
	SIGNAL_HANDLER
	UnregisterSignal(gone, COMSIG_LIVING_REVIVE)

#define CHASM_TRAIT "chasm trait"

/**
 * Called if something comes back to life inside the pit. Expected sources are badmins and changelings.
 *
 * Arguments
 * * escapee - Lucky guy who just came back to life at the bottom of a hole.
 */
/datum/component/chasm/proc/on_revive(mob/living/escapee)
	var/atom/parent = src.parent
	parent.visible_message(span_boldwarning("After a long climb, [escapee] leaps out of [parent]!"))
	escapee.movement_type &= FLYING
	escapee.forceMove(get_turf(parent))
	escapee.throw_at(get_edge_target_turf(parent, pick(GLOB.alldirs)), rand(1, 10), rand(1, 10))
	escapee.movement_type &= ~FLYING
	escapee.Paralyze(20 SECONDS, TRUE)
	UnregisterSignal(escapee, COMSIG_LIVING_REVIVE)

#undef CHASM_TRAIT

/**
 * An abstract object which is basically just a bag that the chasm puts people inside
 */
/obj/effect/abstract/chasm_storage
	name = "chasm depths"
	desc = "The bottom of a hole. You shouldn't be able to interact with this."
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/component/chasm/proc/fish(datum/source, obj/item/I, mob/user, params)
	if(!istype(I,/obj/item/twohanded/fishingrod))
		return
	var/obj/item/twohanded/fishingrod/rod = I
	if(!rod.wielded)
		to_chat(user, span_warning("You need to wield the rod in both hands before you can fish in the chasm!"))
		return
	if(do_after(user, 3 SECONDS, src.parent))
		if(!rod.wielded)
			return
		var/atom/parent = src.parent
		var/list/fishing_contents = parent.GetAllContents()
		if(!length(fishing_contents))
			to_chat(user, span_warning("There's nothing here!"))
			return
		var/found = FALSE
		for(var/mob/M in fishing_contents) //since only mobs can fall in here this really isnt needed but on the off chance something naughty happens..
			M.forceMove(get_turf(user))
			UnregisterSignal(M, COMSIG_LIVING_REVIVE)
			found = TRUE
		if(found)
			to_chat(user, span_warning("You reel in something!"))
		else
			to_chat(user, span_warning("There's nothing here!"))
	return
