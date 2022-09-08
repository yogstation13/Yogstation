// 7.62 (Nagant Rifle)

/obj/item/ammo_casing/a762
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet/a762

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/item/projectile/bullet/a762_enchanted

// 5.56mm (M-90gl Rifle + NT ARG)

/obj/item/ammo_casing/a556
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	icon_state = "556-casing"
	caliber = "a556"
	projectile_type = /obj/item/projectile/bullet/a556

/obj/item/ammo_casing/a556/ap
	name = "5.56mm armor-piercing bullet casing"
	desc = "A 5.56mm armor-piercing bullet casing."
	icon_state = "556ap-casing"
	projectile_type = /obj/item/projectile/bullet/a556/ap

/obj/item/ammo_casing/a556/inc
	name = "5.56mm incendiary bullet casing"
	desc = "A 5.56mm incendiary bullet casing."
	icon_state = "556i-casing"
	projectile_type = /obj/item/projectile/bullet/incendiary/a556

/obj/item/ammo_casing/a556/rubber
	name = "5.56mm rubber bullet casing"
	desc = "A 5.56mm rubber bullet casing."
	icon_state = "556r-casing"
	projectile_type = /obj/item/projectile/bullet/a556/rubber

// .308 (LWT-650 DMR)

/obj/item/ammo_casing/m308
	name = ".308 bullet casing"
	desc = "A .308 bullet casing."
	icon_state = "556-casing"
	caliber = "m308"
	projectile_type = /obj/item/projectile/bullet/m308

/obj/item/ammo_casing/m308/pen
	name = ".308 penetrator bullet casing"
	desc = "A .308 penetrator bullet casing."
	icon_state = "556pen-casing"
	projectile_type = /obj/item/projectile/bullet/m308/pen

/obj/item/ammo_casing/m308/laser
	name = ".308 heavy laser bullet casing"
	desc = "A .308 heavy laser bullet casing."
	icon_state = "556l-casing"
	projectile_type = /obj/item/projectile/beam/laser/heavylaser

// 40mm (Grenade Launcher)

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = /obj/item/projectile/bullet/a40mm
