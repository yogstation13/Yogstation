#define SNAKE_SPAM_TICKS 600 //how long between cardboard box openings that trigger the '!'
/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon_state = "cardboard"
	mob_storage_capacity = 1
	resistance_flags = FLAMMABLE
	max_integrity = 70
	integrity_failure = 0
	can_weld_shut = 0
	cutting_tool = TOOL_WIRECUTTER
	open_sound = "rustle"
	material_drop = /obj/item/stack/sheet/cardboard
	delivery_icon = "deliverybox"
	anchorable = FALSE
	door_anim_time = 0 // no animation
	var/move_speed_multiplier = 1
	var/move_delay = FALSE
	var/egged = 0

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(!istype(user) || opened || move_delay || user.incapacitated() || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	if(step(src, direction))
		addtimer(CALLBACK(src, PROC_REF(ResetMoveDelay)), CONFIG_GET(number/movedelay/walk_delay) * move_speed_multiplier)
	else
		ResetMoveDelay()

/obj/structure/closet/cardboard/proc/ResetMoveDelay()
	move_delay = FALSE

/obj/structure/closet/cardboard/open()
	if(opened || !can_open())
		return 0
	var/list/alerted = null
	if(egged < world.time)
		var/mob/living/Snake = null
		for(var/mob/living/L in src.contents)
			Snake = L
			break
		if(Snake)
			alerted = viewers(7,src)
	..()
	if(LAZYLEN(alerted))
		egged = world.time + SNAKE_SPAM_TICKS
		for(var/mob/living/L in alerted)
			if(!L.stat)
				if(!L.incapacitated(ignore_restraints = 1))
					L.face_atom(src)
				L.do_alert_animation()
		playsound(loc, 'sound/machines/chime.ogg', 50, FALSE, -5)

/// Does the MGS ! animation
/atom/proc/do_alert_animation()
	var/mutable_appearance/alert = mutable_appearance('icons/obj/closet.dmi', "cardboard_special")
	SET_PLANE_EXPLICIT(alert, ABOVE_LIGHTING_PLANE, src)
	var/atom/movable/flick_visual/exclamation = flick_overlay_view(alert, 1 SECONDS)
	exclamation.alpha = 0
	exclamation.pixel_x = -pixel_x
	animate(exclamation, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
	// We use this list to update plane values on parent z change, which is why we need the timer too
	// I'm sorry :(
	LAZYADD(update_on_z, exclamation)
	// Intentionally less time then the flick so we don't get weird shit
	addtimer(CALLBACK(src, PROC_REF(forget_alert), exclamation), 0.8 SECONDS, TIMER_CLIENT_TIME)

/atom/proc/forget_alert(atom/movable/flick_visual/exclamation)
	LAZYREMOVE(update_on_z, exclamation)


/obj/structure/closet/cardboard/metal
	name = "large metal box"
	desc = "THE COWARDS! THE FOOLS!"
	icon_state = "metalbox"
	max_integrity = 500
	mob_storage_capacity = 5
	resistance_flags = NONE
	move_speed_multiplier = 2
	cutting_tool = TOOL_WELDER
	open_sound = 'sound/machines/click.ogg'
	material_drop = /obj/item/stack/sheet/plasteel
#undef SNAKE_SPAM_TICKS

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(!istype(user) || opened || move_delay || user.incapacitated() || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	var/oldloc = loc
	step(src, direction)
	if(oldloc != loc)
		addtimer(CALLBACK(src, PROC_REF(ResetMoveDelay)), CONFIG_GET(number/movedelay/walk_delay) * move_speed_multiplier)
	else
		move_delay = FALSE
