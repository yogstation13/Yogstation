/obj/structure/transit_tube_pod/cargo
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "pod_cargo"
	cargo = TRUE
	name = "transit tube cargo pod"

/obj/structure/transit_tube_pod/cargo/update_icon()
	if(contents.len)
		icon_state = "pod_cargo_occupied"
	else
		icon_state = "pod_cargo"

/obj/structure/transit_tube_pod/cargo/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/atom/location = get_turf(src)
		if(user)
			location = user.loc
			add_fingerprint(user)
			user.visible_message("[user] removes [src].", "<span class='notice'>You remove [src].</span>")
		var/obj/structure/c_transit_tube_pod/cargo/R = new/obj/structure/c_transit_tube_pod/cargo(location)
		transfer_fingerprints_to(R)
		R.setDir(dir)
		empty_pod(location)
	qdel(src)
