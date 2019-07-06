#define XENOARCH_SPUR_SPAWN_POLARSTAR 0
#define XENOARCH_SPUR_SPAWN_MODKIT 1
#define XENOARCH_SPUR_SPAWN_NOTHING 2
//this is currently unimplemented but it will be used in order to prevent multiple 
// guns from spawning as only 1 copy should exists in the game would at any time

GLOBAL_VAR_INIT(polarstar, XENOARCH_SPUR_SPAWN_POLARSTAR)

/obj/item/gun/energy/polarstar
	name = "Polar Star"
	desc = "Despite being incomplete, the severe wear on this gun shows to which extent it's been used already."
	icon = 'yogstation/icons/obj/xenoarch/guns.dmi'
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/xenoarch_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/xenoarch_righthand.dmi'
	icon_state = "polarstar"
	item_state = "polarstar"
	slot_flags = SLOT_BELT
	fire_delay = 1
	recoil = 1
	cell_type = /obj/item/stock_parts/cell

	var/fire_power = "" //TODO MAYBE?












//#################//
//###PROJECTILES###//
//#################//

/obj/item/ammo_casing/energy/polarstar
	projectile_type = /obj/item/projectile/bullet/polarstar
	select_name = "polar star lens"
	e_cost = 100
	fire_sound = null
	harmful = TRUE


/obj/item/projectile/bullet/polarstar
	name = "polar star bullet"
	range = 100
	damage = 40
	damage_type = BRUTE
	icon = 'yogstation/icons/obj/xenoarch/guns.dmi'
	icon_state = "spur_high"
	
/obj/item/projectile/bullet/polarstar/fire(angle, atom/direct_target)
	if(!fired_from || !istype(fired_from,/obj/item/gun/energy))
		return ..()
	
	var/obj/item/gun/energy/fired_gun = fired_from

	switch(fired_gun.cell.maxcharge)

