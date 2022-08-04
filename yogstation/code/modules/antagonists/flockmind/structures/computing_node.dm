/obj/structure/destructible/flock/computer
	name = "weird computer"
	desc = "A weird looking computer."
	flock_id = "Compute node"
	flock_desc = "A computing node that provides compute power to the Flock."
	icon_state = "compute"
	max_integrity = 60
	light_color = "#7BFFFF"
	light_range = 3
	compute_provided = 60

/obj/structure/destructible/flock/computer/Initialize()
	. = ..()
	update_icon(state=0, override=0)

/obj/structure/destructible/flock/computer/update_icon(state=0, override=0)
	cut_overlays()
	SSvis_overlays.add_vis_overlay(src, icon, "compute_screen", FLOAT_LAYER, FLOAT_PLANE, dir)
	SSvis_overlays.add_vis_overlay(src, icon, "compute_display[rand(1,9)]", FLOAT_LAYER, FLOAT_PLANE, dir)

/obj/structure/destructible/flock/computer/mainframe
	name = "big weird computer"
	desc = "It almost looks like a corrupted computer of some kind."
	flock_id = "Major compute node"
	max_integrity = 100
	compute_provided = 180