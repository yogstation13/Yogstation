/obj/item/ammo_casing/caseless/laser
	name = "laser casing"
	desc = "You shouldn't be seeing this."
	caliber = LASER
	icon_state = "s-casing-live"
	projectile_type = /obj/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/projectile/beam/weak
	variance = 0.8
	click_cooldown_override = 1

/obj/item/ammo_casing/caseless/laser/lasgun
	projectile_type = /obj/projectile/beam/laser/lasgun

/obj/item/ammo_casing/caseless/laser/longlas
	projectile_type = /obj/projectile/beam/laser/lasgun/longlas

/obj/item/ammo_casing/caseless/laser/laspistol
	projectile_type = /obj/projectile/beam/laser/lasgun/hotshot

/obj/item/ammo_casing/caseless/laser/hotshot
	projectile_type = /obj/projectile/beam/laser/lasgun/laspistol
