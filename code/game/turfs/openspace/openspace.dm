/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon = 'icons/turf/floors.dmi'
	icon_state = "openspace_int"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	plane = ADJUSTING_PLANE(-PLANE_ZLEVEL_OFFSET)
	layer = OPENSPACE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	intact = 0
	FASTDMM_PROP(\
		pipe_astar_cost = 50\
	)
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

/turf/open/openspace/airless
	icon_state = "openspace_ext"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/openspace/debug/update_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	icon = null
	icon_state = ""
	if(edge_openspace) // *we* are the openspace
		QDEL_NULL(edge_openspace)
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	if(update_multiz(TRUE, TRUE))
		for(var/turf/T in orange(1, src)) // orange as in "orange man bad"
			T.add_adjacent_openspace()

/turf/open/openspace/Destroy()
	vis_contents.len = 0
	for(var/turf/T in orange(1, src)) // orange as in "orange man bad"
		T.remove_adjacent_openspace()
	return ..()

/turf/open/openspace/update_multiz(prune_on_fail = FALSE, init = FALSE)
	. = ..()
	var/turf/T = below()
	if(!T)
		vis_contents.len = 0
		if(prune_on_fail)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return FALSE
	if(init)
		vis_contents += T
	return TRUE

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/add_adjacent_openspace()
	adjacent_openspaces++


/turf/open/openspace/remove_adjacent_openspace()
	adjacent_openspaces--

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source)
	if(direction == UP)
		for(var/obj/structure/lattice/catwalk/C in src)
			return FALSE
	return TRUE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	if(direction == DOWN)
		for(var/obj/structure/lattice/catwalk/C in src)
			return FALSE
	return TRUE

/turf/open/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/openspace/attackby(obj/item/C, mob/user, params)
	..()
	if(!CanBuildHere())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, "<span class='warning'>There is already a catwalk here!</span>")
			return
		if(L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a catwalk.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, "<span class='warning'>You need two rods to build a catwalk!</span>")
			return
		if(R.use(1))
			to_chat(user, "<span class='notice'>You construct a lattice.</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		if(!CanCoverUp())
			return
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/open/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a floor.</span>")
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/openspace/icemoon
	name = "ice chasm"
	baseturfs = /turf/open/openspace/icemoon
	can_cover_up = FALSE
	can_build_on = FALSE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/openspace/icemoon/can_zFall(atom/movable/A, levels = 1, turf/target)
	return TRUE

/obj/effect/edge_openspace
	name = null
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ADJUSTING_PLANE(-PLANE_ZLEVEL_OFFSET)
	layer = OPENSPACE_LAYER
	anchored = TRUE // wait wtf they're not anchored by default?

/obj/effect/edge_openspace/Initialize()
	. = ..()
	verbs.Cut()	
