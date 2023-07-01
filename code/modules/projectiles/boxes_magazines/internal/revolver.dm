/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38/rubber
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/tra32
	name = "\improper Caldwell revolver cylinder"
	ammo_type = /obj/item/ammo_casing/tra32
	caliber = "32trac"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/rev44
	name = "\improper Mateba revolver cylinder"
	ammo_type = /obj/item/ammo_casing/m44
	caliber = "44"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "\improper Nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = "n762"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "\improper Russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/rus357/Initialize(mapload)
	stored_ammo += new ammo_type(src)
	. = ..()

/obj/item/ammo_box/magazine/internal/cylinder/derringer
	name = "derringer revolver cylinder"
	max_ammo = 2
