/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/projectile/plasma
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	delay = 15
	e_cost = 25

/obj/item/ammo_casing/energy/plasma/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/plasmacutter))
		var/obj/item/gun/energy/plasmacutter/PC = loc
		PC.modify_projectile(BB)

/obj/item/ammo_casing/energy/plasma/weak
	projectile_type = /obj/projectile/plasma/weak
	select_name = "weak plasma burst"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	e_cost = 65

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/projectile/plasma/adv
	delay = 10
	e_cost = 10

//cool alien plasma beams
/obj/item/ammo_casing/energy/plasma/stalwart
	projectile_type = /obj/projectile/plasma/scatter/adv/stalwart
	fire_sound = 'sound/weapons/pulse.ogg'
	delay = 5
	e_cost = 50
	pellets = 4
	variance = 22

/obj/item/ammo_casing/energy/plasma/adv/mega
	projectile_type = /obj/projectile/plasma/adv/mega

/obj/item/ammo_casing/energy/plasma/scatter
	projectile_type = /obj/projectile/plasma/scatter
	delay = 15
	e_cost = 35
	pellets = 6
	variance = 30

/obj/item/ammo_casing/energy/plasma/scatter/adv
	projectile_type = /obj/projectile/plasma/scatter/adv

/obj/item/ammo_casing/energy/plasma/scatter/adv/mega
	projectile_type = /obj/projectile/plasma/scatter/adv/mega

/obj/item/ammo_casing/energy/plasma/adv/cyborg
	projectile_type = /obj/projectile/plasma/adv
	delay = 10
	e_cost = 15 // Might need nerfing

/obj/item/ammo_casing/energy/plasma/adv/cyborg/malf
	projectile_type = /obj/projectile/plasma/adv/malf
	e_cost = 50
