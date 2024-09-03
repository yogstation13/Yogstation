//from mojave sun

/obj/effect/turf_decal/road
	icon = 'icons/effects/road_decals.dmi'

/obj/effect/turf_decal/road/Initialize(mapload)
	. = ..()
	if(prob(35))
		icon_state = "[initial(icon_state)]-[rand(1,2)]"

/obj/effect/turf_decal/road/horizontalline
	icon_state = "horizontal_line"

/obj/effect/turf_decal/road/verticalline
	icon_state = "vertical_line"

/obj/effect/turf_decal/road/horizontalcrossing
	icon_state = "horizontal_crossing"

/obj/effect/turf_decal/road/verticalcrossing
	icon_state = "vertical_crossing"

// Street drains

/obj/effect/turf_decal/road/drain
	icon_state = "drain"
