// Used by /turf/open/chasm and subtypes to implement the "dropping" mechanic
/datum/component/chasm
	var/turf/target_turf
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

/datum/component/chasm/proc/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	falling_atoms[AM] = (falling_atoms[AM] || 0) + 1
	var/turf/T = target_turf

	if(T)
		// send to the turf below
		AM.visible_message(span_boldwarning("[AM] falls into [parent]!"), span_userdanger("[fall_message]"))
		T.visible_message(span_boldwarning("[AM] falls from above!"))
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Paralyze(100)
			L.adjustBruteLoss(30)
		falling_atoms -= AM

	else
		// send to oblivion
		AM.visible_message(span_boldwarning("[AM] falls into [parent]!"), span_userdanger("[oblivion_message]"))
		if (isliving(AM))
			var/mob/living/L = AM
			L.notransform = TRUE
			L.Stun(200)
			L.resting = TRUE

		var/oldtransform = AM.transform
		var/oldcolor = AM.color
		var/oldalpha = AM.alpha
		animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 1 SECONDS)
		for(var/i in 1 to 5)
			//Make sure the item is still there after our sleep
			if(!AM || QDELETED(AM))
				return
			AM.pixel_y--
			sleep(0.2 SECONDS)

		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return

		if(iscyborg(AM))
			var/mob/living/silicon/robot/S = AM
			qdel(S.mmi)

		falling_atoms -= AM
		if (isliving(AM)) //living mobs get added to the contents of the chasm
			var/atom/parent = src.parent
			AM.forceMove(parent)
			AM.alpha = oldalpha
			AM.color = oldcolor
			AM.transform = oldtransform
			var/mob/living/L = AM
			L.Paralyze(100)
			L.adjustBruteLoss(400)
			var/obj/item/bodypart/l_leg = L.get_bodypart(BODY_ZONE_L_LEG)
			var/datum/wound/blunt/critical/l_fracture = new
			l_fracture.apply_wound(l_leg)
			var/obj/item/bodypart/r_leg = L.get_bodypart(BODY_ZONE_R_LEG)
			var/datum/wound/blunt/critical/r_fracture = new
			r_fracture.apply_wound(r_leg)
		else
			qdel(AM) //everything else DIES
			if(AM && !QDELETED(AM))	//It's indestructible
				var/atom/parent = src.parent
				parent.visible_message(span_boldwarning("[parent] spits out [AM]!"))
				AM.alpha = oldalpha
				AM.color = oldcolor
				AM.transform = oldtransform
				AM.throw_at(get_edge_target_turf(parent,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))

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
			M.forceMove(get_turf(parent))
			found = TRUE
		if(found)
			to_chat(user, span_warning("You reel in something!"))
		else
			to_chat(user, span_warning("There's nothing here!"))
	return
		

