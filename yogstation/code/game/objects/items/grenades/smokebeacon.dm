/obj/item/grenade/smokebeacon
	name = "smoke grenade"
	desc = "The word 'Dank' is scribbled on it in crayon."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "smokewhite"
	det_time = 20
	item_state = "flashbang"
	slot_flags = ITEM_SLOT_BELT
	var/datum/effect_system/smoke_spread/beacon/smoke

/obj/item/grenade/smokebeacon/New()
	..()
	src.smoke = new /datum/effect_system/smoke_spread/beacon
	src.smoke.attach(src)

/obj/item/grenade/smokebeacon/Destroy()
	qdel(smoke)
	return ..()

/obj/item/grenade/smokebeacon/prime()
	update_mob()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.set_up(2, src)
	smoke.start()

	sleep(20)
	explosion(src.loc,2,4,8,flame_range = 4)
	qdel(src)

/datum/effect_system/smoke_spread/beacon
	effect_type = /obj/effect/particle_effect/smoke/beacon

/obj/effect/particle_effect/smoke/beacon
	opaque = FALSE
	color = "#B4696A"