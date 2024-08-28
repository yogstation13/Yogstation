/obj/item/donator/wumpa
	name = "wumpa"
	desc = span_bold("What in the god-dam?...")
	icon = 'monkestation/code/modules/donator/icons/obj/misc.dmi'
	icon_state = "wumpa"
	var/datum/looping_sound/wumpa/sounds
	var/shutup = FALSE
	pickup_sound = 'monkestation/code/modules/donator/sounds/woah_3.ogg'
	drop_sound = 'monkestation/code/modules/donator/sounds/woah_1.ogg'
	var/squeak_override = list('monkestation/code/modules/donator/sounds/woah_1.ogg' = 33,
	'monkestation/code/modules/donator/sounds/woah_2.ogg'=33,
	'monkestation/code/modules/donator/sounds/woah_3.ogg'=33,
	'monkestation/code/modules/donator/sounds/woahwoah.ogg' = 1)
/obj/item/donator/wumpa/Initialize(mapload)
	. = ..()
	sounds = new /datum/looping_sound/wumpa(src,TRUE,FALSE,FALSE,CHANNEL_JUKEBOX)
	AddComponent(/datum/component/squeak,squeak_override)
/obj/item/donator/wumpa/attack_self(mob/user, modifiers)
	. = ..()
	shutup=!shutup
	if(shutup)
		user.visible_message("[src] shuts up.")
		sounds.stop()
	else
		user.visible_message("[src] continues its jolly melody.")
		sounds.start(src)


/datum/looping_sound/wumpa
	mid_sounds = list('monkestation/code/modules/donator/sounds/wumpa.ogg' = 1)
	mid_length = 31
	volume = 1
	extra_range = 3
	falloff_exponent = 100
	falloff_distance = 3

