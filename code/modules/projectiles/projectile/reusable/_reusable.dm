/obj/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/obj/item/ammo_casing/ammo_type
	var/dropped = FALSE
	impact_effect_type = null

/obj/projectile/bullet/reusable/on_hit(atom/target, blocked = FALSE)
	. = ..()
	handle_drop(target, blocked)

/obj/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/projectile/bullet/reusable/proc/handle_drop(atom/target, blocked)
	if(dropped || !ammo_type)
		return

	var/turf/T = get_turf(src)
	var/obj/item/thing_to_drop = ispath(ammo_type) ? new ammo_type(src) : ammo_type

	if(CHECK_BITFIELD(thing_to_drop.item_flags, DROPDEL)) // Delete it if it has the dropdel flag
		qdel(thing_to_drop)
		dropped = TRUE
		return

	thing_to_drop.forceMove(T)

	if(istype(ammo_type, /obj/item/ammo_casing/reusable))
		var/obj/item/ammo_casing/reusable/reusable_to_drop = thing_to_drop
		reusable_to_drop.on_land(src)

	dropped = TRUE
