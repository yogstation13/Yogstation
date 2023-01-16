// CPU that allows the computer to run programs.
// Better CPUs are obtainable via research and can run more programs on background.

/obj/item/computer_hardware/processor_unit
	name = "processor board"
	desc = "A standard CPU board used in most computers. It can run up to three programs simultaneously."
	icon_state = "cpuboard"
	w_class = WEIGHT_CLASS_NORMAL
	power_usage = 50
	critical = 1
	malfunction_probability = 1
	var/max_idle_programs = 2 // 2 idle, + 1 active = 3 as said in description.
	var/single_purpose = FALSE // If you can switch to other programs or only use the initial program
	device_type = MC_CPU

/obj/item/computer_hardware/processor_unit/on_remove(obj/item/modular_computer/MC, mob/user)
	MC.shutdown_computer()

/obj/item/computer_hardware/processor_unit/small
	name = "microprocessor"
	desc = "A miniaturised CPU used in portable devices. It can run up to two programs simultaneously."
	icon_state = "cpu"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 25
	max_idle_programs = 1

/obj/item/computer_hardware/processor_unit/photonic
	name = "photonic processor board"
	desc = "An advanced experimental CPU board that uses photonic core instead of regular circuitry. It can run up to five programs simultaneously, but uses a lot of power."
	icon_state = "cpuboard_super"
	w_class = WEIGHT_CLASS_NORMAL
	power_usage = 250
	max_idle_programs = 4

/obj/item/computer_hardware/processor_unit/photonic/small
	name = "photonic microprocessor"
	desc = "An advanced miniaturised CPU for use in portable devices. It uses photonic core instead of regular circuitry. It can run up to three programs simultaneously."
	icon_state = "cpu_super"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 75
	max_idle_programs = 2

/obj/item/computer_hardware/processor_unit/pda
	name = "cheep microprocessor"
	desc = "A BRISC V based CPU that uses very little power while providing good processing power"
	icon_state = "cpu"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 25
	max_idle_programs = 2

/obj/item/computer_hardware/processor_unit/pda/can_install(obj/item/modular_computer/M, mob/living/user)
	if(!istype(M, /obj/item/modular_computer/tablet))
		to_chat(user, span_warning("\The [M] does not support BRISC V architectures!"))
		return FALSE
	return ..()
	
