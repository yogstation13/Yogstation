/atom
	var/image/demo_last_appearance

/atom/Destroy(force)
	demo_last_appearance = null
	return ..()

/atom/movable
	var/atom/demo_last_loc

/atom/movable/Destroy(force)
	demo_last_loc = null
	return ..()

/client/New()
	SSdemo.write_event_line("login [ckey]")
	return ..()

/client/Destroy()
	. = ..()
	SSdemo.write_event_line("logout [ckey]")

/turf/setDir()
	. = ..()
	SSdemo.mark_turf(src)

/atom/movable/setDir()
	. = ..()
	SSdemo.mark_dirty(src)
