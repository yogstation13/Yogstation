
/proc/create_portal_pair(turf/source, turf/destination, _creator = null, _lifespan = 300, accuracy = 0, newtype = /obj/effect/portal, atmos_link_override)
	if(!istype(source) || !istype(destination))
		return
	var/turf/actual_destination = get_teleport_turf(destination, accuracy)
	var/obj/effect/portal/P1 = new newtype(source, _creator, _lifespan, null, FALSE, null, atmos_link_override)
	var/obj/effect/portal/P2 = new newtype(actual_destination, _creator, _lifespan, P1, TRUE, null, atmos_link_override)
	if(!istype(P1)||!istype(P2))
		return
	P1.link_portal(P2)
	P1.hardlinked = TRUE
	return list(P1, P2)

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = TRUE
	density = TRUE // dense for receiving bumbs
	layer = HIGH_OBJ_LAYER
	light_system = STATIC_LIGHT
	light_range = 3
	light_power = 1
	light_on = TRUE
	light_color = COLOR_BLUE_LIGHT
	/// Are mechs able to enter this portal?
	var/mech_sized = FALSE
	/// A reference to another "linked" destination portal
	var/obj/effect/portal/linked
	/// Requires a linked portal at all times. Destroy if there's no linked portal, if there is destroy it when this one is deleted.
	var/hardlinked = TRUE
	/// What teleport channel does this portal use?
	var/teleport_channel = TELEPORT_CHANNEL_BLUESPACE
	var/creator
	/// For when a portal needs a hard target and isn't to be linked.
	var/turf/hard_target
	/// Do we teleport anchored objects?
	var/allow_anchored = FALSE
	/// What precision value do we pass to do_teleport (how far from the target destination we will pop out at).
	var/innate_accuracy_penalty = 0
	/// Used to track how often sparks should be output. Might want to turn this into a cooldown.
	var/last_effect = 0
	/// Does this portal bypass teleport restrictions? like TRAIT_NO_TELEPORT and NOTELEPORT flags.
	var/force_teleport = FALSE
	/// Does this portal create spark effect when teleporting?
	var/sparkless = FALSE
	/// If FALSE, the wibble filter will not be applied to this portal (only a visual effect).
	var/wibbles = TRUE
	
	///Link source/destination atmos.
	var/atmos_link = FALSE			
	/// Atmos link source
	var/turf/open/atmos_source		
	/// Atmos link destination
	var/turf/open/atmos_destination	

/obj/effect/portal/anom
	name = "wormhole"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	layer = RIPPLE_LAYER
	mech_sized = TRUE
	teleport_channel = TELEPORT_CHANNEL_WORMHOLE
	light_on = FALSE
	wibbles = FALSE

/obj/effect/portal/Move(newloc)
	for(var/T in newloc)
		if(istype(T, /obj/effect/portal))
			return FALSE
	return ..()

// Prevents portals spawned by jaunter/handtele from floating into space when relocated to an adjacent tile.
/obj/effect/portal/newtonian_move(direction, instant = FALSE, start_delay = 0)
	return TRUE

/obj/effect/portal/attackby(obj/item/W, mob/user, params)
	if(user && Adjacent(user))
		user.forceMove(get_turf(src))
		return TRUE

/obj/effect/portal/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(HAS_TRAIT(mover, TRAIT_NO_TELEPORT) && !force_teleport)
		return TRUE

/obj/effect/portal/Bumped(atom/movable/bumper)
	teleport(bumper)

/obj/effect/portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/attack_robot(mob/living/user)
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/Initialize(mapload, _creator, _lifespan = 0, obj/effect/portal/_linked, automatic_link = FALSE, turf/hard_target_override, atmos_link_override)
	. = ..()
	GLOB.portals += src
	if(!istype(_linked) && automatic_link)
		. = INITIALIZE_HINT_QDEL
		CRASH("Somebody fucked up.")
	if(_lifespan > 0)
		QDEL_IN(src, _lifespan)
	if(!isnull(atmos_link_override))
		atmos_link = atmos_link_override
	link_portal(_linked)
	hardlinked = automatic_link
	if(isturf(hard_target_override))
		hard_target = hard_target_override
	if(wibbles)
		apply_wibbly_filters(src)
	
	creator = _creator

/obj/effect/portal/singularity_pull()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/proc/link_portal(obj/effect/portal/newlink)
	linked = newlink
	if(atmos_link)
		link_atmos()

/obj/effect/portal/proc/link_atmos()
	if(atmos_source || atmos_destination)
		unlink_atmos()
	if(!isopenturf(get_turf(src)))
		return FALSE
	if(linked)
		if(isopenturf(get_turf(linked)))
			atmos_source = get_turf(src)
			atmos_destination = get_turf(linked)
	else if(hard_target)
		if(isopenturf(hard_target))
			atmos_source = get_turf(src)
			atmos_destination = hard_target
	else
		return FALSE
	if(!istype(atmos_source) || !istype(atmos_destination))
		return FALSE
	LAZYINITLIST(atmos_source.atmos_adjacent_turfs)
	LAZYINITLIST(atmos_destination.atmos_adjacent_turfs)
	if(atmos_source.atmos_adjacent_turfs[atmos_destination] || atmos_destination.atmos_adjacent_turfs[atmos_source])	//Already linked!
		return FALSE
	atmos_source.atmos_adjacent_turfs[atmos_destination] = TRUE
	atmos_destination.atmos_adjacent_turfs[atmos_source] = TRUE

/obj/effect/portal/proc/unlink_atmos()
	if(istype(atmos_source))
		if(istype(atmos_destination) && !atmos_source.Adjacent(atmos_destination) && !TURFS_CAN_SHARE(atmos_destination, atmos_source))
			LAZYREMOVE(atmos_source.atmos_adjacent_turfs, atmos_destination)
		atmos_source = null
	if(istype(atmos_destination))
		if(istype(atmos_source) && !atmos_destination.Adjacent(atmos_source) && !TURFS_CAN_SHARE(atmos_source, atmos_destination))
			LAZYREMOVE(atmos_destination.atmos_adjacent_turfs, atmos_source)
		atmos_destination = null

/// Calls on_portal_destroy(destroyed portal, location of destroyed portal) on creator if creator has such call.
/obj/effect/portal/Destroy()				
	if(creator && hascall(creator, "on_portal_destroy"))
		call(creator, "on_portal_destroy")(src, src.loc)
	creator = null
	GLOB.portals -= src
	unlink_atmos()
	if(hardlinked && !QDELETED(linked))
		QDEL_NULL(linked)
	else
		linked = null
	return ..()

/obj/effect/portal/attack_ghost(mob/dead/observer/O)
	if(!teleport(O, TRUE))
		return ..()

/obj/effect/portal/proc/teleport(atom/movable/M, force = FALSE)
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (!isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
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
	if(do_teleport(M, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, forced = force_teleport))
		if(istype(M, /obj/projectile))
			var/obj/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE

/obj/effect/portal/proc/get_link_target_turf()
	var/turf/real_target
	if(!istype(linked) || QDELETED(linked))
		if(hardlinked)
			qdel(src)
		if(!istype(hard_target) || QDELETED(hard_target))
			hard_target = null
			return
		else
			real_target = hard_target
			linked = null
	else
		real_target = get_turf(linked)
	return real_target

/obj/effect/portal/permanent
	name = "permanent portal"
	desc = "An unwavering portal that will never fade."
	hardlinked = FALSE // dont qdel my portal nerd
	force_teleport = TRUE // force teleports because they're a mapmaker tool
	var/id // var edit or set id in map editor

/obj/effect/portal/permanent/proc/get_linked()
	if(!id)
		return
	var/list/possible = list()
	for(var/obj/effect/portal/permanent/P in GLOB.portals - src)
		if(P.id && P.id == id) // gets portals with the same id, there should only be two permanent portals with the same id
			possible += P
	return possible

/obj/effect/portal/permanent/proc/set_linked()
	var/list/possible = get_linked()
	if(!possible || !possible.len)
		return
	for(var/obj/effect/portal/permanent/other in possible)
		other.linked = src
	linked = pick(possible)

/obj/effect/portal/permanent/teleport(atom/movable/M, force = FALSE)
	// try to search for a new one if something was var edited etc
	set_linked()
	. = ..()

/obj/effect/portal/permanent/one_way // doesn't have a return portal
	name = "one-way portal"
	desc = "You get the feeling that this might not be the safest thing you've ever done."
	var/list/possible_exits = list()
	var/keep // if this is a portal that should be kept

/obj/effect/portal/permanent/one_way/set_linked()
	if(!keep) // wait for a keep portal to set
		return
	var/list/possible_temp = get_linked()
	if(possible_temp && possible_temp.len)
		for(var/obj/effect/portal/permanent/other in possible_temp)
			possible_exits += get_turf(other)
			qdel(other)
	if(possible_exits && possible_exits.len)
		hard_target = pick(possible_exits)

/obj/effect/portal/permanent/one_way/keep // because its nice to be able to tell which is which on the map
	keep = TRUE

/obj/effect/portal/permanent/one_way/destroy
	keep = FALSE
