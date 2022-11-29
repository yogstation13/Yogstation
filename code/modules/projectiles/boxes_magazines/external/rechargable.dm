//Laser Rifle

/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
	icon_state = "oldrifle"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	caliber = LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_icon()
	..()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	if(ammo_count())
		icon_state = "oldrifle"
	else
		icon_state = "oldrifle_empty"

/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return


/obj/item/ammo_box/magazine/recharge/lasgun
	max_ammo = 30
	icon = 'icons/obj/guns/grimdark.dmi'
	icon_state = "lasgunmag"
	desc = "A rechargeable, detachable battery that serves as a magazine for las weaponry."
	
/obj/item/ammo_box/magazine/recharge/lasgun/update_icon()
	..()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	if(ammo_count())
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]_0"

/obj/item/ammo_box/magazine/recharge/lasgun/attack_self() //No popping out the "bullets"
	return

/obj/item/ammo_box/magazine/recharge/lasgun/pistol
	max_ammo = 15
	desc = "A smaller, lighter version of the standard lasgun power-pack. Holds less charge but fits into handguns."
	icon_state = "laspistolmag"

/obj/item/ammo_box/magazine/recharge/lasgun/hotshot
	max_ammo = 20
	desc = "A power-pack tuned to discharge more power with each shot, allowing for the hotshot lasgun to deal more damage."

/obj/item/ammo_box/magazine/recharge/lasgun/sniper
	max_ammo = 8
	desc = "A standard power-pack for las weaponry, this one expending more power into focusing shots so they land on far-away targets."
