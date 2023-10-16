// Shoots a straight line of rusty stuff ahead of the caster, what rust monsters get
/datum/action/cooldown/spell/basic_projectile/rust_wave
	name = "Patron's Reach"
	desc = "Fire a rust spreading projectile in front of you, dealing toxin damage to whatever it hits."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "rust_wave"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	projectile_type = /obj/projectile/magic/aoe/rust_wave

/obj/projectile/magic/aoe/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	nodamage = FALSE
	hitsound = 'sound/weapons/punch3.ogg'
	ignored_factions = list("heretics")
	range = 15
	speed = 1

/obj/projectile/magic/aoe/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/datum/action/cooldown/spell/basic_projectile/rust_wave/short
	name = "Lesser Patron's Reach"
	projectile_type = /obj/projectile/magic/aoe/rust_wave/short

/obj/projectile/magic/aoe/rust_wave/short
	range = 7
	speed = 2
