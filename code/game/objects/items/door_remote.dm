#define REMOTE_OPEN "Open Door"
#define REMOTE_BOLT "Toggle Bolts"
#define REMOTE_EMERGENCY "Toggle Emergency Access"

/obj/item/door_remote
	name = "door remote"
	desc = "Remotely controls airlocks."
	icon = 'icons/obj/remote.dmi'
	icon_state = "remote"
	base_icon_state = "remote"
	item_state = "electronic"

	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	var/department = "civilian"
	w_class = WEIGHT_CLASS_TINY
	var/mode = REMOTE_OPEN
	var/list/region_access = list(1) //See access.dm
	var/list/access_list

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	for(var/i in region_access)
		access_list += get_region_accesses(i)
	update_icon_state()

/obj/item/door_remote/attack_self(mob/user)
	switch(mode)
		if(REMOTE_OPEN)
			mode = REMOTE_BOLT
		if(REMOTE_BOLT)
			mode = REMOTE_EMERGENCY
		if(REMOTE_EMERGENCY)
			mode = REMOTE_OPEN
	playsound(user, 'sound/items/door_remote.ogg', 85, TRUE)
	update_icon_state()
	to_chat(user, "Now in mode: [mode].")

// Airlock remote works by sending NTNet packets to whatever it's pointed at.
/obj/item/door_remote/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/obj/machinery/door/door
	if(istype(target, /obj/machinery/door))
		door = target
		if(!door.opens_with_door_remote)
			return
	else
		for (var/obj/machinery/door/door_on_turf in get_turf(target))
			if(door_on_turf.opens_with_door_remote)
				door = door_on_turf
				break
		if(isnull(door))
			return
	if(!door.check_access_list(access_list) || !door.requiresID())
		target.balloon_alert(user, "can't access!")
		return

	var/obj/machinery/door/airlock/airlock = door

	if(!door.hasPower() || (istype(airlock) && !airlock.canAIControl()))
		target.balloon_alert(user, mode == REMOTE_OPEN ? "it won't budge!" : "nothing happens!")
		return

	switch(mode)
		if(REMOTE_OPEN)
			if(door.density)
				door.open()
			else
				door.close()
		if(REMOTE_BOLT)
			if(!istype(airlock))
				target.balloon_alert(user, "only airlocks!")
				return

			if(airlock.locked)
				airlock.unbolt()
				log_combat(user, airlock, "unbolted", src)
			else
				airlock.bolt()
				log_combat(user, airlock, "bolted", src)
		if(REMOTE_EMERGENCY)
			if(!istype(airlock))
				target.balloon_alert(user, "only airlocks!")
				return

			airlock.emergency = !airlock.emergency
			airlock.update_appearance(UPDATE_ICON)

/obj/item/door_remote/update_icon_state()
	var/icon_state_mode
	switch(mode)
		if(REMOTE_OPEN)
			icon_state_mode = "open"
		if(REMOTE_BOLT)
			icon_state_mode = "bolt"
		if(REMOTE_EMERGENCY)
			icon_state_mode = "emergency"

	icon_state = "[base_icon_state]_[department]_[icon_state_mode]"
	return ..()


/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "The holy grail of all door remotes. It can control any door on the station and beyond."
	department = "omni"
	region_access = list(0)

/obj/item/door_remote/captain
	name = "command door remote"
	desc = "Remotely controls airlocks in command areas, including certain other secure rooms."
	department = "com"
	region_access = list(7)

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	desc = "Remotely controls airlocks in the engineering department, including maintenance tunnels."
	department = "eng"
	region_access = list(5)

/obj/item/door_remote/research_director
	name = "research door remote"
	desc = "Remotely controls airlocks in the research department."
	department = "sci"
	region_access = list(4)

/obj/item/door_remote/head_of_security
	name = "security door remote"
	desc = "Remotely controls airlocks in the security department."
	department = "sec"
	region_access = list(2)

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks in the supply department. Also comes with additional Vault access."
	department = "sup"
	region_access = list(6)

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	desc = "Remotely controls airlocks in the medical department."
	department = "med"
	region_access = list(3)

/obj/item/door_remote/civillian
	name = "civilian door remote"
	desc = "Remotely controls airlocks in civilian areas, including public airlocks."
	department = "civ"
	region_access = list(1, 6)

#undef REMOTE_OPEN
#undef REMOTE_BOLT
#undef REMOTE_EMERGENCY
