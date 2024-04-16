/obj/item/rls
	name = "Rapid Light Switch (RLS)"
	desc = "A device used to remotely switch lighting."
	icon = 'icons/obj/device.dmi'
	icon_state = "multitool_red"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = 0
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	var/last_used

/obj/item/rls/attack_self(mob/user)
	. = ..()
	if(last_used > world.time - 10 SECONDS)
		to_chat(user, span_notice("[src] is still cycling"))
		return
	last_used = world.time
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	A.lightswitch = !A.lightswitch
	A.update_icon()

	for(var/obj/machinery/light_switch/L in A)
		L.update_icon()

	A.power_change()
	to_chat(user, span_notice("You toggle the lights [A.lightswitch ? "on" : "off"]."))
