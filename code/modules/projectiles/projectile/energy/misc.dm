/obj/item/projectile/energy/declone
	name = "radiation beam"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 100
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	
/obj/item/projectile/energy/declone/weak
	damage = 9
	irradiate = 30
	
/obj/item/projectile/energy/dart //ninja throwing dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	paralyze = 100
	range = 7

/obj/item/projectile/energy/holo
	name = "holoprojectile"
	icon = 'modular_skyrat/icons/obj/projectiles.dmi'
	icon_state = "holo"
	damage = 40
	damage_type = BURN
	range = 14

/obj/item/projectile/energy/holo/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.apply_status_effect(STATUS_EFFECT_HOLOBURN, firer)
