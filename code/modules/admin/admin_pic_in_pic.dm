/obj/screen/movable/pic_in_pic/admin_track
	persistent = TRUE
	var/following_ckey
	var/datum/component/redirect/move_listener

/obj/screen/movable/pic_in_pic/admin_track/Initialize(mapload, target)
	. = ..()
	set_view_size(3, 3, FALSE)
	if(isatom(target))
		set_view_center(target)
	else if(istype(target, /client))
		var/client/C = target
		following_ckey = C.ckey
		set_view_center(C.mob)
		if(!GLOB.ckey_PiP_watchlist[C.ckey])
			GLOB.ckey_PiP_watchlist[C.ckey] = list()
		GLOB.ckey_PiP_watchlist[C.ckey] += src
	else
		return INITIALIZE_HINT_QDEL

/obj/screen/movable/pic_in_pic/admin_track/set_view_center(atom/target, do_refresh = TRUE)
	..()
	if(target)
		if(!move_listener)
			move_listener = target.AddComponent(/datum/component/redirect, COMSIG_MOVABLE_MOVED, CALLBACK(src, .proc/refresh_view))
		else
			target.TakeComponent(move_listener)
			if(QDELING(move_listener))
				move_listener = null

/obj/screen/movable/pic_in_pic/admin_track/Destroy()
	QDEL_NULL(move_listener)
	if(following_ckey)
		var/list/L = GLOB.ckey_PiP_watchlist[following_ckey]
		L -= src
		if(!L.len)
			GLOB.ckey_PiP_watchlist -= following_ckey
	return ..()

/obj/screen/movable/pic_in_pic/admin_track/make_backgrounds()
	standard_background = new /mutable_appearance()
	standard_background.icon = 'icons/misc/pic_in_pic.dmi'
	standard_background.icon_state = "background_thin"
	standard_background.layer = HUD_LAYER