/turf/open/floor
	var/psi_null

/turf/open/floor/disrupts_psionics()
	return (psi_null ? src : FALSE)

/turf/open/floor/nullglass
	name = "nullglass plating"
	desc = "You can hear the tiles whispering..."
	icon_state = "light_off"
	psi_null = TRUE
	floor_tile = /obj/item/stack/tile/mineral/nullglass

/obj/item/stack/tile/mineral/nullglass
	name = "nullglass floor tile"
	icon_state = "tile_e"
	turf_type = /turf/open/floor/nullglass
