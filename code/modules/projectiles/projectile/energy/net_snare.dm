/obj/projectile/energy/net
	name = "energy netting"
	icon_state = "e_netting"
	damage = 10
	damage_type = STAMINA
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10

/obj/projectile/energy/net/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/projectile/energy/net/on_hit(atom/target, blocked = 0, pierce_hit)
	var/obj/item/dragnet_beacon/destination_beacon = null
	var/obj/item/gun/energy/e_gun/dragnet/our_dragnet = fired_from
	if(our_dragnet && istype(our_dragnet))
		destination_beacon = our_dragnet.linked_beacon

	if(isliving(target))
		var/turf/Tloc = get_turf(target)
		if(!locate(/obj/effect/nettingportal) in Tloc)
			new /obj/effect/nettingportal(Tloc, destination_beacon)
	. = ..()

/obj/projectile/energy/net/on_range()
	do_sparks(1, TRUE, src)
	. = ..()

/obj/effect/nettingportal
	name = "DRAGnet teleportation field"
	desc = "A field of bluespace energy, locking on to teleport a target."
	icon = 'icons/effects/effects.dmi'
	icon_state = "dragnetfield"
	light_outer_range = 3
	anchored = TRUE

/obj/item/restraints/handcuffs/holographic/dragnet
	breakouttime = 15 SECONDS
	trashtype = /obj/item/restraints/handcuffs/holographic/dragnet/used

/obj/item/restraints/handcuffs/holographic/dragnet/used
	desc = "A holographic projection of handcuffs, the projection seem rather weak."
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/holographic/dragnet/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s [name] dissapears!"), \
							span_userdanger("[user]'s [name] dissapears!"))
	. = ..()

/obj/effect/nettingportal/Initialize(mapload, destination_beacon)
	. = ..()
	var/obj/item/dragnet_beacon/teletarget = destination_beacon
	addtimer(CALLBACK(src, PROC_REF(pop), teletarget), 4 SECONDS)

/obj/effect/nettingportal/proc/pop(teletarget)
	if(teletarget)
		for(var/mob/living/carbon/living_carbon in get_turf(src))
			if(!living_carbon.handcuffed && living_carbon.canBeHandcuffed())
				playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
				living_carbon.set_handcuffed(new /obj/item/restraints/handcuffs/holographic/dragnet/used(living_carbon))
				living_carbon.update_handcuffed()
		for(var/mob/living/living_mob in get_turf(src))
			do_teleport(living_mob, get_turf(teletarget), 1, channel = TELEPORT_CHANNEL_BLUESPACE) //Teleport what's in the tile to the beacon
	else
		for(var/mob/living/carbon/living_carbon in get_turf(src))
			if(!living_carbon.handcuffed && living_carbon.canBeHandcuffed())
				playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
				living_carbon.set_handcuffed(new /obj/item/restraints/handcuffs/holographic/dragnet/used(living_carbon))
				living_carbon.update_handcuffed()
		for(var/mob/living/living_mob in get_turf(src))
			do_teleport(living_mob, get_turf(living_mob), 15, channel = TELEPORT_CHANNEL_BLUESPACE) //Otherwise it just warps you off somewhere.
	qdel(src)

/obj/effect/nettingportal/singularity_act()
	return

/obj/effect/nettingportal/singularity_pull()
	return

/obj/item/dragnet_beacon
	name = "\improper DRAGnet beacon"
	desc = "Can be synced with a DRAGnet to set it as a designated teleporting point."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "dragnet_beacon"
	inhand_icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	///Has a security ID been used to lock this in place?
	var/locked = FALSE
	var/obj/item/gun/energy/e_gun/dragnet/linked_dragnet
	//lazylist for keeping track of links
	var/list/linked_dragnets

/obj/item/dragnet_beacon/attackby(obj/item/tool, mob/living/user, params)
	if(isidcard(tool))
		if(!anchored)
			balloon_alert(user, "wrench the beacon first!")
			return
		if(obj_flags & EMAGGED)
			balloon_alert(user, "the access control is fried!")
			return

		var/obj/item/card/id/id_card = tool
		if((ACCESS_SECURITY in id_card.GetAccess()))
			locked = !locked
			balloon_alert(user, "beacon [locked ? "locked" : "unlocked"]")
		else
			balloon_alert(user, "no access!")

	if(istype(tool, /obj/item/gun/energy/e_gun/dragnet))
		if(!anchored)
			balloon_alert(user, "wrench the beacon first!")
			return
		linked_dragnet = tool
		linked_dragnet.link_beacon(user, src)
	update_appearance()

/obj/item/dragnet_beacon/wrench_act(mob/living/user, obj/item/tool)
	if(user.is_holding(src))
		balloon_alert(user, "put it down first!")
		return

	if(anchored && locked)
		balloon_alert(user, "must be unlocked first!")
		return

	if(isinspace() && !anchored)
		balloon_alert(user, "nothing to anchor to!")
		return

	set_anchored(!anchored)
	if(anchored == FALSE && linked_dragnet && !(obj_flags & EMAGGED))
		linked_dragnet = null
		for(var/obj/item/gun/energy/e_gun/dragnet/link in linked_dragnets)
			link.handle_beacon_disable()
	update_appearance()
	tool.play_tool_sound(src, 75)
	user.balloon_alert_to_viewers("[anchored ? "anchored" : "unanchored"]")

/obj/item/dragnet_beacon/update_overlays()
	. = ..()
	if(obj_flags & EMAGGED)
		. += "sp_orange"
		return
	if(LAZYLEN(linked_dragnets) != 0)
		. += "sp_green"
		return
	if(anchored)
		. += "sp_yellow"
		return
	else
		. += "dragnet_beacon"


/obj/item/dragnet_beacon/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	locked = FALSE
	set_anchored(FALSE)
	do_sparks(3, TRUE, src)
	balloon_alert(user, "beacon unlocked")
	update_appearance()
	return TRUE

/obj/item/dragnet_beacon/emp_act(severity)
	. = ..()
	linked_dragnet = null
	for(var/obj/item/gun/energy/e_gun/dragnet/link in linked_dragnets)
		link.handle_beacon_disable()
	locked = FALSE
	update_appearance()

/obj/projectile/energy/trap
	name = "energy snare"
	icon_state = "e_snare"
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 4

/obj/projectile/energy/trap/on_hit(atom/target, blocked = 0, pierce_hit)
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - drop a trap
		new/obj/item/restraints/legcuffs/beartrap/energy(get_turf(loc))
	else if(iscarbon(target))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy(get_turf(target))
		B.spring_trap(null, target)
	. = ..()

/obj/projectile/energy/trap/on_range()
	new /obj/item/restraints/legcuffs/beartrap/energy(loc)
	..()

/obj/projectile/energy/trap/cyborg
	name = "Energy Bola"
	icon_state = "e_snare"
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10

/obj/projectile/energy/trap/cyborg/on_hit(atom/target, blocked = 0, pierce_hit)
	if(!ismob(target) || blocked >= 100)
		do_sparks(1, TRUE, src)
		qdel(src)
	if(iscarbon(target))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy/cyborg(get_turf(target))
		B.spring_trap(null, target)
	QDEL_IN(src, 10)
	. = ..()

/obj/projectile/energy/trap/cyborg/on_range()
	do_sparks(1, TRUE, src)
	qdel(src)
