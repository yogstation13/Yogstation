/atom/movable
	var/can_buckle = 0
	var/buckle_lying = -1 //bed-like behaviour, forces mob.lying = buckle_lying if != -1
	var/buckle_requires_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/list/mob/living/buckled_mobs = null //list()
	var/max_buckled_mobs = 1
	var/buckle_prevents_pull = FALSE

//Interaction
/atom/movable/attack_robot(mob/living/user)
	. = ..()
	if(.)
		return
	if(Adjacent(user) && can_buckle && has_buckled_mobs())
		if(buckled_mobs.len > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?","Unbuckle Who?") as null|mob in buckled_mobs
			if(user_unbuckle_mob(unbuckled, user))
				return 1
		else
			if(user_unbuckle_mob(buckled_mobs[1], user))
				return 1

/atom/movable/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(can_buckle && has_buckled_mobs())
		if(buckled_mobs.len > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?","Unbuckle Who?") as null|mob in buckled_mobs
			if(user_unbuckle_mob(unbuckled,user))
				return 1
		else
			if(user_unbuckle_mob(buckled_mobs[1],user))
				return 1

/atom/movable/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M) && istype(user))
		if(user_buckle_mob(M, user))
			return 1

/atom/movable/proc/has_buckled_mobs()
	if(!buckled_mobs)
		return FALSE
	if(buckled_mobs.len)
		return TRUE

/**
 * Set a mob as buckled to src
 *
 * If you want to have a mob buckling another mob to something, or you want a chat message sent, use user_buckle_mob instead.
 * Arguments:
 * M - The mob to be buckled to src
 * force - Set to TRUE to ignore src's can_buckle and M's can_buckle_to
 * check_loc - Set to FALSE to allow buckling from adjacent turfs, or TRUE if buckling is only allowed with src and M on the same turf.
 * buckle_mob_flags- Used for riding cyborgs and humans if we need to reserve an arm or two on either the rider or the ridden mob.
 */
/atom/movable/proc/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(!buckled_mobs)
		buckled_mobs = list()

	if(!istype(M))
		return FALSE

	if(check_loc && M.loc != loc)
		return FALSE

	if((!can_buckle && !force) || M.buckled || (buckled_mobs.len >= max_buckled_mobs) || (buckle_requires_restraints && !M.restrained()) || M == src)
		return FALSE
	M.buckling = src
	if(!M.can_buckle() && !force)
		if(M == usr)
			to_chat(M, span_warning("You are unable to buckle yourself to [src]!"))
		else
			to_chat(usr, span_warning("You are unable to buckle [M] to [src]!"))
		M.buckling = null
		return FALSE

	// This signal will check if the mob is mounting this atom to ride it. There are 3 possibilities for how this goes
	//	1. This movable doesn't have a ridable element and can't be ridden, so nothing gets returned, so continue on
	//	2. There's a ridable element but we failed to mount it for whatever reason (maybe it has no seats left, for example), so we cancel the buckling
	//	3. There's a ridable element and we were successfully able to mount, so keep it going and continue on with buckling
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PREBUCKLE, M, force, buckle_mob_flags) & COMPONENT_BLOCK_BUCKLE)
		return FALSE

	if(M.pulledby)
		if(buckle_prevents_pull)
			M.pulledby.stop_pulling()
		else if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.reset_pull_offsets(M, TRUE)

	if(!check_loc && M.loc != loc)
		M.forceMove(loc)

	M.buckling = null
	M.buckled = src
	M.setDir(dir)
	buckled_mobs |= M
	M.update_mobility()
	M.throw_alert("buckled", /atom/movable/screen/alert/restrained/buckled)
	M.set_glide_size(glide_size)
	post_buckle_mob(M)

	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, M, force)
	return TRUE

/obj/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	. = ..()
	if(.)
		if(resistance_flags & ON_FIRE) //Sets the mob on fire if you buckle them to a burning atom/movableect
			M.adjust_fire_stacks(1)
			M.IgniteMob()

/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(istype(buckled_mob) && buckled_mob.buckled == src && (buckled_mob.can_unbuckle() || force))
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_mobility()
		buckled_mob.clear_alert("buckled")
		buckled_mob.set_glide_size(DELAY_TO_GLIDE_SIZE(buckled_mob.total_multiplicative_slowdown()))
		buckled_mobs -= buckled_mob
		SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)

		post_unbuckle_mob(.)

/atom/movable/proc/unbuckle_all_mobs(force=FALSE)
	if(!has_buckled_mobs())
		return
	for(var/m in buckled_mobs)
		unbuckle_mob(m, force)

//Handle any extras after buckling
//Called on buckle_mob()
/atom/movable/proc/post_buckle_mob(mob/living/M)

//same but for unbuckle
/atom/movable/proc/post_unbuckle_mob(mob/living/M)

/**
 * Simple helper proc that runs a suite of checks to test whether it is possible or not to buckle the target mob to src.
 *
 * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
 * Called from [/atom/movable/proc/buckle_mob] and [/atom/movable/proc/is_user_buckle_possible].
 * Arguments:
 * * target - Target mob to check against buckling to src.
 * * force - Whether or not the buckle should be forced. If TRUE, ignores src's can_buckle var and target's can_buckle_to
 * * check_loc - TRUE if target and src have to be on the same tile, FALSE if they are allowed to just be adjacent
 */
/atom/movable/proc/is_buckle_possible(mob/living/target, force = FALSE, check_loc = TRUE)
	// Make sure target is mob/living
	if(!istype(target))
		return FALSE

	// No bucking you to yourself.
	if(target == src)
		return FALSE

	// Check if this atom can have things buckled to it.
	if(!can_buckle && !force)
		return FALSE

	// If we're checking the loc, make sure the target is on the thing we're bucking them to.
	if(check_loc && target.loc != loc)
		return FALSE

	// Make sure the target isn't already buckled to something.
	if(target.buckled)
		return FALSE

	// Make sure this atom can still have more things buckled to it.
	if(LAZYLEN(buckled_mobs) >= max_buckled_mobs)
		return FALSE

	// Stacking buckling leads to lots of jank and issues, better to just nix it entirely
	if(target.has_buckled_mobs())
		return FALSE

	// If the buckle requires restraints, make sure the target is actually restrained.
	if(buckle_requires_restraints && !HAS_TRAIT(target, TRAIT_RESTRAINED))
		return FALSE

	//If buckling is forbidden for the target, cancel
	if(!target.can_buckle_to && !force)
		return FALSE

	return TRUE

/**
 * Simple helper proc that runs a suite of checks to test whether it is possible or not for user to buckle target mob to src.
 *
 * Returns FALSE if any conditions that should prevent buckling are satisfied. Returns TRUE otherwise.
 * Called from [/atom/movable/proc/user_buckle_mob].
 * Arguments:
 * * target - Target mob to check against buckling to src.
 * * user - The mob who is attempting to buckle the target to src.
 * * check_loc - TRUE if target and src have to be on the same tile, FALSE if buckling is allowed from adjacent tiles
 */
/atom/movable/proc/is_user_buckle_possible(mob/living/target, mob/user, check_loc = TRUE)
	// Standard adjacency and other checks.
	if(!Adjacent(user) || !Adjacent(target) || !isturf(user.loc) || user.incapacitated() || target.anchored)
		return FALSE

	// In buckling even possible in the first place?
	if(!is_buckle_possible(target, FALSE, check_loc))
		return FALSE

	return TRUE

/**
 * Handles a mob buckling another mob to src and sends a visible_message
 *
 * Basically exists to do some checks on the user and then call buckle_mob where the real buckling happens.
 * First, checks if the buckle is valid and cancels if it isn't.
 * Second, checks if src is on a different turf from the target; if it is, does a do_after and another check for sanity
 * Finally, calls [/atom/movable/proc/buckle_mob] to buckle the target to src then gives chat feedback
 * Arguments:
 * * M - The target mob/living being buckled to src
 * * user - The other mob that's buckling M to src
 * * check_loc - TRUE if src and M have to be on the same turf, false otherwise
 */
/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !isturf(user.loc) || user.incapacitated() || M.anchored)
		return FALSE

	add_fingerprint(user)
	. = buckle_mob(M, check_loc = check_loc)
	if(.)
		if(M == user)
			M.visible_message(\
				span_notice("[M] buckles [M.p_them()]self to [src]."),\
				span_notice("You buckle yourself to [src]."),\
				span_italics("You hear metal clanking."))
		else
			M.visible_message(\
				span_warning("[user] buckles [M] to [src]!"),\
				span_warning("[user] buckles you to [src]!"),\
				span_italics("You hear metal clanking."))

/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	var/mob/living/M = unbuckle_mob(buckled_mob)
	if(M)
		if(M != user)
			M.visible_message(\
				span_notice("[user] unbuckles [M] from [src]."),\
				span_notice("[user] unbuckles you from [src]."),\
				span_italics("You hear metal clanking."))
		else
			M.visible_message(\
				span_notice("[M] unbuckles [M.p_them()]self from [src]."),\
				span_notice("You unbuckle yourself from [src]."),\
				span_italics("You hear metal clanking."))
		add_fingerprint(user)
		if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.set_pull_offsets(M, L.grab_state)
	return M
