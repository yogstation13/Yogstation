/obj/item/electrical_stasis_manifold
	name = "electrical stasis manifold"
	desc = "Highly unstable and valuable for research."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "e_stasis_manifold"
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
	desc = "Gross... Highly valuable for research."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "organic_augur"
	w_class = WEIGHT_CLASS_NORMAL
