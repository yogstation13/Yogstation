/obj/item/ammo_casing/reusable/foam_dart
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart
	caliber = "foam_force"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	materials = list(/datum/material/iron = 11.25)
	harmful = FALSE
	var/modified = FALSE
	var/obj/item/pen/pen

/obj/item/ammo_casing/reusable/foam_dart/update_icon()
	..()
	if (modified)
		icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)

/obj/item/ammo_casing/reusable/foam_dart/examine(mob/user)
	. = ..()
	if(modified)
		. += "This one doesn't look too safe."

/obj/item/ammo_casing/reusable/foam_dart/attackby(obj/item/A, mob/user, params)
	if (A.tool_behaviour == TOOL_SCREWDRIVER && !modified)
		modified = TRUE
		to_chat(user, span_notice("You pop the safety cap off [src]."))
		update_icon()
	else if (istype(A, /obj/item/pen))
		if(modified)
			if(!pen)
				if(!user.transferItemToLoc(A, src))
					return
				harmful = TRUE
				pen = A
				to_chat(user, span_notice("You insert [A] into [src]."))
			else
				to_chat(user, span_warning("There's already something in [src]."))
		else
			to_chat(user, span_warning("The safety cap prevents you from inserting [A] into [src]."))
	else
		return ..()

/obj/item/ammo_casing/reusable/foam_dart/attack_self(mob/living/user)
	if(pen)
		user.put_in_hands(pen)
		pen = null
		harmful = FALSE
		to_chat(user, span_notice("You remove [pen] from [src]."))

/obj/item/ammo_casing/reusable/foam_dart/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	if(modified)
		BB.damage_type = BRUTE
	if(pen)
		BB.damage = 5
		BB.nodamage = FALSE
	BB.icon_state = "[icon_state]_proj"
	..()

/obj/item/ammo_casing/reusable/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/riot
	icon_state = "foamdart_riot"
	materials = list(/datum/material/iron = 1125)
