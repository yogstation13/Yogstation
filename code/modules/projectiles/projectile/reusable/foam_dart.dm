/obj/item/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	nodamage = TRUE
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	var/modified = FALSE
	var/obj/item/pen/pen = null

/// Apply stamina damage to other toy gun users
/obj/item/projectile/bullet/reusable/foam_dart/on_hit(atom/target, blocked)
	. = ..()

	if(stamina > 0) // NO RIOT DARTS!!!
		return

	if(!iscarbon(target))
		return
	
	var/nerfed = FALSE
	var/mob/living/carbon/C = target
	for(var/obj/item/gun/ballistic/T in C.held_items) // Is usually just ~2 items
		if(ispath(T.mag_type, /obj/item/ammo_box/magazine/toy)) // All automatic foam force guns
			nerfed = TRUE
			break
		if(ispath(T.mag_type, /obj/item/ammo_box/magazine/internal/shot/toy)) // Foam force shotguns & crossbows
			nerfed = TRUE
			break
	
	if(!nerfed)
		return
	
	C.adjustStaminaLoss(25) // ARMOR IS CHEATING!!!

/obj/item/projectile/bullet/reusable/foam_dart/handle_drop()
	if(dropped)
		return
	var/turf/T = get_turf(src)
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newcasing = new ammo_type(T)
	newcasing.modified = modified
	var/obj/item/projectile/bullet/reusable/foam_dart/newdart = newcasing.BB
	newdart.modified = modified
	if(modified)
		newdart.damage = 5
		newdart.nodamage = FALSE
	newdart.damage_type = damage_type
	if(pen)
		newdart.pen = pen
		pen.forceMove(newdart)
		pen = null
	newdart.update_icon()


/obj/item/projectile/bullet/reusable/foam_dart/Destroy()
	pen = null
	return ..()

/obj/item/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 25
