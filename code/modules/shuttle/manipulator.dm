/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/shuttle_manipulator.dmi'
	icon_state = "holograph_on"
	layer = OBJ_LAYER

	density = TRUE
	
/obj/machinery/shuttle_manipulator/update_icon()	
	cut_overlays()	
	var/mutable_appearance/hologram_projection = mutable_appearance(icon, "hologram_on")	
	hologram_projection.pixel_y = 22	
	var/mutable_appearance/hologram_ship = mutable_appearance(icon, "hologram_whiteship")	
	hologram_ship.pixel_y = 27	
	add_overlay(hologram_projection)	
	add_overlay(hologram_ship)