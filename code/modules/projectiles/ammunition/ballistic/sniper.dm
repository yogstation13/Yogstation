// .50 BMG (Sniper)

/obj/item/ammo_casing/p50
	name = ".50 BMG bullet casing"
	desc = "A .50 BMG bullet casing."
	caliber = CALIBER_50BMG
	projectile_type = /obj/projectile/bullet/p50
	icon_state = ".50"

/obj/item/ammo_casing/p50/soporific
	name = ".50 BMG soporific bullet casing"
	desc = "A .50 BMG bullet casing, specialised in sending the target to sleep, instead of hell."
	projectile_type = /obj/projectile/bullet/p50/soporific
	icon_state = "sleeper"
	harmful = FALSE

/obj/item/ammo_casing/p50/penetrator
	name = ".50 BMG penetrator round bullet casing"
	desc = "A .50 BMG penetrator bullet casing."
	projectile_type = /obj/projectile/bullet/p50/penetrator
