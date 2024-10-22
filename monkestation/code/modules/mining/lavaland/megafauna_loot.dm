/obj/item/mayhem/examine(mob/user)
	. = ..()
	. += span_notice("Also makes you deal a lot of damage to fauna. It'd be best to use it alone for that, though.")
	. += span_notice("Additionally, grants lifesteal based on damage dealt.")
