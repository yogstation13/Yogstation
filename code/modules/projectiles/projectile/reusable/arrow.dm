/obj/item/projectile/bullet/reusable/arrow
	name = "Wooden arrow"
	desc = "Woosh!"
	damage = 20
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/wood

/obj/item/projectile/bullet/reusable/arrow/ash
	name = "Ashen arrow"
	desc = "Fire Hardened arrow."
	damage = 30
	ammo_type = /obj/item/ammo_casing/caseless/arrow/ash

/obj/item/projectile/bullet/reusable/arrow/bone //AP for ashwalkers
	name = "Bone arrow"
	desc = "An arrow made from bone and sinew."
	damage = 30
	armour_penetration = 40
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone

/obj/item/projectile/bullet/reusable/arrow/bronze
	name = "Bronze arrow"
	desc = "Bronze tipped arrow"
	damage = 25
	armour_penetration = 10
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bronze

/obj/item/projectile/bullet/reusable/arrow/bola
	name = "Bola arrow"
	desc = "An arrow with a bola wrapped around it"
	var/obj/item/restraints/legcuffs/bola/bola

/obj/item/projectile/bullet/reusable/arrow/bola/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		return bola.impactCarbon(target)
	if(isanimal(target))
		return bola.impactAnimal(target)
/*
/obj/item/projectile/bullet/reusable/arrow/explosive
	name = "Explosive arrow"
	desc = "An arrow with an explosive attached to it"
	damage = 20
	armour_penetration = 10
	var/obj/item/grenade/explosive = null

/obj/item/projectile/bullet/reusable/arrow/explosive/prehit(atom/target)
	. = ..()
	explosive.forceMove(target)
	explosive.prime()
	visible_message("[explosive]")
*/
/obj/item/projectile/bullet/reusable/arrow/flaming
	name = "Flaming arrow"
	desc = "A burning arrow"
	damage = 20
	armour_penetration = 10

/obj/item/projectile/bullet/reusable/arrow/flaming/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/energy/arrow
	name = "energy bolt"
	icon_state = "arrow_energy"
	damage = 30
	damage_type = BURN

/obj/item/projectile/energy/arrow/disabler
	name = "disabler bolt"
	icon_state = "arrow_disable"
	light_color = LIGHT_COLOR_BLUE
	damage = 40
	damage_type = STAMINA
	nodamage = TRUE

/*
/obj/item/projectile/energy/arrow/pulse
	name = "pulse bolt"
	icon_state = "arrow_pulse"
	light_color = LIGHT_COLOR_BLUE
	damage = 50
	damage_type = BURN

/obj/item/projectile/energy/arrow/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target
*/

/obj/item/projectile/energy/arrow/xray
	name = "X-ray bolt"
	icon_state = "arrow_xray"
	light_color = LIGHT_COLOR_GREEN
	damage = 20
	irradiate = 300
	range = 15
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF

/obj/item/projectile/energy/arrow/clockbolt
	name = "redlight bolt"
