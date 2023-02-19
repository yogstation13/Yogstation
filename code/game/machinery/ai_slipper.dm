/obj/machinery/ai_slipper
	name = "foam dispenser"
	desc = "A remotely-activatable dispenser for crowd-controlling foam."
	icon = 'icons/obj/device.dmi'
	icon_state = "ai-slipper0"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 200
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)

	var/uses = 20
	var/cooldown = 0
	var/cooldown_time = 100
	req_access = list(ACCESS_AI_UPLOAD)

/obj/machinery/ai_slipper/examine(mob/user)
	. = ..()
	. += span_notice("It has <b>[uses]</b> uses of foam remaining.")

/obj/machinery/ai_slipper/update_icon()
	if(stat & BROKEN)
		return
	if((stat & NOPOWER) || cooldown_time > world.time || !uses)
		icon_state = "ai-slipper0"
	else
		icon_state = "ai-slipper1"

/obj/machinery/ai_slipper/interact(mob/user)
	if(!allowed(user))
		to_chat(user, span_danger("Access denied."))
		return
	if(!uses)
		to_chat(user, span_danger("[src] is out of foam and cannot be activated."))
		return
	if(cooldown_time > world.time)
		to_chat(user, span_danger("[src] cannot be activated for <b>[DisplayTimeText(world.time - cooldown_time)]</b>."))
		return
	new /obj/effect/particle_effect/foam(loc)
	uses--
	to_chat(user, span_notice("You activate [src]. It now has <b>[uses]</b> uses of foam remaining."))
	cooldown = world.time + cooldown_time
	power_change()
	addtimer(CALLBACK(src, .proc/power_change), cooldown_time)
