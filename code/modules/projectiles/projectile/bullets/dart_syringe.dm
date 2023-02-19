/obj/item/projectile/bullet/reusable/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	var/obj/item/reagent_containers/container
	var/piercing = FALSE

/obj/item/projectile/bullet/reusable/dart/hidden
	name = "beanbag slug"
	stamina = 5 // gotta act like we did stamina
	sharpness = SHARP_NONE

// don't want our "beanbag slugs" dropping reagent darts everywhere
/obj/item/projectile/bullet/reusable/dart/hidden/handle_drop()
	if(!dropped)
		QDEL_NULL(container)
		dropped = TRUE

/obj/item/projectile/bullet/reusable/dart/Initialize()
	. = ..()

/obj/item/projectile/bullet/reusable/dart/on_hit(atom/target, blocked = FALSE)
	if(!istype(ammo_type))
		return BULLET_ACT_HIT
	if(iscarbon(target) && (blocked < 100))
		var/mob/living/carbon/C = target

		if(C.can_inject(null, FALSE, def_zone, piercing) && C.embed_object(ammo_type, def_zone, FALSE))
			dropped = TRUE
			..()
			return BULLET_ACT_HIT
		else
			target.visible_message(span_danger("\The [ammo_type] was deflected!"), \
		span_userdanger("You were protected against \the [ammo_type]!"))
	if(blocked >= 100)
		target.visible_message(span_danger("\The [ammo_type] was deflected!"), \
		span_userdanger("You were protected against \the [ammo_type]!"))
	..(target, blocked)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/reusable/dart/proc/add_dart(obj/item/reagent_containers/new_dart, syrpierce)
	piercing = syrpierce
	ammo_type = new_dart
	new_dart.forceMove(src)
	name = new_dart.name

/obj/item/projectile/bullet/reusable/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"
