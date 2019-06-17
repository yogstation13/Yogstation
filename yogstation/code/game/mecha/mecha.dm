/obj/mecha/Bump(var/atom/obstacle)
	if(istype(obstacle, /turf/closed/indestructible)) //no cheesing for you
		return FALSE
	..()