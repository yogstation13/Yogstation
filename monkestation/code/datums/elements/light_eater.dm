/datum/element/light_eater/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_LIGHT_EATER_EAT, PROC_REF(on_eat_signal))

/datum/element/light_eater/proc/on_eat_signal(datum/source, food, eater, silent)
	SIGNAL_HANDLER
	eat_lights(food, eater, silent)
