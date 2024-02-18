/obj/effect/portal/permanent/teleport(atom/movable/M, force = FALSE) // Made perma portals always teleport even in noteleport areas since they are mapmaker only
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE
	if(!force && (!ismecha(M) && !istype(M, /obj/projectile) && M.anchored && !allow_anchored))
		return
	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)] made by [usr].")
	var/no_effect = FALSE
	if(last_effect == world.time)
		no_effect = TRUE
	else
		last_effect = world.time
	if(do_teleport(M, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, forced = TRUE))
		if(istype(M, /obj/projectile))
			var/obj/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE

/obj/effect/portal/permanent/one_way/multi // Portals that have multiple entry points and multiple exit points
	name = "strange portal"
	desc = "You're not really sure where this could possibly go."
	var/is_entry // Marks whether this is an entry portal or not
	var/list/linked_targets = list() // List of ***TURFS*** that mark where exit portals were on mapboot

/obj/effect/portal/permanent/one_way/multi/entry
	is_entry = TRUE

/obj/effect/portal/permanent/one_way/multi/exit
	is_entry = FALSE

/obj/effect/portal/permanent/one_way/multi/set_linked()
	return

/obj/effect/portal/permanent/one_way/multi/get_link_target_turf()
	while(linked_targets.len)
		var/turf/target = pick(linked_targets)
		if(!istype(target))
			linked_targets -= target
			continue
		return target
