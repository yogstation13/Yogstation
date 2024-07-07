/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	caliber = CALIBER_FOAM
	max_ammo = 4
	var/hugbox = FALSE

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/toy/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/internal/shot/toy/attempt_load(obj/item/A, mob/user, silent, replace_spent)
	if(istype(A, /obj/item/ammo_casing/reusable/foam_dart/riot) && hugbox)
		to_chat(user, span_danger("The dart seems to be blocked from entering by a bright orange piece of plastic! How annoying."))
		return
	..()
	
