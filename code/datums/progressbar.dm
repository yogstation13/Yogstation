#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5
#define SKILL_ICON_OFFSET_X -18
#define SKILL_ICON_OFFSET_Y -13

/datum/progressbar
	///The progress bar visual element.
	var/image/bar
	///The icon for the skill used.
	var/image/skill_icon
	///The target where this progress bar is applied and where it is shown.
	var/atom/bar_loc
	///The mob whose client sees the progress bar.
	var/mob/user
	///The client seeing the progress bar.
	var/client/user_client
	///Extra checks for whether to stop the progress.
	var/datum/callback/extra_checks
	///Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	///Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	///Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	///Whether progress has already been ended.
	var/progress_ended = FALSE
	///Which skill this uses
	var/skill_check


/datum/progressbar/New(mob/User, goal_number, atom/target, timed_action_flags = NONE, datum/callback/extra_checks, skill_check)
	. = ..()
	if (!istype(target))
		stack_trace("Invalid target [target] passed in")
		qdel(src)
		return
	if(QDELETED(User) || !istype(User))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] user")
		qdel(src)
		return
	if(!isnum(goal_number))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] goal_number")
		qdel(src)
		return
	goal = goal_number
	bar_loc = target
	bar = image('icons/effects/progessbar.dmi', bar_loc, "prog_bar_0")
	SET_PLANE_EXPLICIT(bar, ABOVE_HUD_PLANE, User) //yogs change, increased so it draws ontop of ventcrawling overlays
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	if(skill_check)
		skill_icon = image('icons/mob/skills.dmi', bar_loc, "[skill_check]_small", pixel_x = SKILL_ICON_OFFSET_X)
		SET_PLANE_EXPLICIT(skill_icon, ABOVE_HUD_PLANE, User)
		skill_icon.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		src.skill_check = skill_check
	user = User
	src.extra_checks = extra_checks

	LAZYADDASSOCLIST(user.progressbars, bar_loc, src)
	var/list/bars = user.progressbars[bar_loc]
	listindex = bars.len

	if(user.client)
		user_client = user.client
		add_prog_bar_image_to_client()

	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_delete))
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(clean_user_client))
	RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(on_user_login))
	if(!(timed_action_flags & IGNORE_USER_LOC_CHANGE))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
		var/obj/mecha/mech = user.loc
		if(ismecha(user.loc) && user == mech.occupant)
			RegisterSignal(mech, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && target != user)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if(!(timed_action_flags & IGNORE_HELD_ITEM))
		var/obj/item/held = user.get_active_held_item()
		if(held)
			RegisterSignal(held, COMSIG_ITEM_EQUIPPED, PROC_REF(end_progress))
			RegisterSignal(held, COMSIG_ITEM_DROPPED, PROC_REF(end_progress))
		else
			RegisterSignal(user, COMSIG_MOB_PICKUP_ITEM, PROC_REF(end_progress))
		RegisterSignal(user, COMSIG_MOB_SWAPPING_HANDS, PROC_REF(end_progress))
	if(!(timed_action_flags & IGNORE_INCAPACITATED))
		if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
			end_progress()
			return
		RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), PROC_REF(end_progress))


/datum/progressbar/Destroy()
	if(user)
		for(var/pb in user.progressbars[bar_loc])
			var/datum/progressbar/progress_bar = pb
			if(progress_bar == src || progress_bar.listindex <= listindex)
				continue
			progress_bar.listindex--

			var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * progress_bar.listindex) - PROGRESSBAR_HEIGHT
			animate(progress_bar.bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

			if(progress_bar.skill_icon)
				animate(progress_bar.skill_icon, pixel_y = dist_to_travel + SKILL_ICON_OFFSET_Y, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

		LAZYREMOVEASSOC(user.progressbars, bar_loc, src)
		user = null

	if(user_client)
		clean_user_client()

	bar_loc = null

	if(bar)
		QDEL_NULL(bar)
	if(skill_icon)
		QDEL_NULL(skill_icon)

	return ..()


///Called right before the user's Destroy()
/datum/progressbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER

	user.progressbars = null //We can simply nuke the list and stop worrying about updating other prog bars if the user itself is gone.
	user = null
	qdel(src)


///Removes the progress bar image from the user_client and nulls the variable, if it exists.
/datum/progressbar/proc/clean_user_client(datum/source)
	SIGNAL_HANDLER

	if(!user_client) //Disconnected, already gone.
		return
	user_client.images -= bar
	user_client.images -= skill_icon
	user_client = null


///Called by user's Login(), it transfers the progress bar image to the new client.
/datum/progressbar/proc/on_user_login(datum/source)
	SIGNAL_HANDLER

	if(user_client)
		if(user_client == user.client) //If this was not client handling I'd condemn this sanity check. But clients are fickle things.
			return
		clean_user_client()
	if(!user.client) //Clients can vanish at any time, the bastards.
		return
	user_client = user.client
	add_prog_bar_image_to_client()


///Adds a smoothly-appearing progress bar image to the player's screen.
/datum/progressbar/proc/add_prog_bar_image_to_client()
	bar.pixel_y = 0
	bar.alpha = 0
	user_client.images += bar
	if(skill_icon)
		skill_icon.pixel_y = SKILL_ICON_OFFSET_Y
		skill_icon.alpha = 0
		user_client.images += skill_icon
		animate(skill_icon, pixel_y = 32 + SKILL_ICON_OFFSET_Y + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)


///Updates the progress bar image visually.
/datum/progressbar/proc/update(progress)
	if(progress_ended)
		return FALSE
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return FALSE
	last_progress = progress
	if(extra_checks && !extra_checks.Invoke())
		return FALSE
	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"
	return TRUE


///Called on progress end, be it successful or a failure. Wraps up things to delete the datum and bar.
/datum/progressbar/proc/end_progress()
	if(progress_ended)
		return
	progress_ended = TRUE

	if(last_progress != goal)
		bar.icon_state = "[bar.icon_state]_fail"
	else if(skill_check) // get better at things by practicing them
		user.add_exp(skill_check, goal)

	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	if(skill_icon)
		animate(skill_icon, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)

/datum/progressbar/proc/on_moved(atom/movable/mover, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change, interrupting)
	SIGNAL_HANDLER
	if(!interrupting)
		return
	if(!mover.Process_Spacemove() && mover.inertia_dir)
		return
	INVOKE_ASYNC(src, PROC_REF(end_progress))

#undef SKILL_ICON_OFFSET_Y
#undef SKILL_ICON_OFFSET_X
#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT
