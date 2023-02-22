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
	ammo_type = list(/obj/item/ammo_casing/energy/polarstar)
	var/chargesound

/obj/item/gun/energy/polarstar/New(loc, ...)
	. = ..()
	playsound(src, 'yogstation/sound/weapons/spur_spawn.ogg')

/obj/item/gun/energy/polarstar/update_icon(force_update)
	var/maxcharge = cell.maxcharge
	var/charge = cell.charge

	var/oldsound = chargesound
	var/obj/item/ammo_casing/energy/AC = ammo_type[select] //shouldnt be anything other than the normal but eh,adminbus resistance doesnt hurt
	if(charge >= ((maxcharge/3) * 2)) // 2 third charged
		chargesound = 'yogstation/sound/weapons/spur_chargehigh.ogg'
		recoil = 1
		fire_sound = 'yogstation/sound/weapons/spur_high.ogg'
	else if(charge >= ((maxcharge/3) * 1)) // 1 third charged
		chargesound = 'yogstation/sound/weapons/spur_chargemed.ogg'
		recoil = 0
		fire_sound = 'yogstation/sound/weapons/spur_medium.ogg'
	else if(charge >= AC.e_cost) // less than that
		chargesound = 'yogstation/sound/weapons/spur_chargehigh.ogg'
		recoil = 0
		fire_sound = 'yogstation/sound/weapons/spur_low.ogg'
	else
		chargesound = null
		recoil = 0
		fire_sound = 'yogstation/sound/weapons/spur_low.ogg'

	if(chargesound != oldsound)
		playsound(src, chargesound, 100)
		sleep(0.1 SECONDS)
		playsound(src, chargesound, 75)
	return

/obj/item/gun/energy/polarstar/spur
	name = "Spur"
	desc = "A masterpiece crafted by the legendary gunsmith of a far-away planet."
	icon_state = "spur"
	item_state = "spur"
	fire_delay = 0 //pewpew
	ammo_type = list(/obj/item/ammo_casing/energy/polarstar/spur)
	selfcharge = TRUE








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
	range = 20
	damage = 20
	damage_type = BRUTE
	icon = 'yogstation/icons/obj/xenoarch/guns.dmi'
	icon_state = "spur_high"
	var/skip = FALSE //this is the hackiest thing ive ever done but i dont know any other solution other than deparent the spur projectile

/obj/item/projectile/bullet/polarstar/fire(angle, atom/direct_target)
	if(!fired_from || !istype(fired_from,/obj/item/gun/energy) || skip)
		return ..()

	var/obj/item/gun/energy/polarstar/fired_gun = fired_from
	var/maxcharge = fired_gun.cell.maxcharge
	var/charge = fired_gun.cell.charge

	if(charge >= ((maxcharge/3) * 2)) // 2 third charged
		icon_state = "spur_high"
		damage = 20
		range = 20
	else if(charge >= ((maxcharge/3) * 1)) // 1 third charged
		icon_state = "spur_medium"
		damage = 15
		range = 13
	else
		icon_state = "spur_low"
		damage = 10
		range = 7
	..()

/obj/item/projectile/bullet/polarstar/on_range()
	if(!loc)
		return
	var/turf/T = loc
	var/image/impact = image('yogstation/icons/obj/xenoarch/guns.dmi',T,"spur_range")
	impact.layer = ABOVE_MOB_LAYER
	T.overlays += impact
	sleep(0.3 SECONDS)
	T.overlays -= impact
	qdel(impact)
	..()

/obj/item/projectile/bullet/polarstar/on_hit(atom/target, blocked)
	. = ..()
	var/impact_icon = null
	var/impact_sound = null

	if(ismob(target))
		impact_icon = "spur_hitmob"
		impact_sound = 'yogstation/sound/weapons/spur_hitmob.ogg'
	else
		impact_icon = "spur_hitwall"
		impact_sound = 'yogstation/sound/weapons/spur_hitwall.ogg'

	var/image/impact = image('yogstation/icons/obj/xenoarch/guns.dmi',target,impact_icon)
	target.overlays += impact
	spawn(30)
		target.overlays -= impact
	playsound(loc, impact_sound, 30)
	if(istype(target,/turf/closed/mineral))
		var/turf/closed/mineral/M = target
		M.attempt_drill()
	..()

/obj/item/ammo_casing/energy/polarstar/spur
	projectile_type = /obj/item/projectile/bullet/polarstar/spur
	select_name = "spur lens"


/obj/item/projectile/bullet/polarstar/spur
	name = "spur bullet"
	range = 20
	damage = 40
	damage_type = BRUTE
	icon = 'yogstation/icons/obj/xenoarch/guns.dmi'
	icon_state = "spur_high"
	skip = TRUE

/obj/item/projectile/bullet/polarstar/spur/fire(angle, atom/direct_target)
	if(!fired_from || !istype(fired_from,/obj/item/gun/energy))
		return ..()

	var/obj/item/gun/energy/polarstar/fired_gun = fired_from
	var/maxcharge = fired_gun.cell.maxcharge
	var/charge = fired_gun.cell.charge

	if(charge >= ((maxcharge/3) * 2)) // 2 third charged
		icon_state = "spur_high"
		damage = 40
		range = 20
	else if(charge >= ((maxcharge/3) * 1)) // 1 third charged
		icon_state = "spur_medium"
		damage = 30
		range = 13
	else
		icon_state = "spur_low"
		damage = 20
		range = 7
	..()
