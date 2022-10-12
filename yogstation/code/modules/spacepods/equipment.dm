/obj/item/spacepod_equipment
	var/obj/spacepod/spacepod
	icon = 'yogstation/icons/obj/spacepods/parts.dmi'
	var/slot = SPACEPOD_SLOT_MISC
	var/slot_space = 1

/obj/item/spacepod_equipment/proc/on_install(obj/spacepod/SP)
	spacepod = SP
	SP.equipment |= src
	forceMove(SP)

/obj/item/spacepod_equipment/proc/on_uninstall()
	spacepod.equipment -= src

/obj/item/spacepod_equipment/proc/can_install(obj/spacepod/SP, mob/user)
	var/room = SP.equipment_slot_limits[slot] || 0
	for(var/obj/item/spacepod_equipment/EQ in SP.equipment)
		if(EQ.slot == slot)
			room -= EQ.slot_space
	if(room < slot_space)
		to_chat(user, span_warning("There's no room for another [slot] system!"))
		return FALSE
	return TRUE

/obj/item/spacepod_equipment/proc/can_uninstall(mob/user)
	return TRUE

/obj/item/spacepod_equipment/weaponry
	slot = SPACEPOD_SLOT_WEAPON
	var/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 15
	var/overlay_icon
	var/overlay_icon_state

/obj/item/spacepod_equipment/weaponry/on_install(obj/spacepod/SP)
	. = ..()
	SP.weapon = src
	SP.update_icon()

/obj/item/spacepod_equipment/weaponry/on_uninstall()
	. = ..()
	if(spacepod.weapon == src)
		spacepod.weapon = null

/obj/item/spacepod_equipment/weaponry/proc/fire_weapons(target)
	if(spacepod.next_firetime > world.time)
		to_chat(usr, span_warning("Your weapons are recharging."))
		playsound(src, 'sound/weapons/gun_dry_fire.ogg', 30, TRUE)
		return
	if(!spacepod.cell || !spacepod.cell.use(shot_cost))
		to_chat(usr, span_warning("Insufficient charge to fire the weapons"))
		playsound(src, 'sound/weapons/gun_dry_fire.ogg', 30, TRUE)
		return
	spacepod.next_firetime = world.time + fire_delay
	for(var/I in 1 to shots_per)
		spacepod.fire_projectiles(projectile_type, target)
		playsound(src, fire_sound, 50, TRUE)
		sleep(0.2 SECONDS)

/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/cargo // this one holds large crates and shit
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon_state = "cargo_blank"
	slot = SPACEPOD_SLOT_CARGO

/obj/item/spacepod_equipment/cargo/large
	name = "spacepod crate storage system"
	desc = "A heavy duty storage system for spacepods. Holds one crate."
	icon_state = "cargo_crate"
	var/obj/storage = null
	var/storage_type = /obj/structure/closet/crate

/obj/item/spacepod_equipment/cargo/large/on_install(obj/spacepod/SP)
	..()
	// COMSIG - a way to make component signals sound more important than they actually are.
	// it's not even limited to components. Does this look like a component to you?
	// Okay here's a better name: It's a fucking *event handler*. Like the ones in javascript.
	// a much more descriptive and less scary name than fucking "COMSIG". But noooooooooo
	// the TG coders were too self important to pick a descriptive name and wanted to sound all scientific
	RegisterSignal(SP, COMSIG_MOUSEDROPPED_ONTO, .proc/spacepod_mousedrop)
	SP.verbs |= /obj/spacepod/proc/unload_cargo

/obj/item/spacepod_equipment/cargo/large/on_uninstall()
	UnregisterSignal(spacepod, COMSIG_MOUSEDROPPED_ONTO)
	..()
	if(!(locate(/obj/item/spacepod_equipment/cargo/large) in spacepod.equipment))
		spacepod.verbs -= /obj/spacepod/proc/unload_cargo

/obj/item/spacepod_equipment/cargo/large/can_uninstall(mob/user)
	if(storage)
		to_chat(user, span_warning("Unload the cargo first!"))
		return FALSE
	return ..()

/obj/spacepod/proc/unload_cargo() // if I could i'd put this on spacepod_equipment but unfortunately BYOND is stupid
	set name = "Unload Cargo"
	set category = "Spacepod"
	set src = usr.loc

	if(!verb_check())
		return

	var/used_key_list = list()
	var/cargo_map = list()
	for(var/obj/item/spacepod_equipment/cargo/large/E in equipment)
		if(!E.storage)
			continue
		cargo_map[avoid_assoc_duplicate_keys("[E.name] ([E.storage.name])", used_key_list)] = E
	var/selection = input(usr, "Unload which cargo?", null, null) as null|anything in cargo_map
	var/obj/item/spacepod_equipment/cargo/large/E = cargo_map[selection]
	if(!selection || !verb_check() || !E || !(E in equipment) || !E.storage)
		return
	E.storage.forceMove(loc)
	E.storage = null

/obj/item/spacepod_equipment/cargo/large/proc/spacepod_mousedrop(obj/spacepod/SP, obj/A, mob/user)
	if(user == SP.pilot || (user in SP.passengers))
		return FALSE
	if(istype(A, storage_type) && SP.Adjacent(A)) // For loading ore boxes
		if(!storage)
			to_chat(user, span_notice("You begin loading [A] into [SP]'s [src]"))
			if(do_after_mob(user, list(A, SP), 40))
				storage = A
				A.forceMove(src)
				to_chat(user, span_notice("You load [A] into [SP]'s [src]!"))
			else
				to_chat(user, span_warning("You fail to load [A] into [SP]'s [src]"))
		else
			to_chat(user, span_warning("[SP] already has \an [storage]"))
		return TRUE
	return FALSE

/obj/item/spacepod_equipment/cargo/large/ore
	name = "spacepod ore storage system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over. Needs to be loaded with an ore box to work"
	icon_state = "cargo_ore"
	storage_type = /obj/structure/ore_box

/obj/item/spacepod_equipment/cargo/large/ore/on_install(obj/spacepod/SP)
	..()
	RegisterSignal(SP, COMSIG_MOVABLE_MOVED, .proc/spacepod_moved)

/obj/item/spacepod_equipment/cargo/large/ore/on_uninstall()
	UnregisterSignal(spacepod, COMSIG_MOVABLE_MOVED)
	..()

/obj/item/spacepod_equipment/cargo/large/ore/proc/spacepod_moved(obj/spacepod/SP)
	if(storage)
		for(var/turf/T in SP.locs)
			for(var/obj/item/stack/ore in T)
				ore.forceMove(storage)

/obj/item/spacepod_equipment/cargo/chair
	name = "passenger seat"
	desc = "A passenger seat for a spacepod."
	icon_state = "sec_cargo_chair"
	var/occupant_mod = 1

/obj/item/spacepod_equipment/cargo/chair/on_install(obj/spacepod/SP)
	..()
	SP.max_passengers += occupant_mod

/obj/item/spacepod_equipment/cargo/chair/on_uninstall()
	spacepod.max_passengers -= occupant_mod
	..()

/obj/item/spacepod_equipment/cargo/chair/can_uninstall(mob/user)
	if(spacepod.passengers.len > (spacepod.max_passengers - occupant_mod))
		to_chat(user, span_warning("You can't remove an occupied seat! Remove the occupant first."))
		return FALSE
	return ..()

/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/weaponry/disabler
	name = "disabler system"
	desc = "A weak disabler system for space pods, fires disabler beams."
	icon_state = "weapon_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 400
	fire_sound = 'sound/weapons/taser2.ogg'
	overlay_icon = 'yogstation/icons/obj/spacepods/2x2.dmi'
	overlay_icon_state = "pod_weapon_disabler"

/obj/item/spacepod_equipment/weaponry/burst_disabler
	name = "burst disabler system"
	desc = "A weak disabler system for space pods, this one fires 3 at a time."
	icon_state = "weapon_burst_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 1200
	shots_per = 3
	fire_sound = 'sound/weapons/taser2.ogg'
	fire_delay = 30
	overlay_icon = 'yogstation/icons/obj/spacepods/2x2.dmi'
	overlay_icon_state = "pod_weapon_disabler"

/obj/item/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy."
	icon_state = "weapon_laser"
	projectile_type = /obj/item/projectile/beam/laser
	shot_cost = 600
	fire_sound = 'sound/weapons/Laser.ogg'
	overlay_icon = 'yogstation/icons/obj/spacepods/2x2.dmi'
	overlay_icon_state = "pod_weapon_laser"

// MINING LASERS
/obj/item/spacepod_equipment/weaponry/basic_pod_ka
	name = "weak kinetic accelerator"
	desc = "A weak kinetic accelerator for space pods, fires bursts of energy that cut through rock."
	icon = 'goon/icons/obj/spacepods/parts.dmi'
	icon_state = "pod_taser"
	projectile_type = /obj/item/projectile/kinetic/pod
	shot_cost = 300
	fire_delay = 14
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/spacepod_equipment/weaponry/pod_ka
	name = "kinetic accelerator system"
	desc = "A kinetic accelerator system for space pods, fires bursts of energy that cut through rock."
	icon = 'goon/icons/obj/spacepods/parts.dmi'
	icon_state = "pod_m_laser"
	projectile_type = /obj/item/projectile/kinetic/pod/regular
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/projectile/kinetic/pod
	range = 4

/obj/item/projectile/kinetic/pod/regular
	damage = 50
	pressure_decrease = 0.5

/obj/item/spacepod_equipment/weaponry/plasma_cutter
	name = "plasma cutter system"
	desc = "A plasma cutter system for space pods. It is capable of expelling concentrated plasma bursts to mine or cut off xeno limbs!"
	icon = 'goon/icons/obj/spacepods/parts.dmi'
	icon_state = "pod_p_cutter"
	projectile_type = /obj/item/projectile/plasma
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	overlay_icon = 'yogstation/icons/obj/spacepods/2x2.dmi'
	overlay_icon_state = "pod_weapon_plasma"

/obj/item/spacepod_equipment/weaponry/plasma_cutter/adv
	name = "enhanced plasma cutter system"
	desc = "An enhanced plasma cutter system for space pods. It is capable of expelling concentrated plasma bursts to mine or cut off xeno faces!"
	icon_state = "pod_ap_cutter"
	projectile_type = /obj/item/projectile/plasma/adv
	shot_cost = 200
	fire_delay = 8

/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/tracker
	name = "spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon = 'goon/icons/obj/spacepods/parts.dmi'
	icon_state = "pod_locator"

/*
///////////////////////////////////////
/////////Lock System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/lock
	name = "pod lock"
	desc = "You shouldn't be seeing this"
	icon_state = "blank"
	slot = SPACEPOD_SLOT_LOCK

/obj/item/spacepod_equipment/lock/on_install(obj/spacepod/SP)
	..()
	RegisterSignal(SP, COMSIG_PARENT_ATTACKBY, .proc/spacepod_attackby)
	SP.lock = src

/obj/item/spacepod_equipment/lock/on_uninstall()
	UnregisterSignal(spacepod, COMSIG_PARENT_ATTACKBY)
	if(spacepod.lock == src)
		spacepod.lock = null
	spacepod.locked = FALSE
	..()

/obj/item/spacepod_equipment/lock/proc/spacepod_attackby(obj/spacepod/SP, I, mob/user)
	return FALSE

// Key and Tumbler System
/obj/item/spacepod_equipment/lock/keyed
	name = "spacepod tumbler lock"
	desc = "A locking system to stop podjacking. This version uses a standalone key."
	icon_state = "lock_tumbler"
	var/static/id_source = 0
	var/id = null

/obj/item/spacepod_equipment/lock/keyed/Initialize()
	. = ..()
	if(id == null)
		id = ++id_source


/obj/item/spacepod_equipment/lock/keyed/spacepod_attackby(obj/spacepod/SP, obj/item/I, mob/user)
	if(istype(I, /obj/item/spacepod_key))
		var/obj/item/spacepod_key/key = I
		if(key.id == id)
			SP.lock_pod()
			return
		else
			to_chat(user, span_warning("This is the wrong key!"))
		return TRUE
	return FALSE

/obj/item/spacepod_equipment/lock/keyed/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/spacepod_key))
		var/obj/item/spacepod_key/key = I
		if(key.id == null)
			key.id = id
			to_chat(user, span_notice("You grind the blank key to fit the lock."))
		else
			to_chat(user, span_warning("This key is already ground!"))
	else
		..()

/obj/item/spacepod_equipment/lock/keyed/sec
	id = "security spacepod"

// The key
/obj/item/spacepod_key
	name = "spacepod key"
	desc = "A key for a spacepod lock."
	icon = 'yogstation/icons/obj/spacepods/parts.dmi'
	icon_state = "podkey"
	w_class = WEIGHT_CLASS_TINY
	var/id = null

/obj/item/spacepod_key/sec
	name = "security spacepod key"
	desc = "Unlocks the security spacepod. Probably best kept out of assistant hands."
	id = "security spacepod"

/obj/item/device/lock_buster
	name = "pod lock buster"
	desc = "Destroys a podlock in mere seconds once applied. Waranty void if used."
	icon = 'yogstation/icons/obj/spacepods/parts.dmi'
	icon_state = "lock_buster_off"
	var/on = FALSE

/obj/item/device/lock_buster/attack_self(mob/user)
	on = !on
	if(on)
		icon_state = "lock_buster_on"
	else
		icon_state = "lock_buster_off"
	to_chat(user, span_notice("You turn the [src] [on ? "on" : "off"]."))
