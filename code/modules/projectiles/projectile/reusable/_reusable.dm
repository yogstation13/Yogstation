/obj/item/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/obj/item/ammo_casing/ammo_type
	var/dropped = FALSE
	impact_effect_type = null

/obj/item/projectile/bullet/reusable/on_hit(atom/target, blocked = FALSE)
	. = ..()
	handle_drop(target)

/obj/item/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/item/projectile/bullet/reusable/proc/handle_drop(atom/target)
	if(dropped || !ammo_type)
		return

	var/turf/T = get_turf(src)
	var/obj/item/thing_to_drop = ispath(ammo_type) ? new ammo_type(T) : ammo_type
	thing_to_drop.forceMove(T)

	if(istype(ammo_type, /obj/item/ammo_casing/reusable))
		var/obj/item/ammo_casing/reusable/reusable_to_drop = thing_to_drop
		reusable_to_drop.on_land(src)

	dropped = TRUE
