#define PASSIVE_SNUFF_LIMIT 0.5

/obj/item/light_eater
	COOLDOWN_DECLARE(message_cooldown)
	COOLDOWN_DECLARE(snuff_message_cooldown)

/obj/item/light_eater/equipped(mob/user, slot, initial)
	. = ..()
	var/static/list/containers_connections = list(COMSIG_MOVABLE_MOVED = PROC_REF(on_moved))
	AddComponent(/datum/component/connect_containers, user, containers_connections)
	RegisterSignal(user, COMSIG_NIGHTMARE_SNUFF_CHECK, PROC_REF(do_snuff_check))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	START_PROCESSING(SSprocessing, src)

/obj/item/light_eater/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, list(COMSIG_NIGHTMARE_SNUFF_CHECK, COMSIG_MOVABLE_MOVED))
	STOP_PROCESSING(SSprocessing, src)

/obj/item/light_eater/proc/on_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	do_snuff_check(loc, get_turf(source))

/obj/item/light_eater/proc/do_snuff_check(mob/user, turf/start_turf)
	if(!start_turf)
		return

	var/lumcount = start_turf.get_lumcount()
	if(lumcount > PASSIVE_SNUFF_LIMIT)
		return

	var/snuffed_something = FALSE

	for(var/atom/nearby as anything in view(2, start_turf))
		if(!nearby.light || !nearby.light_on)
			continue

		if(istype(nearby, /obj/machinery/light))
			var/obj/machinery/light/light_fixture = nearby
			if(!light_fixture.low_power_mode) // Otherwise the emergency lights caused by tripping a fire alarm get snuffed and we don't want that.
				continue

		var/hsl = rgb2num(nearby.light_color, COLORSPACE_HSL)
		if(nearby.light_power * (hsl[3] / 100) > 0.8) // The power of the light multiplied by its lightness is a good indicator of its overall brightness.
			return

		SEND_SIGNAL(src, COMSIG_LIGHT_EATER_EAT, nearby, src, TRUE)
		snuffed_something = TRUE

	if(!snuffed_something || !COOLDOWN_FINISHED(src, snuff_message_cooldown))
		return

	COOLDOWN_START(src, snuff_message_cooldown, 1 SECOND)

	user.visible_message(
		message = span_danger("Something dark in [src] lashes out at nearby lights!"),
		self_message = span_notice("Your [name] lashes out at nearby lights!"),
		blind_message = span_danger("You feel a gnawing pulse eat at your sight.")
	)

/obj/item/light_eater/process(seconds_per_tick)
	do_snuff_check(loc, get_turf(loc))

/obj/item/light_eater/pre_attack(atom/target, mob/living/user)
	. = ..()
	if(.)
		return

	if(user.istate & ISTATE_HARM) // In this case, you want to hit the door instead of prying it open.
		return

	var/is_fire_door = istype(target, /obj/machinery/door/firedoor)

	if(!is_fire_door && !istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/window))
		return

	var/obj/machinery/door/opening = target

	if(!opening.density) // Don't bother opening that which is already open.
		return

	var/has_power = opening.hasPower() && !is_fire_door

	if((!opening.requiresID() || opening.allowed(user)) && has_power) // Blocks useless messages for doors we can open normally.
		return

	if(has_power)
		if(check_message_cd())
			opening.balloon_alert(user, "powered!")
		return TRUE

	if(opening.locked)
		if(check_message_cd())
			opening.balloon_alert(user, "bolted!")
		return TRUE

	if(opening.welded)
		if(check_message_cd())
			opening.balloon_alert(user, "welded!")
		return TRUE

	user.visible_message(
		message = span_warning("[user] forces [opening] to open with [user.p_their()] [src]!"),
		self_message = span_warning("We force [opening] to open."),
		blind_message = span_hear("You hear a metal screeching sound.")
	)

	if(is_fire_door)
		var/obj/machinery/door/firedoor/fire_door = opening
		if(user.istate & ISTATE_SECONDARY)
			fire_door.try_to_crowbar_secondary(src, user)
		else
			fire_door.try_to_crowbar(src, user)
	else
		opening.open(BYPASS_DOOR_CHECKS)
	return TRUE

/obj/item/light_eater/proc/check_message_cd()
	. = COOLDOWN_FINISHED(src, message_cooldown)
	if(.)
		COOLDOWN_START(src, message_cooldown, 5 SECONDS)

#undef PASSIVE_SNUFF_LIMIT
