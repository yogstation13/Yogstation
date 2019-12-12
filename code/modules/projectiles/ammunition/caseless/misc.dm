/obj/item/ammo_casing/caseless/laser
	name = "laser casing"
	desc = "You shouldn't be seeing this."
	caliber = "laser"
	icon_state = "s-casing-live"
	projectile_type = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/item/projectile/beam/weak
	variance = 0.8
	click_cooldown_override = 1

/obj/item/ammo_casing/caseless/kineticspear
	name = "kinetic spear"
	desc = "A specialized spear rigged to deliver a weak kinetic blast on contact with fauna."
	projectile_type = /obj/item/projectile/bullet/reusable/kineticspear
	caliber = "speargun"
	icon = 'yogstation/icons/obj/ammo.dmi'
	icon_state = "kineticspear"
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/pod/PopulateContents()
	. = ..()
	new /obj/item/ammo_casing/caseless/kineticspear(src)
	new /obj/item/ammo_casing/caseless/kineticspear(src)
