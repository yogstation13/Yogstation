/obj/item/electrical_stasis_manifold
	name = "electrical stasis manifold"
	icon = 'icons/obj/device.dmi'
	icon_state = "empar"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/electrical_stasis_manifold/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, src, 1, stun = FALSE))
			visible_message(span_danger("\The [src] crumbles after discharging all of its energy!"))
			qdel(src)

/obj/item/organic_augur
	name = "organic augur"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "slime"
	w_class = WEIGHT_CLASS_NORMAL
