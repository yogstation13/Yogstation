/obj/item/projectile/bullet/reusable/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	var/obj/item/reagent_containers/container
	var/piercing = FALSE

/obj/item/projectile/bullet/reusable/dart/Initialize()
	. = ..()

/obj/item/projectile/bullet/reusable/dart/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(blocked != 100) // not completely blocked
			if(C.embed_object(container, def_zone, FALSE))
				dropped = TRUE
				..()
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message(span_danger("\The [container] was deflected!"), \
									   span_userdanger("You were protected against \the [container]!"))

	..(target, blocked)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/reusable/dart/handle_drop()
	if(!dropped)
		container.forceMove(get_turf(src))
		dropped = TRUE

/obj/item/projectile/bullet/reusable/dart/proc/add_dart(obj/item/reagent_containers/new_dart)
	container = new_dart
	new_dart.forceMove(src)
	name = new_dart.name
	if(istype(new_dart, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/syringe
		piercing = syringe.proj_piercing

/obj/item/projectile/bullet/reusable/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"
