/datum/component/lock_on_cursor/Initialize(lock_cursor_range,
	lock_amount,
	list/target_typecache,
	list/immune,
	icon,
	icon_state,
	datum/callback/on_click_callback,
	datum/callback/on_lock,
	datum/callback/can_target_callback,
	catcher_default_click)
	. = ..()
	mouse_tracker.default_click = catcher_default_click
