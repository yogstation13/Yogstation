//For runtime portal making, aka admin abuse :)
GLOBAL_LIST_EMPTY(custom_portals)

/obj/effect/custom_portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	color = "#8b008b"
	anchored = TRUE
	///The portal ID we are linked to
	var/linked_to
	///Our ID
	var/portal_id
	///Can mechs walk through?
	var/mech_sized = FALSE
	///Last time we did the flickering effect thing when people walk through
	var/last_effect = 0


/obj/effect/custom_portal/Initialize(mapload)
	. = ..()
	GLOB.custom_portals += src

/obj/effect/custom_portal/Destroy()
	GLOB.custom_portals -= src
	return ..()

/obj/effect/custom_portal/singularity_pull()
	return

/obj/effect/custom_portal/singularity_act()
	return

/obj/effect/custom_portal/attack_ghost(mob/dead/observer/O)
	if(!teleport(O, TRUE))
		return ..()

/obj/effect/custom_portal/proc/teleport(atom/movable/M, force = FALSE)
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (!isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!real_target)
		to_chat(M, "<span class='warning'>This portal has no linked portal!</span>")
	if(!force && (!ismecha(M) && !istype(M, /obj/item/projectile) && M.anchored))
		return
	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)] made by [usr].")
	var/no_effect = FALSE
	if(last_effect == world.time)
		no_effect = TRUE
	else
		last_effect = world.time
	if(do_teleport(M, real_target, 0, no_effects = no_effect, channel = TELEPORT_CHANNEL_QUANTUM, forced = TRUE))
		if(istype(M, /obj/item/projectile))
			var/obj/item/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE

/obj/effect/custom_portal/proc/get_link_target_turf()
	var/turf/real_target
	var/list/matching_portals = list()
	if(!linked_to)
		return
	for(var/PU in GLOB.custom_portals)
		var/obj/effect/custom_portal/P = PU
		if(P.portal_id == linked_to)
			matching_portals += P

	var/obj/effect/custom_portal/picked = pick(matching_portals)
	if(picked)
		real_target = get_turf(picked)
		return real_target

/obj/effect/custom_portal/Move(newloc)
	for(var/T in newloc)
		if(istype(T, /obj/effect/custom_portal))
			return FALSE
	return ..()

/obj/effect/custom_portal/attackby(obj/item/W, mob/user, params)
	if(user && Adjacent(user))
		user.forceMove(get_turf(src))
		return TRUE

/obj/effect/custom_portal/Crossed(atom/movable/AM, oldloc, force_stop = 0)
	if(force_stop)
		return ..()
	if(isobserver(AM))
		return ..()
	var/turf/T = get_link_target_turf()
	if(T && (get_turf(oldloc) == T))
		return ..()
	if(!teleport(AM))
		return ..()

/obj/effect/custom_portal/attack_tk(mob/user)
	return

/obj/effect/custom_portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(get_turf(user) == get_turf(src))
		teleport(user)
	if(Adjacent(user))
		user.forceMove(get_turf(src))


/obj/effect/custom_portal/a
	color = "#00ff00"

	linked_to = "b"
	portal_id = "a"

/obj/effect/custom_portal/b
	color = null

	icon_state = "portal1"
	linked_to = "a"
	portal_id = "b"
