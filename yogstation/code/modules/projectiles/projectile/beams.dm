/obj/item/projectile/beam/emitter/on_hit(atom/target, blocked = FALSE)
	var/turf/T = get_turf(target)
	if(ismineralturf(T) && prob(50))
		var/turf/closed/mineral/M = T
		M.attempt_drill()
	. = ..()
