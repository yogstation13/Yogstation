/obj/item/projectile/bullet/honker
	ricochets_max = INFINITY
	reflect_range_decrease = 5
	multiple_hit = TRUE

/obj/item/projectile/bullet/honker/check_ricochet(atom/A)
	if(istype(A, /turf/closed))
		return TRUE
	return FALSE

/obj/item/projectile/bullet/honker/check_ricochet_flag(atom/A)
	return TRUE