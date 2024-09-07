/obj/item/gun/ballistic/automatic/pistol/usp
	name = "USP Match"
	desc = "A small and light 9mm pistol which is often used as a metropolice standard carry."
	icon = 'icons/obj/guns/halflife/projectile.dmi'
	icon_state = "uspmatch"
	mag_type = /obj/item/ammo_box/magazine/usp9mm
	can_suppress = TRUE
	fire_sound = "sound/weapons/halflife/uspfire.ogg"
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"

/obj/item/gun/ballistic/automatic/pistol/usp/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/usp/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)


//Exclusively loot pistols. Rare, and the ammunition will be hard to attain. Much less ammo capacity than the USP match, but slightly higher damage.
/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity. This is a very old model by this point."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE
	fire_sound = "sound/weapons/pistolshotsmall.ogg"
	feedback_types = list(
		"fire" = 3
	)

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE


/obj/item/gun/ballistic/revolver/coltpython
	name = "\improper colt python"
	desc = "An old colt python revolver. Uses .357 magnum ammo."
	fire_sound = "sound/weapons/halflife/revolverfire.ogg"
	icon_state = "colt_python"
	item_state = "colt_python"
	spread = 3 //less spread
