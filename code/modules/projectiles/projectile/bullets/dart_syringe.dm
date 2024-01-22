/obj/projectile/bullet/reusable/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	var/piercing = FALSE

/obj/projectile/bullet/reusable/dart/Initialize(mapload)
	. = ..()

/obj/projectile/bullet/reusable/dart/proc/add_dart(obj/item/reagent_containers/new_dart, syrpierce)
	piercing = syrpierce
	ammo_type = new_dart
	new_dart.forceMove(src)
	name = new_dart.name

/obj/projectile/bullet/reusable/dart/handle_drop(mob/living/carbon/target, blocked)
	if(dropped || !isitem(ammo_type) || !iscarbon(target))
		return ..()

	if(blocked >= 100 || !target.can_inject(null, FALSE, def_zone, piercing) || !target.embed_object(ammo_type, def_zone, FALSE))  // The bulk of the code to actualy embbed the dart is here, its all stacked up so we don't have to copy the fail text multiple times
		target.visible_message(span_danger("\The [ammo_type] was deflected!"), \
		span_userdanger("You were protected against \the [ammo_type]!"))
	else
		dropped = TRUE // If we got here, the dart should already be embedded so we just need to mark it as dropped to prevent further handle_drop stuff from messing it up

	return ..() // Run further handle_drop stuff, for if the syringe doesn't embbed in the target

/obj/projectile/bullet/reusable/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"

/obj/projectile/bullet/reusable/dart/syringe/blowgun
	name = "syringe"
	icon_state = "syringeproj"
	range = 2

/obj/projectile/bullet/reusable/dart/hidden
	name = "beanbag slug"
	icon_state = "bullet" //So it doesn't look like a goddamned syringe
	stamina = 5 // gotta act like we did stamina
	sharpness = SHARP_NONE
