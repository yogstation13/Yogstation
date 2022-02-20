/obj/item/ai_cpu
	name = "neural processing unit"
	desc = "A processor specialized in the tasks that a neural network such as the AI might perform. For usage in server racks only."

	icon = 'icons/obj/module.dmi'
	icon_state = "cpuboard"

	w_class = WEIGHT_CLASS_SMALL

	var/speed = 1
	var/base_power_usage = AI_CPU_BASE_POWER_USAGE
	var/power_multiplier = 1

/obj/item/ai_cpu/proc/get_power_usage()
	return base_power_usage * power_multiplier

/obj/item/ai_cpu/proc/get_efficiency()
	return 1 / power_multiplier * 100
