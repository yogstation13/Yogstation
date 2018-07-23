/obj/machinery/atmospherics/pipe/manifold/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold_center[invis]"

	cut_overlays()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			add_overlay(getpipeimage(icon, "manifold_full[invis]", get_dir(src, nodes[i])))