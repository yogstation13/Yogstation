/mob/living/Moved()
	. = ..()
	update_turf_movespeed(loc)

/mob/living/CanPass(atom/movable/mover, turf/target)
	if((mover.pass_flags & PASSMOB))
		return TRUE
	if(istype(mover, /obj/item/projectile))
		var/obj/item/projectile/P = mover
		return !P.can_hit_target(src, P.permutated, src == P.original, TRUE)
	if(mover.throwing)
		return (!density || !(mobility_flags & MOBILITY_STAND) || (mover.throwing.thrower == src && !ismob(mover)))
	if(buckled == mover)
		return TRUE
	if(ismob(mover))
		if(mover in buckled_mobs)
			return TRUE
	return (!mover.density || !density || !(mobility_flags & MOBILITY_STAND))

/mob/living/toggle_move_intent()
	. = ..()
	update_move_intent_slowdown()

/mob/living/update_config_movespeed()
	update_move_intent_slowdown()
	return ..()

/mob/living/proc/update_move_intent_slowdown()
	var/mod = 0
	if(m_intent == MOVE_INTENT_WALK)
		mod = CONFIG_GET(number/movedelay/walk_delay)
	else
		mod = CONFIG_GET(number/movedelay/run_delay)
	if(!isnum(mod))
		mod = 1
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = mod)

/mob/living/proc/update_turf_movespeed(turf/open/T)
	if(isopenturf(T) && !is_flying())
		add_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD, TRUE, 100, override = TRUE, multiplicative_slowdown = T.slowdown)
	else
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)

/mob/living/can_zFall(turf/T, levels)
	var/obj/item/tank/jetpack/J
	J = get_jetpack()
	if(J && J.on)
		return FALSE
	return ..()

/mob/living/canZMove(dir, turf/target)
	if(!can_zTravel(target, dir))
		return FALSE
	if((movement_type & FLYING) || !has_gravity(loc))
		return TRUE
	var/obj/item/tank/jetpack/J
	J = get_jetpack()
	if(J && J.on && J.allow_thrust(0.02, src))
		return TRUE
