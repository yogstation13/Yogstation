/obj/structure/plasticflaps
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps. Definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	armor = list(MELEE = 100, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 50, BIO = 100, RAD = 100, FIRE = 50, ACID = 50, ELECTRIC = 100)
	density = FALSE
	anchored = TRUE
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	alpha = 0
	gen_overlay()
	air_update_turf()

/obj/structure/plasticflaps/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(same_z_layer)
		return ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	gen_overlay()
	return ..()

/obj/structure/plasticflaps/proc/gen_overlay()
	var/turf/our_turf = get_turf(src)
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, MUTATE_PLANE(GAME_PLANE, our_turf), dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it


/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("[src] are <b>screwed</b> to the floor.")
	else
		. += span_notice("[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>cut</b> apart.")

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	add_fingerprint(user)
	var/action = anchored ? "unscrews [src] from" : "screws [src] to"
	var/uraction = anchored ? "unscrew [src] from" : "screw [src] to"
	user.visible_message(span_warning("[user] [action] the floor."), span_notice("You start to [uraction] the floor..."), "You hear rustling noises.")
	if(!W.use_tool(src, user, 100, volume=100, extra_checks = CALLBACK(src, PROC_REF(check_anchored_state), anchored)))
		return TRUE
	setAnchored(!anchored)
	update_atmos_behaviour()
	air_update_turf()
	to_chat(user, span_notice(" You [anchored ? "unscrew" : "screw"] [src] from the floor."))
	return TRUE

///Update the flaps behaviour to gases, if not anchored will let air pass through
/obj/structure/plasticflaps/proc/update_atmos_behaviour()
	can_atmos_pass = anchored ? ATMOS_PASS_YES : ATMOS_PASS_NO

/obj/structure/plasticflaps/wirecutter_act(mob/living/user, obj/item/W)
	if(!anchored)
		user.visible_message(span_warning("[user] cuts apart [src]."), span_notice("You start to cut apart [src]."), "You hear cutting.")
		if(W.use_tool(src, user, 50, volume=100))
			if(anchored)
				return TRUE
			to_chat(user, span_notice("You cut apart [src]."))
			var/obj/item/stack/sheet/plastic/five/P = new(loc)
			P.add_fingerprint(user)
			qdel(src)
			return TRUE
		else
			return TRUE

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	if(anchored != check_anchored)
		return FALSE
	return TRUE

/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller_but_not_a_byond_built_in_proc)
	if(isliving(caller_but_not_a_byond_built_in_proc))
		if(isbot(caller_but_not_a_byond_built_in_proc))
			return TRUE

		var/mob/living/M = caller_but_not_a_byond_built_in_proc
		if(!M.ventcrawler && M.mob_size != MOB_SIZE_TINY)
			return FALSE
	var/atom/movable/M = caller_but_not_a_byond_built_in_proc
	if(M && M.pulling)
		return CanAStarPass(ID, to_dir, M.pulling)
	return TRUE //diseases, stings, etc can pass

/obj/structure/plasticflaps/CanAllowThrough(atom/movable/A, turf/T)
	. = ..()

	if(istype(A) && (A.pass_flags & PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))//if it's a bed/chair and is dense or someone is buckled, it will not pass
		return FALSE

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return FALSE

	if(ismecha(A))
		return FALSE

	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if(isbot(A)) //Bots understand the secrets
			return TRUE
		if(M.buckled && istype(M.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE
		if((M.mobility_flags & MOBILITY_STAND) && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf()
