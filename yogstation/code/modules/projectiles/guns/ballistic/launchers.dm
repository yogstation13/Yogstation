/obj/item/gun/ballistic/automatic/speargun
	name = "survival speargun"
	desc = "A heavily stripped down survival weapon built to combat fauna. Fires kinetic spears that must be retrieved after use."
	icon = 'yogstation/icons/obj/guns/projectile.dmi'
	icon_state = "kineticspeargun"
	item_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	can_suppress = FALSE
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	actions_types = list()
	casing_ejector = FALSE

/obj/item/gun/ballistic/automatic/speargun/update_icon()
	return

/obj/item/gun/ballistic/automatic/speargun/attack_self()
	return

/obj/item/gun/ballistic/automatic/speargun/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] spear\s into \the [src].</span>")
		update_icon()
		chamber_round()

/obj/item/storage/pod/PopulateContents()
	. = ..()
	new /obj/item/gun/ballistic/automatic/speargun(src)
	new /obj/item/gun/ballistic/automatic/speargun(src)