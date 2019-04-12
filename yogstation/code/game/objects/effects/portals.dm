/obj/effect/portal/permanent/teleport(atom/movable/M, force = FALSE) // Made perma portals always teleport even in noteleport areas since they are mapmaker only
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE
	if(!force && (!ismecha(M) && !istype(M, /obj/item/projectile) && M.anchored && !allow_anchored))
		return
	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)] made by [usr].")
	var/no_effect = FALSE
	if(last_effect == world.time)
		no_effect = TRUE
	else
		last_effect = world.time
	if(do_teleport(M, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, forced = TRUE))
		if(istype(M, /obj/item/projectile))
			var/obj/item/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE