#define OVERCLOCK_MIN_POWER_MULT -0.5

#define SUCCESSFUL_OVERCLOCK "success"
#define FAILED_OVERCLOCK_SPEED "Clockspeed too high"
#define FAILED_OVERCLOCK_POWER "Power Multiplier too high"
#define FAILED_OVERCLOCK_NO_POWER "Power Multiplier too low"

/obj/item/ai_cpu
	name = "neural processing unit"
	desc = "A processor specialized in the tasks that a neural network such as the AI might perform. For usage in server racks only."

	icon = 'icons/obj/module.dmi'
	icon_state = "cpuboard"

	w_class = WEIGHT_CLASS_SMALL

	var/speed = 1
	var/base_power_usage = AI_CPU_BASE_POWER_USAGE
	var/power_multiplier = 1

	var/max_power_multiplier = 1
	var/growth_scale = 1

	//Multipliers
	var/minimum_max_power = 1.25
	var/maximum_max_power = 2

	//Lower value means speed and power is more linear
	var/minimum_growth = 0.7
	//High values means its easier to get a high overclock at low power
	var/maximum_growth = 3.5

	var/list/last_overclocking_values = list()



/obj/item/ai_cpu/Initialize()
	growth_scale = rand(minimum_growth * 100, maximum_growth * 100) / 100
	max_power_multiplier = (rand(minimum_max_power * 100, maximum_max_power * 100) / 100) * power_multiplier

	return ..() 

/obj/item/ai_cpu/proc/valid_overclock()
	if(power_multiplier == initial(power_multiplier) && speed == initial(speed))
		return SUCCESSFUL_OVERCLOCK

	if((power_multiplier - 1) < OVERCLOCK_MIN_POWER_MULT)
		return FAILED_OVERCLOCK_NO_POWER

	//logistic formula:
	//y = 2/1+e^(-growth_scale*x) where x = power_multiplier - 1. Maximum of 94% faster at 200% power multiplier. Minimum of 34% faster at 200% power multiplier
	//9% faster at 25% power multiplier, growth = 0.7.
	//41% faster at 25% power multiplier, growth = 3.5
	var/optimal_speed_mult = 2 / (1 + NUM_E ** (-growth_scale*(power_multiplier - 1)))

	if(power_multiplier > max_power_multiplier)
		return FAILED_OVERCLOCK_POWER

	if(speed >= initial(speed) * optimal_speed_mult)
		return FAILED_OVERCLOCK_SPEED
	return SUCCESSFUL_OVERCLOCK

/obj/item/ai_cpu/proc/get_power_usage()
	return base_power_usage * power_multiplier

/obj/item/ai_cpu/proc/get_efficiency()
	return 1 / (power_multiplier / initial(power_multiplier)) * 100

/obj/item/ai_cpu/advanced
	name = "advanced neural processing unit"
	desc = "A processor specialized in the tasks that a neural network such as the AI might perform. For usage in server racks only. This chip features advanced branch-prediction and optimized memory access."
	icon_state = "cpuboard_adv"

	speed = 2
	base_power_usage = 1.75 * AI_CPU_BASE_POWER_USAGE


/obj/item/ai_cpu/bluespace
	name = "bluespace neural processing unit"
	desc = "A processor specialized in the tasks that a neural network such as the AI might perform. For usage in server racks only. This chip exploits advances in bluespace technology to shrink components even further."
	icon_state = "cpuboard_super"

	speed = 3
	base_power_usage = 2.5 * AI_CPU_BASE_POWER_USAGE

/obj/item/ai_cpu/experimental
	name = "experimental neural processing unit"
	desc = "A processor specialized in the tasks that a neural network such as the AI might perform. For usage in server racks only. This chip features loose quality-control and as a result of this has more varied overclocking parameters"
	icon_state = "cpuboard_adv"

	speed = 2
	base_power_usage = 2 * AI_CPU_BASE_POWER_USAGE

	minimum_max_power = 1.1
	maximum_max_power = 2.5

	minimum_growth = 0.5 //Basically linear at this point
	maximum_growth = 4.5 //max speed achievable at 2.2x power consumption.
