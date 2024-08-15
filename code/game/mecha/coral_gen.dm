/obj/item/mecha_parts/mecha_equipment/coral_generator
	name = "TBA"
	desc = "TBA"
	icon_state = "mecha_afterburner" 
	selectable = FALSE // your mech IS the weapon
	var/minimum_damage = 10
	var/structure_damage_mult = 4
	var/list/hit_list = list()
	equip_actions = list(/datum/action/innate/mecha/coral_overload_mode)

/obj/item/mecha_parts/mecha_equipment/coral_generator/can_attach(obj/mecha/new_mecha)
	if(locate(type) in new_mecha.equipment)
		return FALSE // no stacking multiple
	return ..()

/datum/action/innate/mecha/coral_overload_mode
	name = "TBA"
	button_icon_state = "TBA"

/datum/action/innate/mecha/coral_overload_mode/Activate(forced_state = null)
	if(chassis?.equipment_disabled) // If a EMP or something has messed a mech up return instead of activating -- Moogle
		return
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.coral_leg_overload_mode = forced_state
	else
		chassis.coral_leg_overload_mode = !chassis.coral_leg_overload_mode
	button_icon_state = "mech_overload_[chassis.coral_leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.", LOG_MECHA)
	if(chassis.coral_leg_overload_mode)
		chassis.AddComponent(/datum/component/after_image, 0.5 SECONDS, 0.5, TRUE)
		chassis.coral_leg_overload_mode = 1
		chassis.step_in = min(1, round(chassis.step_in/2))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.occupant_message(span_danger("You enable leg actuators overload."))
	else
		var/datum/component/after_image/chassis_after_image = chassis.GetComponent(/datum/component/after_image)
		if(chassis_after_image)
			qdel(chassis_after_image)
		chassis.coral_leg_overload_mode = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message(span_notice("You disable leg actuators overload."))
	build_all_button_icons()
