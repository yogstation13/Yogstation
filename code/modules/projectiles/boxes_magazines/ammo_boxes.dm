
/obj/item/ammo_container/box
	name = "ammo box"
	desc = "A container of ammo."

/obj/item/ammo_container/box/AltClick(mob/user)
	. = ..()
	if(user.is_holding(src))
		attack_self(user)

/obj/item/ammo_container/box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 30

/obj/item/ammo_container/box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 20

/obj/item/ammo_container/box/c10mm/sp
	name = "ammo box (10mm soporific)"
	ammo_type = /obj/item/ammo_casing/c10mm/sp

/obj/item/ammo_container/box/c10mm/ap
	name = "ammo box (10mm armor-piercing)"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_container/box/c10mm/hp
	name = "ammo box (10mm hollow-point)"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_container/box/c10mm/inc
	name = "ammo box (10mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c10mm/inc

/obj/item/ammo_container/box/c10mm/emp
	name = "ammo box (10mm EMP)"
	ammo_type = /obj/item/ammo_casing/c10mm/emp

/obj/item/ammo_container/box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_container/box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = "40mm"
	max_ammo = 4
	multiple_sprites = AMMO_CONTAINER_PER_BULLET

/obj/item/ammo_container/box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip holding 7.62mm rounds."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 5
	multiple_sprites = AMMO_CONTAINER_PER_BULLET

/obj/item/ammo_container/box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"
	max_ammo = 40
	materials = list(/datum/material/iron = 500)

/obj/item/ammo_container/box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	materials = list(/datum/material/iron = 50000)
