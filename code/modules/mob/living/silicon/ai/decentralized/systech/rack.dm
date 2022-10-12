/obj/item/server_rack
	name = "server rack"
	desc = "A self-contained rack for usage in an artifical intelligence system. Ready to be slotted into a server rack and start working."
	icon = 'icons/obj/module.dmi'
	icon_state = "server_rack"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/gold=50, /datum/material/iron=250)

	var/list/contained_cpus = list()
	var/contained_ram = 0

/obj/item/server_rack/examine(mob/user)
	. = ..()
	var/total = get_cpu()
	for(var/obj/item/ai_cpu/CPU in contained_cpus)
		. += span_notice("It has [CPU] installed. Running at [CPU.speed]THz and consuming [CPU.get_power_usage()]W.")
	. += span_notice("For a total CPU speed of [total]THz")
	. += span_notice("----------------------")
	. += span_notice("It currently has [get_ram()]TB's of RAM installed.")
	. += span_notice("It consumes [get_power_usage()]W's of electricity.")

/obj/item/server_rack/proc/get_cpu()
	var/amount = 0
	for(var/obj/item/ai_cpu/CPU in contained_cpus)
		amount += CPU.speed
	return amount

/obj/item/server_rack/proc/get_ram()
	return contained_ram

/obj/item/server_rack/proc/get_power_usage()
	var/usage = 0
	for(var/obj/item/ai_cpu/CPU in contained_cpus)
		usage += CPU.get_power_usage()
	usage += contained_ram * AI_RAM_POWER_USAGE
	return usage

/obj/item/server_rack/roundstart/Initialize()
	. = ..()
	var/obj/item/ai_cpu/CPU = new(src)
	contained_cpus += CPU
	contained_ram = 1
