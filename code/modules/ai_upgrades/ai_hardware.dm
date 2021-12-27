/obj/item/ai_hardware
	name = "BUG!"
	desc = "I am a filthy bug. Report me!"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/gold=50)

	var/power_consumption = 0

	var/cpu_power = 0
	var/memory_capacity = 0

/obj/item/ai_hardware/Initialize()
	. = ..()
	calculate_power_usage()

/obj/item/ai_hardware/proc/calculate_efficiency()
	var/theoretical_usage = cpu_power * AI_BASE_POWER_PER_CPU

	return round(theoretical_usage / consumption * 100, 0.5)

/obj/item/ai_hardware/proc/calculate_power_usage()
	power_consumption = cpu_power * AI_BASE_POWER_PER_CPU
