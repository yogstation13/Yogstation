/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart	
	caliber = CALIBER_FOAM
	var/hugbox = FALSE

/obj/item/ammo_box/magazine/toy/Initialize(mapload)
	. = ..()
	if(hugbox) //noob
		name = "safety-first [name]"

/obj/item/ammo_box/magazine/toy/attempt_load(obj/item/A, mob/user, silent, replace_spent)
	if(istype(A, /obj/item/ammo_casing/reusable/foam_dart/riot) && hugbox)
		to_chat(user, span_danger("The dart seems to be blocked from entering by a bright orange piece of plastic! How annoying."))
		return
	..()

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	. = ..()
	if(ammo_count())
		icon_state = "smg9mm-42"
	else
		icon_state = "smg9mm-0"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 10
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	icon_state = "c20r45-toy"
	caliber = CALIBER_FOAM
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	. = ..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/smgm45/riot
	icon_state = "c20r45-riot"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	icon_state = "a762-toy"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	max_ammo = 50

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	. = ..()
	icon_state = "a762-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/toy/m762/riot
	icon_state = "a762-riot"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

//Hugboxed mags for roundstart vendors.
/obj/item/ammo_box/magazine/toy/smg/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/toy/pistol/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/toy/m762/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/toy/smgm45/hugbox
	hugbox = TRUE
