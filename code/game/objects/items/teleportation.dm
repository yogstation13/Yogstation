
#define SOURCE_PORTAL 1
#define DESTINATION_PORTAL 2

#define PORTAL_LOCATION_DANGEROUS "portal_location_dangerous"
#define PORTAL_DANGEROUS_EDGE_LIMIT 8

/* Teleportation devices.
 * Contains:
 *		Locator
 *		Hand-tele
 */

/*
 * Locator
 */
/obj/item/locator
	name = "bluespace locator"
	desc = "Used to track portable teleportation beacons and targets with embedded tracking implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=400)

/obj/item/locator/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	dat += "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"

	if (temp)
		dat = "[temp]<BR><BR><A href='byond://?src=[REF(src)];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
<A href='byond://?src=[REF(src)];refresh=1'>Refresh</A>"}
	dat += "</BODY></HTML>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location || is_centcom_level(current_location.z))//If turf was not found or they're on CentCom
		to_chat(usr, "[src] is malfunctioning.")
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)))
		usr.set_machine(src)
		if (href_list["refresh"])
			temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				temp += "<B>Beacon Signals:</B><BR>"
				for(var/obj/item/beacon/W in GLOB.teleportbeacons)
					if (!W.renamed)
						continue
					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 5)
							direct = "very strong"
						else
							if (direct < 10)
								direct = "strong"
							else
								if (direct < 20)
									direct = "weak"
								else
									direct = "very weak"
						temp += "[W.name]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				temp += "<B>Implant Signals:</B><BR>"
				for (var/obj/item/implant/tracking/W in GLOB.tracked_implants)
					if (!W.imp_in || !isliving(W.loc))
						continue
					else
						var/mob/living/M = W.loc
						if (M.stat == DEAD)
							if (M.timeofdeath + W.lifespan_postmortem < world.time)
								continue

					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 20)
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									direct = "weak"
							temp += "[W.imp_in.name]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=[REF(src)];refresh=1'>Refresh</A><BR>"
			else
				temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["temp"])
				temp = null
		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return


/*
 * Hand-tele
 */
/obj/item/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology. One of the buttons opens a portal, the other re-opens your last destination."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	cryo_preserve = TRUE
	var/list/active_portal_pairs
	var/atmos_link_override
	var/obj/item/stock_parts/manipulator/manipulator

	/**
	 * Represents the last place we teleported to, for making quick portals.
	 * Can be in the following states:
	 * - null, meaning either this hand tele hasn't been used yet, or the last place it was portalled to was removed.
	 * - PORTAL_LOCATION_DANGEROUS, meaning the last place it teleported to was the "None (Dangerous)" location.
	 * - A weakref to a /obj/machinery/computer/teleporter, meaning the last place it teleported to was a pre-setup location.
	*/
	var/last_portal_location

/obj/item/hand_tele/Initialize(mapload)
	. = ..()
	active_portal_pairs = list()
	manipulator = new /obj/item/stock_parts/manipulator(src)

/obj/item/hand_tele/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/manipulator))
		if(!manipulator)
			if(!user.transferItemToLoc(W, src))
				return
			manipulator = W
			to_chat(user, span_notice("You install a [manipulator.name] in [src]."))
		else
			to_chat(user, span_notice("[src] already has a manipulator installed."))

/obj/item/hand_tele/screwdriver_act(mob/living/user, obj/item/I)
	if(manipulator)
		to_chat(user, span_notice("You remove the [manipulator.name] from \the [src]."))
		manipulator.forceMove(drop_location())
		manipulator = null

/obj/item/hand_tele/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!manipulator)
			. += span_warning("The manipulator is missing.")
		else
			. += span_notice("A tier <b>[manipulator.rating]</b> micro manipulator is installed. It is <i>screwed</i> in place.")

/obj/item/hand_tele/pre_attack(atom/target, mob/user, params)
	if(is_parent_of_portal(target))
		try_dispel_portal(target, user)
		return TRUE
	return ..()

/obj/item/hand_tele/pre_attack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	var/portal_location = last_portal_location

	if (isweakref(portal_location))
		var/datum/weakref/last_portal_location_ref = last_portal_location
		portal_location = last_portal_location_ref.resolve()

	if (isnull(portal_location))
		to_chat(user, span_warning("[src] flashes briefly. No target is locked in."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	try_create_portal_to(user, portal_location)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/hand_tele/proc/try_dispel_portal(atom/target, mob/user)
	if(is_parent_of_portal(target)) //dispel me from this horrid realm
		var/dispel_time = 5 - manipulator.rating
		if(dispel_time == 0)
			qdel(target)
			to_chat(user, span_notice("You dispel [target] with \the [src]!"))
			return
		balloon_alert(user, "Dispelling portal...")
		if(do_after(user, dispel_time SECONDS, target))
			qdel(target)
			to_chat(user, span_notice("You dispel [target] with \the [src]!"))

/obj/item/hand_tele/attack_self(mob/user)
	if(!can_teleport_notifies(user))
		return

	var/list/locations = list()
	for(var/obj/machinery/computer/teleporter/computer in GLOB.machines)
		if(!computer.target)
			continue
		var/area/computer_area = get_area(computer.target)
		if(!computer_area || (computer_area.area_flags & NOTELEPORT))
			continue
		if(computer.power_station?.teleporter_hub && computer.power_station.engaged)
			locations["[get_area(computer.target)] (Active)"] = computer
		else
			locations["[get_area(computer.target)] (Inactive)"] = computer

	locations["None (Dangerous)"] = PORTAL_LOCATION_DANGEROUS

	var/teleport_location_key = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") as null|anything in locations
	if(!teleport_location_key || user.get_active_held_item() != src || user.incapacitated())
		return
	// Not always a datum, but needed for IS_WEAKREF_OF to cast properly.
	var/datum/teleport_location = locations[teleport_location_key]
	if (!try_create_portal_to(user, teleport_location))
		return

	if (teleport_location == PORTAL_LOCATION_DANGEROUS)
		last_portal_location = PORTAL_LOCATION_DANGEROUS
	else if (!IS_WEAKREF_OF(teleport_location, last_portal_location))
		if (isweakref(teleport_location))
			var/datum/weakref/about_to_replace_location_ref = last_portal_location
			var/obj/machinery/computer/teleporter/about_to_replace_location = about_to_replace_location_ref.resolve()
			if (about_to_replace_location)
				UnregisterSignal(about_to_replace_location, COMSIG_TELEPORTER_NEW_TARGET)

		RegisterSignal(teleport_location, COMSIG_TELEPORTER_NEW_TARGET, PROC_REF(on_teleporter_new_target))

		last_portal_location = WEAKREF(teleport_location)

/// Takes either PORTAL_LOCATION_DANGEROUS or an /obj/machinery/computer/teleport/computer.
/obj/item/hand_tele/proc/try_create_portal_to(mob/user, teleport_location)
	if(!manipulator)
		to_chat(user, span_notice("[src] is missing its manipulator and cannot function."))
		return
	if(active_portal_pairs.len >= manipulator.rating)
		to_chat(user, span_notice("[src] cannot support another portal!"))
		return

	var/teleport_turf

	if(teleport_location == PORTAL_LOCATION_DANGEROUS)
		var/list/dangerous_turfs = list()
		for(var/turf/dangerous_turf in urange(10, orange=1))
			if(dangerous_turf.x > world.maxx - PORTAL_DANGEROUS_EDGE_LIMIT || dangerous_turf.x < PORTAL_DANGEROUS_EDGE_LIMIT)
				continue	//putting them at the edge is dumb
			if(dangerous_turf.y > world.maxy - PORTAL_DANGEROUS_EDGE_LIMIT || dangerous_turf.y < PORTAL_DANGEROUS_EDGE_LIMIT)
				continue
			var/area/dangerous_area = dangerous_turf.loc
			if(dangerous_area.area_flags & NOTELEPORT)
				continue
			dangerous_turfs += dangerous_turf

		teleport_turf = pick(dangerous_turfs)
	else
		var/obj/machinery/computer/teleporter/computer = teleport_location
		teleport_turf = computer.target

	if(teleport_turf == null)
		to_chat(user, span_notice("[src] vibrates, then stops. Maybe you should try something else."))
		return
	var/area/teleport_area = get_area(teleport_turf)
	if(teleport_area.area_flags & NOTELEPORT)
		to_chat(user, span_notice("[src] is malfunctioning."))
		return
	if(!can_teleport_notifies(user))
		return
	var/list/obj/effect/portal/created = create_portal_pair(get_turf(user), get_teleport_turf(get_turf(teleport_turf)), user, 300, 1, null, atmos_link_override) // yogs - log portal creator
	if(LAZYLEN(created) != 2)
		return

	var/obj/effect/portal/portal1 = created[1]
	var/obj/effect/portal/portal2 = created[2]

	RegisterSignal(portal1, COMSIG_QDELETING, PROC_REF(on_portal_destroy))
	RegisterSignal(portal2, COMSIG_QDELETING, PROC_REF(on_portal_destroy))

	try_move_adjacent(portal1, user.dir)
	active_portal_pairs[portal1] = portal2

	investigate_log("was used by [key_name(user)] at [AREACOORD(user)] to create a portal pair with destinations [AREACOORD(portal1)] and [AREACOORD(portal2)].", INVESTIGATE_PORTAL)
	add_fingerprint(user)

	to_chat(user, span_notice("Locked in."))

	return TRUE

/obj/item/hand_tele/proc/can_teleport_notifies(mob/user)
	var/turf/current_location = get_turf(user)
	var/area/current_area = current_location.loc
	if(!current_location || (current_area.area_flags & NOTELEPORT) || is_away_level(current_location.z) || !isturf(user.loc))
		to_chat(user, span_notice("[src] is malfunctioning."))
		return FALSE

	return TRUE

/obj/item/hand_tele/proc/on_teleporter_new_target(datum/source)
	SIGNAL_HANDLER

	if(IS_WEAKREF_OF(source, last_portal_location))
		last_portal_location = null
		UnregisterSignal(source, COMSIG_TELEPORTER_NEW_TARGET)

/obj/item/hand_tele/proc/on_portal_destroy(obj/effect/portal/P)
	SIGNAL_HANDLER
	active_portal_pairs -= P	//If this portal pair is made by us it'll be erased along with the other portal by the portal.

/obj/item/hand_tele/proc/is_parent_of_portal(obj/effect/portal/P)
	if(!istype(P))
		return FALSE
	if(active_portal_pairs[P])
		return SOURCE_PORTAL
	for(var/i in active_portal_pairs)
		if(active_portal_pairs[i] == P)
			return DESTINATION_PORTAL
	return FALSE

/obj/item/hand_tele/suicide_act(mob/user)
	if(iscarbon(user))
		user.visible_message(span_suicide("[user] is creating a weak portal and sticking [user.p_their()] head through! It looks like [user.p_theyre()] trying to commit suicide!"))
		var/mob/living/carbon/itemUser = user
		var/obj/item/bodypart/head/head = itemUser.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.drop_limb()
			var/list/safeLevels = SSmapping.levels_by_any_trait(list(ZTRAIT_SPACE_RUINS, ZTRAIT_LAVA_RUINS, ZTRAIT_STATION, ZTRAIT_MINING))
			head.forceMove(locate(rand(1, world.maxx), rand(1, world.maxy), pick(safeLevels)))
			itemUser.visible_message(span_suicide("The portal snaps closed taking [user]'s head with it!"))
		else
			itemUser.visible_message(span_suicide("[user] looks even further depressed as they realize they do not have a head...and suddenly dies of shame!"))
			return (SHAME)
		return (BRUTELOSS)

#undef PORTAL_LOCATION_DANGEROUS
#undef PORTAL_DANGEROUS_EDGE_LIMIT
