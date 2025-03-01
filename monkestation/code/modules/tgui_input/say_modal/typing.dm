/** Creates a thinking indicator over the mob. */
/mob/create_thinking_indicator(channel)
	var/bubble_icon = channel == LOOC_CHANNEL ? "looc" : src.bubble_icon

	if(active_thinking_indicator || active_typing_indicator || !thinking_IC || (isliving(src) && stat > SOFT_CRIT) )
		return FALSE
	active_thinking_indicator = image('icons/mob/effects/talk.dmi', src, "[bubble_icon]3", TYPING_LAYER)
	add_typing_overlay(active_thinking_indicator)

/** Removes the thinking indicator over the mob. */
/mob/remove_thinking_indicator()
	if(!active_thinking_indicator)
		return FALSE
	remove_typing_overlay(active_thinking_indicator)
	active_thinking_indicator = null

/** Creates a typing indicator over the mob. */
/mob/create_typing_indicator(channel)
	var/bubble_icon = channel == LOOC_CHANNEL ? "looc" : src.bubble_icon

	if(active_typing_indicator || active_thinking_indicator || !thinking_IC || (isliving(src) && stat > SOFT_CRIT))
		return FALSE
	active_typing_indicator = image('icons/mob/effects/talk.dmi', src, "[bubble_icon]0", TYPING_LAYER)
	add_typing_overlay(active_typing_indicator)


/** Removes the typing indicator over the mob. */
/mob/remove_typing_indicator()
	if(!active_typing_indicator)
		return FALSE
	remove_typing_overlay(active_typing_indicator)
	active_typing_indicator = null

/** Removes any indicators and marks the mob as not speaking IC. */
/mob/remove_all_indicators()
	thinking_IC = FALSE
	remove_thinking_indicator()
	remove_typing_indicator()

/mob/proc/add_typing_overlay(image)
	add_overlay(image)
	play_fov_effect(src, 6, "talk", ignore_self = TRUE)

/mob/proc/remove_typing_overlay(image)
	cut_overlay(image)
