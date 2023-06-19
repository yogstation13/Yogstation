/obj/mecha/Bump(atom/obstacle)
	if(istype(obstacle, /turf/closed/indestructible)) //no cheesing for you
		return FALSE
	..()
