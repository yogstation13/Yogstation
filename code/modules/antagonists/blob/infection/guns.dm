//RIFLE
/obj/item/gun/ballistic/automatic/ar/infection
	name = "\improper M-46 AR"
	desc = "A stanard-issue assault rifle used by Nanotrasen soldiers."
	mag_type = /obj/item/ammo_box/magazine/m556/infection
	burst_size = 2
	fire_delay = 1.4

/obj/item/ammo_box/magazine/m556/infection
	name = "magazine (5.56mm)"
	icon_state = "5.56m"
	ammo_type = /obj/item/ammo_casing/caseless/a556/infection
	caliber = "a556"
	max_ammo = 20

/obj/item/ammo_box/magazine/m556/infection/lazarus
	name = "lazarus magazine (5.56mm)"
	icon_state = "5.56mp"
	ammo_type = /obj/item/ammo_casing/caseless/a556/infection/lazarus
	max_ammo = 20

/obj/item/ammo_box/magazine/m556/infection/purifier
	name = "purifier magazine (5.56mm)"
	icon_state = "5.56ml"
	ammo_type = /obj/item/ammo_casing/caseless/a556/infection/purifier
	max_ammo = 20

/obj/item/ammo_casing/caseless/a556/infection
	projectile_type = /obj/item/projectile/bullet/a556/infection

/obj/item/projectile/bullet/a556/infection
	damage = 20

/obj/item/ammo_casing/caseless/a556/infection/purifier
	projectile_type = /obj/item/projectile/bullet/a556/infection/purifier

/obj/item/projectile/bullet/a556/infection/purifier
	damage = 40

/obj/item/ammo_casing/caseless/a556/infection/lazarus
	projectile_type = /obj/item/projectile/bullet/a556/infection/lazarus

/obj/item/projectile/bullet/a556/infection/lazarus
	damage = 30

//PISTOL
/obj/item/gun/ballistic/automatic/pistol/infection
	name = "service pistol"
	desc = "A small & weak 10mm handgun. Used by Nanotrasen soldiers when they run out of ammo"
	mag_type = /obj/item/ammo_box/magazine/m10mm/infection
	can_suppress = FALSE

/obj/item/ammo_box/magazine/m10mm/infection
	name = "pistol magazine (10mm)"
	desc = "A gun magazine."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/caseless/c10mm/infection

/obj/item/ammo_casing/caseless/c10mm/infection
	name = "10mm bullet casing"
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/c10mm/infection

/obj/item/projectile/bullet/c10mm/infection
	name = "10mm bullet"
	damage = 20

//GRASSCUTTER
/obj/item/gun/energy/pulse/pistol/infection
	name = "'Grasscutter' pistol"
	desc = "A self defense weapon in an easily concealed handgun package with low capacity."
	cell_type = "/obj/item/stock_parts/cell/pulse/pistol/infection"
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	selfcharge = 1

/obj/item/stock_parts/cell/pulse/pistol/infection
	name = "pulse pistol power cell"
	maxcharge = 500

//BIG BERTHA
/obj/item/minigunbackpack/infection
	name = "The 'Big Bertha' back stash"
	overheat_max = 40

/obj/item/minigunbackpack/infection/Initialize()
	. = ..()
	gun = new /obj/item/gun/ballistic/minigunosprey/bertha(src)

/obj/item/gun/ballistic/minigunosprey/bertha
	name = "M-472 'Big Berha'"
	desc = "A simple minigun firing biological destruction rounds. Requires a bulky backpack to store all that ammo."
	slowdown = 1.8
	fire_delay = 1
	spread = 34
	mag_type = /obj/item/ammo_box/magazine/internal/minigunosprey/infection

/obj/item/ammo_box/magazine/internal/minigunosprey/infection
	name = "Minigun back stash box"
	ammo_type = /obj/item/ammo_casing/a546/infection
	caliber = "a556"
	max_ammo = 600

/obj/item/ammo_casing/a546/infection
	projectile_type = /obj/item/projectile/bullet/a546/infection

/obj/item/projectile/bullet/a546/infection
	damage = 28