/obj/item/powersink/examine(mob/user)
	. = ..()
	. += "The power dial reads [num2text(power_drained)]J/[num2text(max_power)]J."
