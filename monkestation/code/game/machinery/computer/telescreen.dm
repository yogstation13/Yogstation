/obj/machinery/computer/security/telescreen/entertainment/update_active_camera_screen()
	. = ..()
	update_spesstv_watcher_list(REF(src), active_camera)

/obj/machinery/computer/security/telescreen/entertainment/Destroy()
	LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
	return ..()

/obj/machinery/computer/security/telescreen/entertainment/atom_break(damage_flag)
	. = ..()
	if(.)
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))

/obj/machinery/computer/security/telescreen/entertainment/power_change()
	. = ..()
	if(!powered())
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
