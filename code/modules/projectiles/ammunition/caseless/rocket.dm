/obj/item/ammo_casing/caseless/rocket
	name = "\improper PM-9HE"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = "84mm"
	icon_state = "srm-8"
	projectile_type = /obj/item/projectile/bullet/a84mm_he

/obj/item/ammo_casing/caseless/rocket/hedp
	name = "\improper PM-9HEDP"
	desc = "An 84mm High Explosive Dual Purpose rocket. Pointy end toward mechs."
	caliber = "84mm"
	icon_state = "84mm-hedp"
	projectile_type = /obj/item/projectile/bullet/a84mm

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	icon_state = "s-casing-live"
	projectile_type = /obj/item/projectile/bullet/gyro


/obj/item/ammo_casing/caseless/cannonball
	name = "cannonball"
	desc = "A big ball of lead, perfect for shooting through windows and doors."
	caliber = "100mm"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "cannonball"
	projectile_type = /obj/item/projectile/bullet/cball
	w_class = WEIGHT_CLASS_NORMAL //cannonballs hefty

/obj/item/ammo_casing/caseless/bolts
	name = "bolts"
	desc = "shorter, more gud rods"
	caliber = null
	icon = 'icons/obj/ammo.dmi'
	icon_state = "bolt"
	projectile_type = /obj/item/projectile/bullet/bolt
	firing_effect_type = /obj/effect/particle_effect/sparks/electricity
	w_class = WEIGHT_CLASS_TINY
	var/e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
