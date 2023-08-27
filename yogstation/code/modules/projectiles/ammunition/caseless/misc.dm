/obj/item/ammo_casing/reusable/kineticspear
	name = "kinetic spear"
	desc = "A specialized spear rigged to deliver a weak kinetic blast on contact with fauna."
	projectile_type = /obj/item/projectile/bullet/reusable/kineticspear
	caliber = "speargun"
	icon = 'yogstation/icons/obj/ammo.dmi'
	icon_state = "kineticspear"
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/pod/PopulateContents()
	. = ..()
	new /obj/item/ammo_casing/reusable/kineticspear(src)
	new /obj/item/ammo_casing/reusable/kineticspear(src)
