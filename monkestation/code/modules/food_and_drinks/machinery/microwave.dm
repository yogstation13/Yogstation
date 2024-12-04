/obj/machinery/microwave
	var/dont_eject_after_done = FALSE
	var/can_eject = TRUE

/obj/machinery/microwave/eject(force = FALSE)
	if (!can_eject && !force)
		return
	. = ..()


/obj/machinery/microwave/on_deconstruction()
	eject(force = TRUE)
	return ..()

/obj/machinery/microwave/after_finish_loop(dontopen = FALSE)
	set_light(0)
	soundloop.stop()
	if (!dontopen)
		open()
	else
		update_appearance()

/obj/machinery/microwave/loop(type, time, wait = max(12 - 2 * efficiency, 2), mob/cooker)
	for(var/ingredient in ingredients)
		if (isliving(ingredient))
			var/mob/living/occupant = ingredient
			occupant.adjust_bodytemperature(12, 0, 473)
	. = ..()

// Shamelessly copied from code\modules\recycling\disposal\bin.dm
/obj/machinery/microwave/MouseDrop_T(mob/living/target, mob/living/user)
	if(target.buckled || target.has_buckled_mobs())
		return
	stuff_mob_in(target, user)

// Shamelessly copied from code\modules\recycling\disposal\bin.dm
/obj/machinery/microwave/proc/stuff_mob_in(mob/living/target, mob/living/user)
	if(!istype(target))
		return
	if(user != target && HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(!HAS_TRAIT(target, TRAIT_FEEBLE))
		return
	if(ingredients.len >= max_n_of_items)
		balloon_alert(user, "it's full!")
		return
	if(!isturf(user.loc)) //No magically doing it from inside closets
		return
	if(user == target)
		user.visible_message(span_warning("[user] starts climbing into [src]."), span_notice("You start climbing into [src]..."))
	else
		target.visible_message(span_danger("[user] starts putting [target] into [src]."), span_userdanger("[user] starts putting you into [src]!"))
	if(do_after(user, 2 SECONDS, target))
		if (!loc)
			return
		target.forceMove(src)
		if(user == target)
			user.visible_message(span_warning("[user] climbs into [src]."), span_notice("You climb into [src]."))
			. = TRUE
		else
			target.visible_message(span_danger("[user] places [target] in [src]."), span_userdanger("[user] places you in [src]."))
			log_combat(user, target, "stuffed", addition="into [src]")
			target.LAssailant = WEAKREF(user)
			. = TRUE
		ingredients += target
		update_appearance()

// Shamelessly copied from code\modules\recycling\disposal\bin.dm
/obj/machinery/microwave/relaymove(mob/living/user, direction)
	eject(force=TRUE)

// Shamelessly copied from code\modules\recycling\disposal\bin.dm
/obj/machinery/microwave/container_resist_act(mob/living/user)
	eject(force=TRUE)
