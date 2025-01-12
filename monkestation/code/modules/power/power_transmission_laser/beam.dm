/obj/effect/transmission_beam
	name = "Shimmering beam"
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "ptl_beam"
	anchored = TRUE

	///used to deal with atoms stepping on us while firing
	var/obj/machinery/power/transmission_laser/host

/obj/effect/transmission_beam/Initialize(mapload, obj/machinery/power/transmission_laser/host)
	. = ..()
	if(!istype(host))
		stack_trace("PTL beam initialized without PTL!")
		return INITIALIZE_HINT_QDEL
	src.host = host
	setDir(host.dir)
	host.laser_effects += src
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/transmission_beam/Destroy(force)
	host?.laser_effects -= src
	host = null
	return ..()

/obj/effect/transmission_beam/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "ptl_beam", src)

/obj/effect/transmission_beam/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	host.atom_entered_beam(src, arrived)
