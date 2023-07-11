/obj/item/gun/ballistic/speargun
	name = "survival speargun"
	desc = "A heavily stripped down survival weapon built to combat fauna. Fires kinetic spears that must be retrieved after use."
	icon = 'yogstation/icons/obj/guns/projectile.dmi'
	icon_state = "kineticspeargun"
	item_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	bolt_type = BOLT_TYPE_NO_BOLT
	can_suppress = FALSE
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	casing_ejector = FALSE
	internal_magazine = TRUE

/obj/item/gun/ballistic/speargun/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/gun/ballistic/speargun/attack_self()
	return

/obj/item/storage/pod/PopulateContents()
	. = ..()
	new /obj/item/gun/ballistic/speargun(src)
	new /obj/item/gun/ballistic/speargun(src)
