/datum/condition_hormone
	var/name = "Hormone"
	var/measurement = "µIU/mL"
	var/normal_range_start = 100
	var/normal_range_end = 200

	var/true_range_start = 0
	var/true_range_end = 0

/datum/condition_hormone/New()
	true_range_start = normal_start_range
	true_range_end 	 = normal_range_end


/datum/condition_hormone/proc/get_multiplier()
	var/mult = abs(sin(world.time / 1000)) + rand(-0.1, 0.2)
	return mult

/datum/condition_hormone/proc/get_normal_value()
	return normal_range_start + (normal_range_end * get_multiplier())

/datum/condition_hormone/proc/get_true_value() 
	return true_range_start + (true_range_end * get_multiplier())
